
'---[ Software License Agreement ]----------------------------------------------
'
' The software supplied herewith by Overton Instruments (Oi) is intended and
' supplied to you for use solely and exclusively with products manufactured by
' OI.
'
' The software is owned by Oi and/or a supplier, and is protected under
' applicable copyright laws.  All rights are reserved.  Any use in violation
' of the foregoing restrictions may subject the user to criminal sanctions under
' laws, as well as to civil liability for the breach of the terms and conditions
' of this license.
'
' THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION.  NO WARRANTIES, WHETHER
' EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO
' THIS SOFTWARE.  PROBESTAR SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR
' SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
'


'---[ Title ]-------------------------------------------------------------------
'
' File    : DUT-MATE Demo
' Version : 0.1
' Author  : Overton Claborne, OI
' Software; BASCOM-8051, MCS Electronics
'
'---[ Program Description ]-----------------------------------------------------
'
' This program demonstrates DUT-MATE functionality.  The Mini-MATE receives a
' set of serial commands from a Host PC, it parses them and then executes the
' command.
'
'---[ Compiler and Hardware related statements ]--------------------------------
'

$romstart = &H2000                                            'Load to RAM
$large
$default Xram
$baud = 115200                                                '19200                                                 'set 19200 baud rate for
$crystal = 22118400                                           '22.1184 MHz crystal

'---[ System Variables ]--------------------------------------------------------
'

      ' general purpose system support varibles

Dim Abort As Bit
Dim A_bit As Bit
Dim A_byte As Byte
Dim A_byte_tmp As Byte
Dim A_ch As Byte
Dim A_num As Byte
Dim A_cnt As Byte
Dim A_range As Byte
Dim A_loop As Byte
Dim A_word As Word
Dim A_addr As Word
Dim A_int As Integer
Dim A_sin As Single
Dim A_val As Long
Dim A_char As String * 1
Dim A_resp As String * 10


Dim S As String * 10
Dim A_str As String * 10
Dim A_str_tmp As String * 10
Dim A_string As String * 140
Dim A_array(10) As Byte

Dim Adc_val As Long
Dim Dac_val As Word
Dim Adc_array(10) As Long

Dim Err_flag As Bit



'---[ Constants - DUT SPECIFIC ]------------------------------------------------
'

Dim True As Const 1
Dim False As Const 0

         ' Spi-bus bit assignment

Sclk Alias P1.0                                               ' Serial clock signal                                            '
Dout Alias P1.1                                               ' Serial data output
Din Alias P1.2                                                ' Serial data input

         ' Various chip-selects

Dut_adc_cs Alias P1.3                                         ' ADC chip select
Dut_dac_cs Alias P1.4                                         ' DAC chip select
Dut_dio_cs Alias P1.5                                         ' DIO chip select
Dut_rst Alias P1.6                                            ' DIO reset


'---[ Include Files ]-----------------------------------------------------------
'

         ' Instrument Drivers

$include "DUT-MATE INC.BAS"


'---[ Initialization ]----------------------------------------------------------
'

Call System_init                                              ' init DUT-MATE hardware


'---[ Main loop ]---------------------------------------------------------------
'
'
'

            ' Serial command interface & string parser
