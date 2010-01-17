
'---[ Software License Agreement ]----------------------------------------------
'
' The software supplied herewith by Overton Instruments (OI) is intended and
' supplied to you for use solely and exclusively with products manufactured by
' OI.
'
' The software is owned by OI and/or a supplier, and is protected under
' applicable copyright laws.  All rights are reserved.  Any use in violation
' of the foregoing restrictions may subject the user to criminal sanctions under
' laws, as well as to civil liability for the breach of the teSfs and conditions
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
' File    : Check-MATE Demo
' Version : 0.1
' Author  : Overton Claborne, OI
' Software; BASCOM-8051, MCS Electronics
'
'---[ Program Description ]-----------------------------------------------------
'
' This program demonstrates Check-MATE functionality.  The Mini-MATE receives a
' set of serial commands from a Host PC, it parses them and then executes the
' command.
'
'---[ Compiler and Hardware related statements ]--------------------------------
'
$large
$romstart = &H2000
$default Xram
$timeout
Baud = 19200                                                  '115200
$crystal = 22118400

'---[ Variables ]---------------------------------------------------------------
'


Dim Err_trap As Bit

Dim A_bit As Bit
Dim A_pol As Byte
Dim A_byte As Byte
Dim A_byte_tmp As Byte
Dim A_num As Byte
Dim A_num_2 As Byte
Dim A_cnt As Byte
Dim A_ch As Byte
Dim A_range As Byte
Dim A_word As Word
Dim A_addr As Word
Dim A_int As Integer
Dim A_sin As Single
Dim A_val As Long
Dim A_char As String * 1
Dim A_resp As String * 16

Dim X_pos As Byte
Dim Y_pos As Byte

Dim Ex_resp As Byte

Dim Adc_val As Word                                           ' ADC data
Dim Dac_val As Word                                           ' DAC value

Dim S As String * 16
Dim A_str As String * 10
Dim A_str_tmp As String * 10
Dim A_string As String * 64

Dim Se_mode(8) As Byte
Dim Se_range(8) As Byte
Dim Se_lookup(4) As Byte
Dim Diff_mode(4) As Byte
Dim Diff_range(4) As Byte
Dim Diff_pol(4) As Byte
Dim Diff_lookup(8) As Byte


'---[ Constants ]---------------------------------------------------------------
'

Dim True As Const 1
Dim False As Const 0



      '----- Native port pin assignments
Sclk Alias P1.7
Dout Alias P1.6
Din Alias P1.5
Adc_cs Alias P1.4
Dac_cs Alias P1.3
Dio_cs Alias P1.2
Uni_bip Alias P1.1
Adc_busy Alias P1.0

Set Sclk
Set Dout
Set Adc_cs
Set Dac_cs
Set Dio_cs
Set Uni_bip


'---[ Local Sub Routines ]------------------------------------------------------
'

Declare Sub Print_ic
Declare Sub Print_orr
Declare Sub Print_ok
Declare Sub Go_send_dio
Declare Sub Go_chk_dio


'---[ Include Files ]-----------------------------------------------------------
'

         ' Interface Drivers

$include "Check-MATE INC.BAS"


'---[ Initialization ]----------------------------------------------------------
'

A_bit = 0
A_byte = 0
A_num = 0
A_word = 0
A_int = 0
A_sin = 0
A_val = 0
Err_trap = 0

Wait 1

Call Chk_init

For A_cnt = 1 To 8
   Se_mode(a_cnt) = 1
   Se_range(a_cnt) = 1
Next A_cnt

For A_cnt = 1 To 4
   Diff_mode(a_cnt) = 0
   Diff_range(a_cnt) = 1
   Diff_pol(a_cnt) = 0
Next A_cnt

Diff_lookup(1) = 1
Diff_lookup(2) = 1
Diff_lookup(3) = 2
Diff_lookup(4) = 2
Diff_lookup(5) = 3
Diff_lookup(6) = 3
Diff_lookup(7) = 4
Diff_lookup(8) = 4


'---[ Main loop ]---------------------------------------------------------------
'
'
'

Main:

            ' Serial command interface & string parser
