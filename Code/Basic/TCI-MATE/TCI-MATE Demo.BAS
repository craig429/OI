
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
' File    : TCI-MATE Demo
' Version : 0.1
' Author  : Overton Claborne, OI
' Software; BASCOM-8051, MCS Electronics
'
'---[ Program Description ]-----------------------------------------------------
'
' This program demonstrates TCI-MATE functionality.  The Mini-MATE receives a
' set of serial commands from a Host PC, it parses them and then executes the
' command.
'
'---[ Compiler and Hardware related statements ]--------------------------------
'
$large
$romstart = &H2000
$default Xram
$timeout
Baud = 9600                                                   '115200
$crystal = 22118400

'---[ Variables ]---------------------------------------------------------------
'


Dim Err_trap As Bit

Dim A_bit As Bit
Dim A_byte As Byte
Dim A_byte_tmp As Byte
Dim A_num As Byte
Dim A_cnt As Byte
Dim A_ch As Byte
Dim A_word As Word
Dim A_addr As Word
Dim A_int As Integer
Dim A_sin As Single
Dim A_val As Long
Dim A_char As String * 1
Dim A_resp As String * 40

Dim X_pos As Byte
Dim Y_pos As Byte

Dim S As String * 64
Dim A_str As String * 10
Dim A_str_tmp As String * 10
Dim A_string As String * 64


'---[ Constants ]---------------------------------------------------------------
'

Dim True As Const 1
Dim False As Const 0



      '----- Native port pin assignments
Sclk Alias P1.0
Dout Alias P1.1
Din Alias P1.2
Tci_dio_cs Alias P1.3
Tci_rtc_cs Alias P1.4
Tci_fram_cs Alias P1.5


'---[ Local Sub Routines ]------------------------------------------------------
'

Declare Sub Print_ic
Declare Sub Print_orr
Declare Sub Print_ok
Declare Sub Go_send_dio
Declare Sub Go_tci_dio


'---[ Include Files ]-----------------------------------------------------------
'

         ' Interface Drivers

$include "TCI-MATE INC.BAS"


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

Call Tci_init


'---[ Main loop ]---------------------------------------------------------------
'
'
'

Main:

            ' Serial command interface & string parser
