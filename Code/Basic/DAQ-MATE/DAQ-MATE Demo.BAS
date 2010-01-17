
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
' File    : DAQ-MATE Demo
' Version : 0.1
' Author  : Overton Claborne, OI
' Software; BASCOM-8051, MCS Electronics
'
'---[ Compiler and Hardware related statements ]--------------------------------
'
$large
'$romstart = &H8000
$default Xram
$timeout
$baud = 115200
$crystal = 22118400

'---[ Variables ]---------------------------------------------------------------
'

Dim Err_trap As Bit

Dim A_bit As Bit
Dim A_pol As Byte
Dim A_byte As Byte
Dim A_byte_tmp As Byte
Dim A_num As Byte
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


Dim Adc_val As Word                                           ' ADC data
Dim Dac_val As Word                                           ' DAC value

Dim S As String * 16
Dim A_str As String * 10
Dim A_str_tmp As String * 10
Dim A_string As String * 64

Dim Ex_resp As Byte

Dim Se_mode(32) As Byte
Dim Se_range(32) As Byte
Dim Se_lookup(16) As Byte
Dim Diff_mode(16) As Byte
Dim Diff_range(16) As Byte
Dim Diff_pol(16) As Byte
Dim Diff_lookup(16) As Byte


'---[ Constants ]---------------------------------------------------------------
'

Dim True As Const 1
Dim False As Const 0

      '----- Native port pin assignments

Sclk Alias P1.7
Dout Alias P1.6
Din Alias P1.5
Daq_adc_cs0 Alias P1.4
Daq_adc_cs1 Alias P1.3
Daq_adc_cs2 Alias P1.2
Daq_adc_cs3 Alias P1.1
Daq_adc_busy Alias P1.0

Set Sclk
Set Dout
Set Daq_adc_cs0
Set Daq_adc_cs0
Set Daq_adc_cs0
Set Daq_adc_cs0

'---[ Sub Routines ]------------------------------------------------------------
'

Declare Sub Print_ic
Declare Sub Print_orr
Declare Sub Print_ok


'---[ Include Files ]-----------------------------------------------------------
'

         ' Interface Drivers

$include "DAQ-MATE INC.BAS"


'---[ Initialization ]----------------------------------------------------------
'

A_bit = 0
A_byte = 0
A_num = 0
A_word = 0
A_int = 0
A_sin = 0
A_val = 0

Wait 1

Call Daq_init

For A_cnt = 1 To 32
   Se_mode(a_cnt) = 1
   Se_range(a_cnt) = 1
Next A_cnt

For A_cnt = 1 To 16
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
Diff_lookup(9) = 5
Diff_lookup(10) = 5
Diff_lookup(11) = 6
Diff_lookup(12) = 6
Diff_lookup(13) = 7
Diff_lookup(14) = 7
Diff_lookup(15) = 8
Diff_lookup(16) = 8
Diff_lookup(17) = 9
Diff_lookup(18) = 9
Diff_lookup(19) = 10
Diff_lookup(20) = 10
Diff_lookup(21) = 11
Diff_lookup(22) = 11
Diff_lookup(23) = 12
Diff_lookup(24) = 12
Diff_lookup(25) = 13
Diff_lookup(26) = 13
Diff_lookup(27) = 14
Diff_lookup(28) = 14
Diff_lookup(29) = 15
Diff_lookup(30) = 15
Diff_lookup(31) = 16
Diff_lookup(32) = 16

'---[ Main loop ]---------------------------------------------------------------
'
'
'
            ' Serial command interface & string parser