Do
   Print
   Input "-> " , S
   S = Ucase(s)
   A_num = Len(s)
   If A_num = 0 Then

         ' print prompt
      Call Print_ok

   Else

      A_resp = Left(s , 3)
      If A_resp = "DT_" Then

         A_resp = Mid(s , 4 , 2)

         Select Case A_resp

         Case "SA":                                           'Get Short Status

            A_resp = Mid(s , 6 , 1)
            If A_resp = "?" Then
               Call Dut_get_short(a_bit)
               Print "<" ; A_bit ; ">"
            Else
               Call Print_ic
            End If

         Case "AS":                                           ' Perform Auto-Sequence

            Err_flag = False
            A_resp = Mid(s , 6 , 3)
            For A_cnt = 1 To 3                                ' chk valid control bits
               A_char = Mid(a_resp , A_cnt , 1)
               If A_char <> "0" And A_char <> "1" Then
                  Call Print_ic
                  Err_flag = True
                  Exit For
               End If
            Next A_cnt
            For A_cnt = 4 Downto 1                            ' state machine
               If Err_flag = True Then Exit For
               If A_cnt <> 2 Then A_char = Mid(a_resp , A_cnt , 1)
               If A_char = "1" Or A_cnt = 2 Then
                  If A_cnt = 4 Then                           ' Pre-power sequence
                     Call Dut_pwr_off                         ' disable DUT power
                     Call Dut_clr_oc                          ' clr circuit breaker
                     Call Dut_disc_rlyon                      ' enable discharge
                     Waitms 250
                     Call Dut_disc_rlyoff                     ' disable discharge
                     Waitms 50
                  Elseif A_cnt = 3 Then                       ' Chk short status
                     Call Dut_get_short(a_bit)
                     If A_bit = True Then
                        Print ">" ; 0 ; "<"                   ' send error code
                        Err_flag = True
                     End If
                  Elseif A_cnt = 2 Then                       ' Apply DUT power
                     Call Dut_pwr_on
                  Elseif A_cnt = 1 Then                       ' Acquire current readings
                     For A_loop = 1 To 10
                         Call Dut_rd_curmon(adc_val)
                         Adc_array(a_loop) = Adc_val
                     Next A_loop
                     Call Dut_get_doc(a_bit)                  ' chk circuit breaker
                     If A_bit = True Then
                        Print ">" ; "1" ; "<"                 ' send error code
                        Err_flag = True
                     Else
                        For A_loop = 1 To 10                  ' send current readings
                            If Err_flag = True Then Exit For
                            Adc_val = Adc_array(a_loop)
                            A_byte = 0
                            If Adc_val.20 = True Then A_byte.0 = 1
                            If Adc_val.21 = True Then A_byte.1 = 1
                            If A_byte = 2 Then                ' valid reading
                               Adc_val = Adc_val And &H00FFFFFF
                               Shift Adc_val , Right , 4
                               A_word = Loww(adc_val)
                               'A_val = 1.25 / 65535
                               'A_val = A_val * A_word
                               'A_str = Str(a_val)
                               'A_str = Mid(a_str , 1 , 4)
                               'If A_byte <> 1 Then A_char = ""
                               A_str = Hex(a_word)
                               If A_loop = 1 Then
                                 Print "<" ; A_str ; ", " ;
                               Elseif A_loop => 2 And A_loop <= 9 Then
                                 Print A_str ; ", ";
                               Else
                                 Print A_str ; ">"
                               End If
                            Else
                                Call Print_oor                ' out-of-range
                                Err_flag = True
                            End If
                        Next A_loop
                     End If
                  Else
                  End If
               Else
                  Call Print_ic                               ' invalid command
                  Err_flag = True
               End If
            Next A_cnt

         Case "SO":                                           ' DUT over current

            A_resp = Mid(s , 6 , 1)
            If A_resp = "?" Then
               A_str = Str(dac_val)
               Print "<" ; A_str ; ">"
            Else
               A_resp = Mid(s , 6 , 4)
               A_word = Val(a_resp)
               If A_word > 4095 Then
                  Call Print_oor                              ' out-of-range
               Else
                  Dac_val = A_word
                  Call Dut_wr_ocb(dac_val)
                  Call Print_ok
               End If
            End If


         Case "OC":                                           ' Clear DUT over-current condition

            Call Dut_clr_oc
            Call Print_ok


         Case "DO":                                           ' Get DUT over-current status

            A_resp = Mid(s , 6 , 1)
            If A_resp = "?" Then
               Call Dut_get_doc(a_bit)
               Print "<" ; A_bit ; ">"
            Else
               Call Print_ic
            End If


         Case "DD":                                           ' DUT discharge

            A_resp = Mid(s , 6 , 1)
            A_num = Val(a_resp)
            If A_num = 0 Or A_num = 1 Then
               If A_num = 1 Then Call Dut_disc_rlyon          ' Enable DUT discharge relay
               If A_num = 0 Then Call Dut_disc_rlyoff         ' Disable DUT discharge relay
               Call Print_ok
            Else
               Call Print_ic
            End If


         Case "DP":                                           ' DUT power

            A_resp = Mid(s , 6 , 1)
            A_num = Val(a_resp)
            If A_num = 0 Or A_num = 1 Then
               If A_num = 1 Then Call Dut_pwr_on              ' Enable DUT Power
               If A_num = 0 Then Call Dut_pwr_off             ' Disable DUT Power
               Call Print_ok
            Else
               Call Print_ic
            End If


         Case "SR":                                           ' get Short status

            A_resp = Mid(s , 6 , 1)
            A_num = Val(a_resp)
            If A_resp = "?" Then
               Call Dut_get_short(a_bit)
               Print "<" ; A_bit ; ">"
               Call Print_ok
            Else
               Call Print_ic
            End If

         Case "DR":                                           ' Master Clear

            Call System_init
            Call Print_ok

         Case "ID":

            A_resp = Mid(s , 6 , 1)                           '
            If A_resp = "?" Then
               Print "<" ; "DUT-MATE v2.0" ; ">"
            Else
               Call Print_ic                                  ' invalid command
            End If

         Case "MN":                                           ' Get DUT-MATE model number

            A_resp = Mid(s , 6 , 1)                           '
            If A_resp = "?" Then
               A_str = Str(dut_model_num)
               Print "<" ; A_str ; ">"
            Else
               Call Print_ic                                  ' invalid command
            End If

         Case "CM":                                           ' Get DUT current

            A_resp = Mid(s , 6 , 1)
            If A_resp = "?" Then
               Call Dut_rd_curmon(adc_val)                    ' Read DUT current drain
               A_byte = 0
               If Adc_val.20 = True Then A_byte.0 = 1
               If Adc_val.21 = True Then A_byte.1 = 1
               If A_byte = 2 Then
                  Shift Adc_val , Right , 4
                  A_word = Adc_val And &H0000FFFF
                  A_str = Str(a_word)
                  Print "<" ; A_str ; ">"
                  'Print A_word
                  'Print Adc_val
                  'Print
               Elseif A_byte = 3 Then
                  Call Print_oor
               Elseif A_byte = 1 Then
                  Call Print_oor
               Else
               End If
            Else
               Call Print_ic
            End If

         Case Else

            Call Print_ic                                     ' invalid command

         End Select

      Else

         Call Print_ic                                        ' invalid command

      End If

   End If

Loop

End


Sub System_init

      ' initialize DUT-MATE hardware

   Call Dut_init

   Set Sclk
   Set Dout
   Set Dut_adc_cs
   Set Dut_dio_cs
   Set Dut_rst

   Dac_val = 0

End Sub


Sub Print_ic

      ' print invalid command

   Print "><"

End Sub


Sub Print_oor

      ' print out-of-range

   Print ">>"

End Sub


Sub Print_ok

      ' print command OK

   Print "<>"

End Sub