Do
         ' prompt user and get command
   Do
      Print
      Input "-> " , S
      S = Ucase(s)
      A_num = Len(s)
   Loop Until A_num <> 0

                           ' parse header
      A_resp = Left(s , 3)
      If A_resp = "TC_" Then

         A_resp = Mid(s , 4 , 2)

                           ' identify command & execute it
         Select Case A_resp

            Case "PI":                                        'Panel Input
               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
                  Call Go_send_dio
               Else
                  Call Print_oor                              ' out-of-range
               End If

            Case "PO":                                        ' Panel Output
               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
                  Tci_data = Tci_data And &HF0
                  Shift Tci_data , Right , 4
                  Call Go_send_dio
               Else
                  A_resp = Mid(s , 6 , 4)
                  A_num = Len(a_resp)
                  A_byte = Val(a_resp)
                  If A_num = 4 And A_byte <= &H0F Then
                     Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
                     Tci_data = Tci_data And &H0F
                     Shift A_byte , Left , 4
                     Tci_data = Tci_data Or A_byte
                     Call Tci_wr_dio(2 , Tci_gpio , Tci_data)
                     Call Print_ok
                  Else
                     Call Print_oor                           ' out-of-range
                  End If
               End If

            Case "TW":                                        ' Get dual thumbwheel switch
               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_rd_dio(1 , Tci_gpio , Tci_data)
                  A_num = Makebcd(tci_data)
                  A_str = Str(a_num)
                  Print "<" ; A_str ; ">"
                  Print
               Else
                  Call Print_ic                               ' invalid command
               End If


            Case "AD":                                        ' Set AUX DIO port direction

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_auxdio_dir(tci_rd , Tci_data)
                  Tci_data = Tci_data And &H0F
                  Call Go_send_dio
               Else
                  A_resp = Mid(s , 6 , 4)
                  A_num = Len(a_resp)
                  A_byte = Val(a_resp)
                  If A_num = 4 And A_byte <= &H0F Then
                     Call Tci_auxdio_dir(tci_rd , Tci_data)
                     Tci_data = Tci_data And &HF0
                     Tci_data = Tci_data Or A_byte
                     Call Tci_auxdio_dir(tci_wr , Tci_data)
                     Call Print_ok
                  Else
                     Call Print_ic
                  End If
               End If

            Case "AP":                                        ' Write/Read AUX DIO port

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_auxdio_data(tci_rd , Tci_data)
                  Tci_data = Tci_data And &H0F
                  Call Go_send_dio
               Else
                  A_resp = Mid(s , 6 , 4)
                  A_num = Len(a_resp)
                  A_byte = Val(a_resp)
                  If A_num = 4 And A_byte <= &H0F Then
                     Call Tci_auxdio_data(tci_rd , Tci_data)
                     Tci_data = Tci_data And &HF0
                     Tci_data = Tci_data Or A_byte
                     Call Tci_auxdio_data(tci_wr , Tci_data)
                     Call Print_ok
                  Else
                     Call Print_oor
                  End If
               End If

            Case "AU":                                        ' configure weak pull-ups

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_auxdio_pup(tci_rd , Tci_data)
                  Tci_data = Tci_data And &H0F
                  Call Go_send_dio
               Else
                  A_resp = Mid(s , 6 , 4)
                  A_num = Len(a_resp)
                  A_byte = Val(a_resp)
                  If A_num = 4 And A_byte <= &H0F Then
                     Call Tci_auxdio_pup(tci_rd , Tci_data)
                     Tci_data = Tci_data And &HF0
                     Tci_data = Tci_data Or A_byte
                     Call Tci_auxdio_pup(tci_wr , Tci_data)
                     Call Print_ok
                  Else
                     Call Print_oor
                  End If
               End If

            Case "DP":                                        ' Day period, AM or PM

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_rtc_ampm(tci_rd , A_str)
                  Print "<" ; A_str ; ">"
                  Print
               Else
                  A_resp = Mid(s , 6 , 2)
                  If A_resp = "AM" Or A_resp = "PM" Then
                     Call Tci_rtc_ampm(tci_wr , A_str)
                     Call Print_ok
                  Else
                     Call Print_ic
                  End If
               End If

            Case "TV":                                        ' Time value

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_rtc_time(tci_rd , A_str)
                  Print "<" ; A_str ; ">"
                  Print
               Else
                  A_resp = Mid(s , 6 , 8)
                  Call Tci_rtc_time(tci_wr , A_resp)
                  If A_resp = "--------" Then
                     Call Print_oor
                  Else
                     Call Print_ok
                  End If
               End If

            Case "DV":                                        ' Date value

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  Call Tci_rtc_date(tci_rd , A_str)
                  Print "<" ; A_str ; ">"
                  Print
               Else
                  A_resp = Mid(s , 6 , 8)
                  Call Tci_rtc_date(tci_wr , A_resp)
                  If A_resp = "--------" Then
                     Call Print_oor
                  Else
                     Call Print_ok
                  End If
               End If

            Case "DT":                                        ' Get LCD display type code

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  A_str = Str(tci_lcd_sel)
                  Print "<" ; A_str ; ">"
                  Print
               Else
                  Call Print_ic
               End If

            Case "DC":                                        ' Clear LCD display

               Call Tci_lcd_clr
               Call Print_ok

            Case "DH":                                        ' Home LCD display

               Call Tci_lcd_home
               Call Print_ok

            Case "DM":                                        ' LCD display mode

               A_resp = Mid(s , 6 , 1)
               If A_resp = "?" Then
                  A_str = "0000"
                  A_char = "1"
                  If Tci_lcd_ena = True Then Mid(a_str , 1 , 1) = A_char
                  If Tci_lcd_curs = True Then Mid(a_str , 2 , 1) = A_char
                  If Tci_lcd_blink = True Then Mid(a_str , 3 , 1) = A_char
                  Print "<" ; A_str ; ">"
                  Print
               Else                                           '
                  A_char = "1"
                  A_resp = Mid(s , 6 , 4)
                  A_num = Len(a_resp)
                  A_byte = Val(a_resp)
                  If A_num = 4 And A_byte < 16 Then
                     Tci_lcd_ena = 0
                     Tci_lcd_curs = 0
                     Tci_lcd_blink = 0
                     For A_cnt = 1 To 4
                        A_str = Mid(a_resp , A_cnt , 1)
                        If A_str = A_char Then
                           If A_cnt = 1 Then Tci_lcd_ena = 1
                           If A_cnt = 2 Then Tci_lcd_curs = 1
                           If A_cnt = 3 Then Tci_lcd_blink = 1
                        End If
                     Next A_cnt
                     Call Tci_set_lcd_disp
                     Call Print_ok
                  Else
                     Call Print_oor
                  End If
               End If

            Case "DP":                                        ' LCD cursor position

                  A_resp = Mid(s , 6 , 3)
                  A_str = Mid(a_resp , 1 , 1)
                  Tci_line_num = Val(a_str)
                  A_str = Mid(a_resp , 2 , 2)
                  Tci_char_num = Val(a_str)
                  If Tci_line_num <= 4 And Tci_char_num <= 40 Then
                     Call Tci_set_lcd_pos(tci_line_num , Tci_char_num)
                     Call Print_ok
                  Else
                     Call Print_oor
                  End If

            Case "DB":                                        ' LCD back light

                  A_resp = Mid(s , 6 , 1)
                  If A_resp = "0" Or A_resp = "1" Then
                     A_num = Val(a_resp)
                     A_bit = 0
                     If A_num = 1 Then A_bit = 1
                     Call Tci_set_lcd_blight(a_bit)
                     Call Print_ok
                  Else
                     Call Print_oor
                  End If

            Case "DS":                                        ' LCD display data string

               A_num = Len(s)
               A_num = A_num - 5
               A_resp = Mid(s , 6 , A_num)
               A_num = Len(a_resp)
               If A_num <> 0 And A_num < 41 Then
                  For A_cnt = 1 To A_num
                     A_char = Mid(a_resp , A_cnt , 1)
                  Next A_cnt
                  Call Print_ok
               Else
                  Call Print_oor
               End If

            Case "ID":

               A_resp = Mid(s , 6 , 1)                        '
               If A_resp = "?" Then
                  A_str = "TCI-MATE v0.1"
                  Print "<" ; A_str ; ">"
                  Print
               Else
                  Call Print_ic                               ' invalid command
               End If

            Case "MR":                                        ' master reset

                  Call Tci_init
                  Call Print_ok

            Case Else

               Call Print_ic                                  ' invalid command

         End Select

      Else

         Call Print_ic                                        ' invalid command

      End If

Loop

End


Sub Go_send_dio

   A_str = "0000"
   A_char = "1"
   For A_cnt = 3 Downto 0
       If Tci_data.a_cnt = 1 Then Mid(a_str , A_cnt , 1) = A_char
   Next A_cnt
   Print "<" ; A_str ; ">"

End Sub


Sub Print_ic

   Print "><"
   Print

End Sub


Sub Print_oor

   Print ">>"
   Print

End Sub


Sub Print_ok

   Print "<>"
   Print

End Sub