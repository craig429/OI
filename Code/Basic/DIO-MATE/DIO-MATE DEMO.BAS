'---[ Software License Agreement ]----------------------------------------------
'
' The software supplied herewith by OVERTON INSTRUMENTS (Oi) is intended and
' supplied to you for use solely and exclusively with products manufactured by
' Oi.
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
' File    : DIO-MATE Demo
' Version : 0.1
' Author  : Overton Claborne, Oi
'
'---[ Program Description ]-----------------------------------------------------
'
'
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

Dim A_bit As Bit
Dim A_byte As Byte
Dim A_byte_tmp As Byte
Dim A_num As Byte
Dim A_cnt As Byte
Dim A_len As Byte
Dim A_pos As Byte
Dim A_word As Word
Dim A_addr As Word
Dim A_int As Integer
Dim A_sin As Single
Dim A_val As Long
Dim A_char As String * 1
Dim A_resp As String * 10


Dim S As String * 10
Dim A_str As String * 10
Dim A_buf As String * 128


'---[ Constants ]---------------------------------------------------------------
'

Dim True As Const 1
Dim False As Const 0



      '----- Native port pin assignments
Sclk Alias P1.0
Dout Alias P1.1
Din Alias P1.2
Dio_cs Alias P1.3
Dio_rst Alias P1.4


Set Sclk
Set Dout
Set Dio_cs
Set Dio_rst


'---[ Sub Routines ]------------------------------------------------------------
'

Declare Sub Print_ic
Declare Sub Print_orr
Declare Sub Print_ok


'---[ Include Files ]-----------------------------------------------------------
'

         ' Interface Drivers

$include "DIO-MATE INC.BAS"


'---[ Initialization ]----------------------------------------------------------
'

A_bit = 0
A_byte = 0
A_num = 0
A_word = 0
A_int = 0
A_sin = 0
A_val = 0

Call Dio_init


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
      If A_resp = "IO_" Then

         A_resp = Mid(s , 4 , 3)

         Select Case A_resp

            Case "PN":                                        'select DIO port number

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  A_char = Chr(dio_port_num)
                  Print "<" ; A_char ; ">"
               Else
                  A_num = Val(a_resp)
                  If A_num < 0 Or A_num > 5 Then
                     Call Print_oor                           ' out-of-range
                  Else
                     Dio_port_num = A_num
                  End If
               End If

            Case "PD":                                        ' set DIO port direction

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Dio_funct_num = Dio_iodir
                  Call Dio_rd(dio_port_num , Dio_funct_num , Dio_data)
                  A_num = 1
                  For A_cnt = 7 Downto 0
                     A_bit = Dio_data.a_cnt
                     If A_bit = 0 Then A_char = "0"
                     If A_bit = 1 Then A_char = "1"
                     Mid(a_str , A_num , 1) = A_char
                     Incr A_num
                  Next A_cnt
               Else
                  A_num = 7
                  A_byte = 0
                  For A_cnt = 6 To 13
                     A_char = Mid(a_resp , A_cnt , 1)
                     If A_char <> "0" And A_char <> "1" Then Call Print_oor
                     If A_char = "0" Then A_bit = 0
                     If A_char = "1" Then A_bit = 1
                     A_byte.a_num = A_bit
                     Decr A_num
                  Next A_cnt
                  Dio_data = A_byte
                  Dio_funct_num = Dio_iodir
                  Call Dio_wr(dio_port_num , Dio_funct_num , Dio_data)
                  Call Print_ok
               End If

            Case "PB":                                        ' read/write DIO port

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Dio_funct_num = Dio_gpio
                  Call Dio_rd(dio_port_num , Dio_funct_num , Dio_data)
                  A_num = 1
                  For A_cnt = 7 Downto 0
                     A_bit = Dio_data.a_cnt
                     If A_bit = 0 Then A_char = "0"
                     If A_bit = 1 Then A_char = "1"
                     Mid(a_str , A_num , 1) = A_char
                     Incr A_num
                  Next A_cnt
               Else
                  A_num = 7
                  A_byte = 0
                  For A_cnt = 6 To 13
                     A_char = Mid(a_resp , A_cnt , 1)
                     If A_char <> "0" And A_char <> "1" Then Call Print_oor
                     If A_char = "0" Then A_bit = 0
                     If A_char = "1" Then A_bit = 1
                     A_byte.a_num = A_bit
                     Decr A_num
                  Next A_cnt
                  Dio_data = A_byte
                  Dio_funct_num = Dio_gpio
                  Call Dio_wr(dio_port_num , Dio_funct_num , Dio_data)
                  Call Print_ok
               End If

            Case "PU":                                        ' configure weak pull-ups

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Dio_funct_num = Dio_gppu
                  Call Dio_rd(dio_port_num , Dio_funct_num , Dio_data)
                  A_num = 1
                  For A_cnt = 7 Downto 0
                     A_bit = Dio_data.a_cnt
                     If A_bit = 0 Then A_char = "0"
                     If A_bit = 1 Then A_char = "1"
                     Mid(a_str , A_num , 1) = A_char
                     Incr A_num
                  Next A_cnt
               Else
                  A_num = 7
                  A_byte = 0
                  For A_cnt = 6 To 13
                     A_char = Mid(a_resp , A_cnt , 1)
                     If A_char <> "0" And A_char <> "1" Then Call Print_oor
                     If A_char = "0" Then A_bit = 0
                     If A_char = "1" Then A_bit = 1
                     A_byte.a_num = A_bit
                     Decr A_num
                  Next A_cnt
                  Dio_data = A_byte
                  Dio_funct_num = Dio_gppu
                  Call Dio_wr(dio_port_num , Dio_funct_num , Dio_data)
                  Call Print_ok
               End If

            Case "ID":                                        ' read product ID

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Print "<" ; "DIO-MATE, v0.1" ; ">"
                  Print
               Else
                  Call Print_ic                               ' invalid command
               End If

            Case "MR":                                        ' Master Reset

               Call Dio_init
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


Sub Print_ic

   Print "><"

End Sub


Sub Print_oor

   Print ">>"

End Sub


Sub Print_ok

   Print "<>"

End Sub