Do
   Print
   Err_trap = False
   Input "-> " , S Noecho
   S = Ucase(s)
   A_num = Len(s)
   If A_num > 0 Then

      A_resp = Left(s , 3)
      If A_resp = "DQ_" Then

         A_resp = Mid(s , 4 , 2)

         Select Case A_resp

            Case "SS":                                        ' Set Single-Ended inputs

               A_str = Mid(s , 6 , 2)
               A_ch = Val(a_str)
               If A_ch => 0 And A_ch <= 32 Then Err_trap = True       ' identify channel
               A_char = Mid(s , 8 , 1)
               A_range = Val(a_char)
               If A_range => 1 And A_range <= 4 Then Err_trap = True       ' identify range
               If Err_trap = False Then
                  If A_ch = 0 Then
                     For A_cnt = 1 To 32
                        Se_mode(a_cnt) = True                 ' set single-ended and
                        Se_range(a_cnt) = A_range             ' range for all channels
                     Next A_cnt
                     For A_cnt = 1 To 16
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

               A_str = Mid(s , 6 , 2)
               A_ch = Val(a_str)
               If A_ch => 0 And A_ch <= 32 Then Err_trap = True       ' identify ADC channel
               A_char = Mid(s , 8 , 1)
               A_pol = Val(a_char)
               If A_pol => 0 And A_pol <= 1 Then Err_trap = True       ' identify polarity
               A_char = Mid(s , 9 , 1)
               A_range = Val(a_char)
               If A_range => 0 And A_range <= 4 Then Err_trap = True       ' identify range
               If Err_trap = False Then
                  If A_ch = 0 Then
                     For A_cnt = 1 To 16
                        Diff_mode(a_cnt) = True
                        Diff_range(a_cnt) = A_range
                        Diff_pol(a_cnt) = A_pol
                     Next A_cnt
                     For A_cnt = 1 To 32
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

            Case "RC":                                        'Configure & Read single ADC channel

               A_char = Mid(s , 6 , 1)
               If A_char = "?" Then
                  A_char = Mid(s , 7 , 1)
                  Daq_ch = Val(a_char)
                  If Daq_ch > 32 Then Err_trap = True
                  A_char = Mid(s , 8 , 1)
                  If A_char <> "D" And A_char <> "S" Then
                     Err_trap = True
                  Else
                     If A_char = "D" Then Daq_mode = 0
                     If A_char = "S" Then Daq_mode = 1
                  End If
                  A_char = Mid(s , 9 , 1)
                  If A_char <> "0" And A_char <> "1" Then
                     Err_trap = True
                  Else
                     If A_char = "0" Then Daq_pol = 0
                     If A_char = "1" Then Daq_pol = 1
                  End If
                  If Daq_ch > 16 And Daq_mode = 0 Then Err_trap = True
                  A_char = Mid(s , 10 , 1)
                  Daq_range = Val(a_char)
                  If Daq_range < 1 Or Daq_range > 4 Then Err_trap = True
                  If Err_trap = False Then
                     Call Daq_rd_adc(daq_val , Daq_ch , Daq_mode , Daq_pol , Daq_range)
                     Printhex "<" ; Daq_val ; ">"
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
                     For A_cnt = 1 To 32
                        A_bit = True
                        If Se_mode(a_cnt) = True Then
                           Daq_range = Se_range(a_cnt)
                           If Ex_resp = True Then Print "CH" ; A_cnt ; "S" ; "0" ; Daq_range ; "=";
                           Daq_ch = A_cnt                     ' set single-ended ch
                        Else
                           A_ch = Diff_lookup(a_cnt)
                           If A_ch <> A_num Then
                              Daq_range = Diff_range(a_ch)
                              Daq_pol = Diff_pol(a_ch)
                              If Ex_resp = True Then Print "CH" ; A_ch ; "D" ; Daq_pol ; Daq_range ; "=";
                              Daq_ch = A_ch                   ' set differential-ended ch
                              A_num = A_ch
                           Else
                              A_bit = False
                           End If
                        End If
                        If A_bit = True Then
                           Call Daq_rd_adc(daq_val , Daq_ch , Daq_mode , Daq_pol , Daq_range)
                           Printhex Daq_val;
                           If A_cnt <> 32 Then Print ",";
                        End If
                     Next A_cnt
                     Print ">"
                  Else
                     Call Print_oor
                  End If
               Else
                  Call Print_ic
               End If

            Case "MR":                                        ' master reset

               Set Sclk
               Set Dout
               Set Daq_adc_cs0
               Set Daq_adc_cs0
               Set Daq_adc_cs0
               Set Daq_adc_cs0

               For A_cnt = 1 To 32
                  Se_mode(a_cnt) = 1
                  Se_range(a_cnt) = 1
               Next A_cnt

               For A_cnt = 1 To 16
                  Diff_mode(a_cnt) = 0
                  Diff_range(a_cnt) = 1
                  Diff_pol(a_cnt) = 0
               Next A_cnt
               Call Daq_init
               Call Print_ok

            Case "ID":                                        ' read product ID

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Print "<" ; "DAQ-MATE, v0.1" ; ">"
               Else
                  Call Print_ic                               ' invalid command
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


Sub Print_ic

   Print "><"

End Sub


Sub Print_oor

   Print ">>"

End Sub


Sub Print_ok

   Print "<>"

End Sub