Do
   Print
   Err_trap = False
   Input "-> " , S Noecho
   S = Ucase(s)
   A_num = Len(s)
   If A_num > 0 Then

      A_resp = Left(s , 3)
      If A_resp = "CK_" Then

         A_resp = Mid(s , 4 , 2)

         Select Case A_resp

            Case "SS":                                        ' Set Single-Ended inputs

               A_char = Mid(s , 6 , 1)
               A_ch = Val(a_char)
               If A_ch => 0 And A_ch <= 8 Then Err_trap = True       ' identify channel
               A_char = Mid(s , 7 , 1)
               A_range = Val(a_char)
               If A_range => 1 And A_range <= 4 Then Err_trap = True       ' identify range
               If Err_trap = False Then
                  If A_ch = 0 Then
                     For A_cnt = 1 To 8
                        Se_mode(a_cnt) = True                 ' set single-ended and
                        Se_range(a_cnt) = A_range             ' range for all channels
                     Next A_cnt
                     For A_cnt = 1 To 4
                        Diff_mode(a_cnt) = False              ' clear all differential
                     Next A_cnt
                  Else
                     Se_mode(a_ch) = A_range                  ' set specific channel
                     A_num = Diff_lookup(a_ch)
                     Diff_mode(a_num) = False
                  End If
                  Call Print_ok
               Else
                  Call Print_oor
               End If

            Case "SD":                                        ' Set Differential inputs

               A_char = Mid(s , 6 , 1)
               A_ch = Val(a_char)
               If A_ch => 0 And A_ch <= 4 Then Err_trap = True       ' identify ADC channel
               A_char = Mid(s , 7 , 1)
               A_pol = Val(a_char)
               If A_pol => 0 And A_pol <= 1 Then Err_trap = True       ' identify polarity
               A_char = Mid(s , 8 , 1)
               A_range = Val(a_char)
               If A_range => 0 And A_range <= 8 Then Err_trap = True       ' identify range
               If Err_trap = False Then
                  If A_ch = 0 Then
                     For A_cnt = 1 To 4
                        Diff_mode(a_cnt) = True
                        Diff_range(a_cnt) = A_range
                        Diff_pol(a_cnt) = A_pol
                     Next A_cnt
                     For A_cnt = 1 To 8
                        Se_mode(a_cnt) = False                ' clear single-ended
                     Next A_cnt
                  Else
                     Diff_mode(a_ch) = True
                     A_num = Se_lookup(a_ch)
                     Se_mode(a_num) = False
                     Incr A_num
                     Se_mode(a_num) = False
                  End If
                  Call Print_ok
               Else
                  Call Print_oor
               End If

            Case "RC":                                        'Configure & Read single channel

               A_char = Mid(s , 6 , 1)
               If A_char = "?" Then
                  A_char = Mid(s , 7 , 1)
                  Chk_ch = Val(a_char)
                  If Chk_ch > 8 Then Err_trap = True
                  A_char = Mid(s , 8 , 1)
                  If A_char <> "D" And A_char <> "S" Then
                     Err_trap = True
                  Else
                     If A_char = "D" Then Chk_mode = 0
                     If A_char = "S" Then Chk_mode = 1
                  End If
                  A_char = Mid(s , 9 , 1)
                  If A_char <> "0" And A_char <> "1" Then
                     Err_trap = True
                  Else
                     If A_char = "0" Then Chk_pol = 0
                     If A_char = "1" Then Chk_pol = 1
                  End If
                  If Chk_ch > 4 And Chk_mode = 0 Then Err_trap = True
                  A_char = Mid(s , 10 , 1)
                  Chk_range = Val(a_char)
                  If Chk_range < 1 Or Chk_range > 4 Then Err_trap = True
                  If Err_trap = False Then
                     Call Chk_rd_adc(chk_val , Chk_ch , Chk_mode , Chk_pol , Chk_range)
                     Printhex "<" ; Chk_val ; ">"
                  Else
                     Call Print_oor
                  End If
               Else
                   Call Print_ic
               End If

            Case "AS":                                        ' Auto scan all channels

               A_num = 0
               A_char = Mid(s , 6 , 1)
               If A_char = "?" Then
                  A_char = Mid(s , 7 , 1)
                  Ex_resp = Val(a_char)
                  If Ex_resp < 2 Then
                     Print "<";
                     For A_cnt = 1 To 8
                        A_bit = True
                        If Se_mode(a_cnt) = True Then
                           Chk_range = Se_range(a_cnt)
                           If Ex_resp = True Then Print "CH" ; A_cnt ; "S" ; "0" ; Chk_range ; "=";
                           Chk_ch = A_cnt                     ' set single-ended ch
                        Else
                           A_ch = Diff_lookup(a_cnt)
                           If A_ch <> A_num Then
                              Chk_range = Diff_range(a_ch)
                              Chk_pol = Diff_pol(a_ch)
                              If Ex_resp = True Then Print "CH" ; A_ch ; "D" ; Chk_pol ; Chk_range ; "=";
                              Chk_ch = A_ch                   ' set differential-ended ch
                              A_num = A_ch
                           Else
                              A_bit = False
                           End If
                        End If
                        If A_bit = True Then
                           Call Chk_rd_adc(chk_val , Chk_ch , Chk_mode , Chk_pol , Chk_range)
                           Printhex Chk_val;
                           If A_cnt <> 8 Then Print ",";
                        End If
                     Next A_cnt
                     Print ">"
                  Else
                     Call Print_oor
                  End If
               Else
                  Call Print_ic
               End If

            Case "MS":                                        ' set measurement samples

               A_char = Mid(s , 6 , 1)
               If A_char = "?" Then
                  A_str = Str(chk_m_cnts)
                  Print "<" ; A_str ; ">"
               Else
                  A_resp = Mid(s , 6 , 3)
                  A_word = Val(a_resp)
                  If A_word > 255 Then
                     Call Print_oor
                  Else
                     Chk_m_cnts = A_word
                     Call Print_ok
                  End If
               End If

            Case "DR":                                        'Set DAC Range

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  If Chk_dac_range = 0 Then A_str = "0"
                  If Chk_dac_range = 1 Then A_str = "1"
                  Print "<" ; A_str ; ">"
               Else
                  A_num = Val(a_resp)
                  If A_num <> 0 And A_num <> 1 Then
                     Call Print_oor                           ' out-of-range
                  Else
                     A_bit = A_num.0
                     If Chk_dac_range <> A_bit Then
                        Chk_dac_range = A_bit
                        Call Chk_dac_mode(a_bit)
                        If A_bit = 1 Then Chk_dac_word = 0
                        If A_bit = 0 Then Chk_dac_word = 2048
                        Call Chk_wr_dac(chk_dac_word)
                     End If
                     Call Print_ok
                  End If
               End If

            Case "SA":                                        'Set dac output voltage

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  'A_str = "0000"
                  'A_str_tmp = Str(chk_dac_word)
                  'A_len = Len(a_str_tmp)
                  'A_pos = 4 - A_len
                  'If A_pos = 0 Then
                     'A_str = A_str_tmp
                  'Else
                   '  Mid(a_str , A_pos , A_len) = A_str_tmp
                  'End If
                  A_str = Str(chk_dac_word)
                  Print "<" ; A_str ; ">"
               Else
                  A_resp = Mid(s , 6 , 4)
                  A_word = Val(a_resp)
                  If A_word > 4095 Then
                     Call Print_oor                           ' out-of-range
                  Else
                     Chk_dac_word = A_word
                     Call Chk_wr_dac(chk_dac_word)
                     Call Print_ok
                  End If
               End If


            Case "PD":                                        ' set DIO port direction

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Chk_rd_dio(chk_iodir , Chk_data)
                  Call Go_send_dio
               Else
                  Call Go_chk_dio
                  If Err_trap = False Then
                     Chk_data = A_byte
                     Call Chk_wr_dio(chk_iodir , Chk_data)
                     Call Print_ok
                  End If
               End If

            Case "PB":                                        ' write to DIO port

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Chk_rd_dio(chk_gpio , Chk_data)
                  Call Go_send_dio
               Else
                  Call Go_chk_dio
                  If Err_trap = False Then
                     Chk_data = A_byte
                     Call Chk_wr_dio(chk_gpio , Chk_data)
                     Call Print_ok
                  End If
               End If

            Case "PU":                                        ' configure weak pull-ups

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Chk_rd_dio(chk_gppu , Chk_data)
                  Call Go_send_dio
               Else
                  Call Go_chk_dio
                  If Err_trap = False Then
                     Chk_data = A_byte
                     Call Chk_wr_dio(chk_gppu , Chk_data)
                     Call Print_ok
                  End If
               End If

            Case "ID":

               A_resp = Mid(s , 6 , 1)                        '
               If A_resp = "?" Then
                  Print "<" ; "Check-MATE v0.1" ; ">"
               Else
                  Call Print_ic                               ' invalid command
               End If

            Case "MR":                                        ' master reset

               Set Sclk
               Set Dout
               Set Adc_cs
               Set Dac_cs
               Set Dio_cs
               Set Uni_bip

               For A_cnt = 1 To 8
                  Se_mode(a_cnt) = True                       ' set single-ended and
                  Se_range(a_cnt) = 1                         ' range for all channels
               Next A_cnt
               For A_cnt = 1 To 4
                  Diff_mode(a_cnt) = False                    ' clear all differential
               Next A_cnt

               Call Chk_init
               Call Print_ok

            Case Else

               Call Print_ic                                  ' invalid command

         End Select

      Else

         Call Print_ic                                        ' invalid command

      End If

   End If

Loop

End


Sub Go_send_dio

   A_num = 1
   For A_cnt = 7 Downto 0
      A_bit = Chk_data.a_cnt
      If A_bit = 0 Then A_char = "0"
      If A_bit = 1 Then A_char = "1"
      Mid(a_str_tmp , A_num , 1) = A_char
      Incr A_num
   Next A_cnt
   A_str = Mid(a_str_tmp , 1 , 8)
   Print "<" ; A_str ; ">"
   Print

End Sub


Sub Go_chk_dio

    A_num = 7
    A_byte = 0
    A_resp = Mid(s , 6 , 8)
    For A_cnt = 1 To 8
      A_char = " "
      A_char = Mid(a_resp , A_cnt , 1)
      If A_char = "0" Then
         A_bit = 0
      Elseif A_char = "1" Then
         A_bit = 1
      Else
         Call Print_oor
         Exit For
      End If
      A_byte.a_num = A_bit
      Decr A_num
    Next A_cnt

End Sub


Sub Print_ic

   Err_trap = True
   Print "><"

End Sub


Sub Print_oor

   Err_trap = True
   Print ">>"

End Sub


Sub Print_ok

   Print "<>"

End Sub