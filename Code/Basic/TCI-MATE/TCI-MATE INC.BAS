

'---[ Software License Agreement ]----------------------------------------------
'
' The software supplied herewith by Overton Instruments (OI) is intended and
' supplied to you for use solely and exclusively with products manufactured by OI.
'
' The software is owned by OI and/or a supplier, and is protected under
' applicable copyright laws.  All rights are reserved.  Any use in violation
' of the foregoing restrictions may subject the user to criminal sanctions under
' laws, as well as to civil liability for the breach of the terms and conditions
' of this license.
'
' THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION.  NO WARRANTIES, WHETHER
' EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO
' THIS SOFTWARE.  OVERTON INSTRUMENTS SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE
' FOR SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.


'---[ Title ]-------------------------------------------------------------------
'
' File    : TCI-MATE INC.bas
' Version : 0.1
' Author  : Overton Claborne, OI
'


'---[ Program Description ]-----------------------------------------------------
'
' This is an INCLUDE file which is a standard component within TES-MATE.
' It comprizes a collection of service routines that are designed to support the
' TCI-MATE, Test Control Interface Module.
'

'---[ Compiler and Hardware related statements ]--------------------------------
'

$large
$default Xram


'---[ Variables ]---------------------------------------------------------------
'

Dim Tci_bit As Bit
Dim Tci_num As Byte
Dim Tci_byte As Byte
Dim Tci_data As Byte
Dim Tci_data_tmp As Byte
Dim Tci_cnt As Byte
Dim Tci_loop As Byte
Dim Tci_dev_sel As Byte
Dim Tci_reg_sel As Byte
Dim Tci_reg_val As Byte
Dim Tci_reg_addr As Byte
Dim Tci_char_num As Byte
dim Tci_line_num as byte
Dim Tci_word As Word

Dim Tci_char As String * 1
Dim Tci_str As String * 10
Dim Tci_str_tmp As String * 10
Dim Tci_xstr As String * 20

Dim Tci_lcd_sel As Byte
Dim Tci_lcd_dir As Bit
Dim Tci_lcd_ena As Bit
Dim Tci_lcd_disp As Bit
Dim Tci_lcd_curs As Bit
Dim Tci_lcd_blink As Bit
Dim Tci_lcd_font As Bit
Dim Tci_lcd_shift As Bit
Dim Tci_lcd_move As Bit
Dim Tci_lcd_sd As Bit
Dim Tci_lcd_addr As Byte



'---[ Constants ]---------------------------------------------------------------
'

Const Tci_wr = 0
Const Tci_rd = 1
Const Tci_off = 0
Const Tci_on = 1

            ' Digital I/O device registers - MCP23S08

Const Tci_iodir = &H00
Const Tci_ipol = &H01
Const Tci_gpinten = &H02
Const Tci_defval = &H03
Const Tci_intcon = &H04
Const Tci_iocon = &H05
Const Tci_gppu = &H06
Const Tci_intf = &H07
Const Tci_intcap = &H08
Const Tci_gpio = &H09
Const Tci_olat = &0A

            ' Digital I/O device registers - MCP23S17

Const Tci_iodir_a = &H00
Const Tci_iodir_b = &H01
Const Tci_ipol_a = &H02
Const Tci_ipol_b = &H03
Const Tci_gpinten_a = &H04
Const Tci_gpinten_b = &H05
Const Tci_defval_a = &H06
Const Tci_defval_b = &H07
Const Tci_intcon_a = &H08
Const Tci_intcon_b = &H09
Const Tci_iocon_a = &H0A
Const Tci_iocon_b = &H0B
Const Tci_gppu_a = &H0C
Const Tci_gppu_b = &H0D
Const Tci_intf_a = &H0E
Const Tci_intf_b = &H0F
Const Tci_intcap_a = &H10
Const Tci_intcap_b = &H11
Const Tci_gpio_a = &H12
Const Tci_gpio_b = &H13
Const Tci_olat_a = &H14
Const Tci_olat_b = &H15

               ' Digital I/O device addresses

Const Tci_opcode_0 = &H40                                     ' LCD Interface
Const Tci_opcode_1 = &H42                                     ' Thumbwheel Sw's
Const Tci_opcode_2 = &H44                                     ' Status LED's
Const Tci_opcode_3 = &H46                                     ' LCD Select

               ' RTC Constants

Dim Tci_sec_reg As Const &H00
Dim Tci_min_reg As Const &H01
Dim Tci_hour_reg As Const &H02
Dim Tci_day_reg As Const &H03
Dim Tci_date_reg As Const &H04
Dim Tci_month_reg As Const &H05
Dim Tci_year_reg As Const &H06
Dim Tci_sec_alarm As Const &H07
Dim Tci_min_alarm As Const &H08
Dim Tci_hour_alarm As Const &H09


'---[ Sub Routines ]------------------------------------------------------------
'
Declare Sub Tci_init

            ' Front Panel support

Declare Sub Tci_chk_start(tci_bit As Bit)
Declare Sub Tci_chk_stop(tci_bit As Bit)
Declare Sub Tci_chk_fixture_ready(tci_bit As Bit)
Declare Sub Tci_chk_dut_present(tci_bit As Bit)
Declare Sub Tci_run_led(tci_bit As Bit)
Declare Sub Tci_pass_led(tci_bit As Bit)
Declare Sub Tci_fail_led(tci_bit As Bit)
Declare Sub Tci_buzzer(tci_bit As Bit)
Declare Sub Tci_get_tw(tci_byte)
Declare Sub Tci_wr_dio(tci_dev_sel As Byte , Tci_reg_sel As Byte , Tci_data As Byte)
Declare Sub Tci_rd_dio(tci_dev_sel As Byte , Tci_reg_sel As Byte , Tci_data As Byte)
Declare Sub Tci_tx(tci_byte As Byte)
Declare Sub Tci_rx(tci_byte As Byte)

            ' Real-Time Clock

Declare Sub Tci_rtc_wr(tci_reg_addr As Byte , Tci_reg_val As Byte)
Declare Sub Tci_rtc_rd(tci_reg_addr As Byte , Tci_reg_val As Byte)
Declare Sub Tci_rtc_time(tci_bit As Bit , Tci_str As String)
Declare Sub Tci_rtc_date(tci_bit As Bit , Tci_str As String)

            ' CHAR LCD

Declare Sub Tci_lcd_busy(tci_data As Byte)
Declare Sub Tci_lcd_clr
Declare Sub Tci_lcd_home
Declare Sub Tci_set_lcd_mode
Declare Sub Tci_set_lcd_function
Declare Sub Tci_set_lcd_disp
Declare Sub Tci_lcd_drive_e(tci_data As Byte)
Declare Sub Tci_go_lcd(tci_data As Byte)

            ' AUX DIO

Declare Sub Tci_auxdio_dir(tci_bit As Bit , Tci_data As Byte)
Declare Sub Tci_auxdio_ppu(tci_bit As Bit , Tci_data As Byte)
Declare Sub Tci_auxdio_data(tci_bit As Bit , Tci_data As Byte)

Goto Skip_tci

'---[ Initialization ]----------------------------------------------------------

Sub Tci_init

                ' set dio device configuration
   Call Tci_wr_dio(0 , Tci_iocon_a , &H38)
   Call Tci_wr_dio(0 , Tci_iocon_b , &H38)
   Call Tci_wr_dio(1 , Tci_iocon , &H38)
   Call Tci_wr_dio(2 , Tci_iocon , &H38)
   Call Tci_wr_dio(3 , Tci_iocon , &H38)

               ' set i/o direction
   Call Tci_wr_dio(1 , Tci_iodir , &H0F)
   Call Tci_wr_dio(2 , Tci_iodir , &H00)
   Call Tci_wr_dio(3 , Tci_iodir , &HFF)

               ' set weak pull-up resister
   Call Tci_wr_dio(1 , Tci_gppu , &H0F)
   Call Tci_wr_dio(2 , Tci_gppu , &HFF)
   Call Tci_wr_dio(3 , Tci_gppu , &HFF)

               ' turn-off leds and buzzer
   Call Tci_wr_dio(1 , Tci_gpio , &HFF)

               ' configure LCD
   Call Tci_rd_dio(3 , Tci_gpio , Tci_data)                   ' Read LCD selector switch
   Shift Tci_data , Right , 4
   Tci_lcd_sel = Tci_data
   If Tci_data = 0 Then Exit Sub                              ' No LCD display
   Call Tci_wr_dio(0 , Tci_iodir_a , &HFF)                    ' Port A, LDC data bus
   Call Tci_wr_dio(0 , Tci_iodir_b , &H00)                    ' Port B, LDC control bits
   Call Tci_rd_dio(0 , Tci_gpio_b , &HF8)                     ' Set base command
   Tci_lcd_dir = 1
   Tci_lcd_ena = 1
   Tci_lcd_disp = 1
   Tci_lcd_curs = 0
   Tci_lcd_blink = 0
   Tci_lcd_font = 0
   Tci_lcd_shift = 0
   Tci_lcd_move = 0
   Tci_lcd_sd = 0
   Call Tci_set_lcd_function                                  ' Set functions
   Call Tci_set_lcd_entry                                     ' Set mode
   Call Tci_set_lcd_disp                                      ' Set display options
   Call Tci_set_lcd_cursor

End Sub



'******************************************************************************
'*      Front Panel support subroutines                                       *
'******************************************************************************
'

Sub Tci_chk_start(tci_bit As Bit)

      ' get start bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   Tci_bit = Tci_data.3

End Sub


Sub Tci_chk_stop(tci_bit As Bit)

      ' get stop bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   Tci_bit = Tci_data.2

End Sub


Sub Tci_chk_fixture_ready(tci_bit As Bit)

      ' get fixture ready bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   Tci_bit = Tci_data.1

End Sub


Sub Tci_chk_dut_present(tci_bit As Bit)

      ' get dut present bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   Tci_bit = Tci_data.0

End Sub


Sub Tci_run_led(tci_bit As Bit)

      ' set run led bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   If Tci_bit = Tci_on Then Tci_data.6 = 0
   If Tci_bit = Tci_off Then Tci_data.6 = 1
   Call Tci_wr_dio(2 , Tci_gpio , Tci_data)

End Sub


Sub Tci_pass_led(tci_bit As Bit)

      ' set pass led bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   If Tci_bit = Tci_on Then Tci_data.5 = 0
   If Tci_bit = Tci_off Then Tci_data.5 = 1
   Call Tci_wr_dio(2 , Tci_gpio , Tci_data)

End Sub


Sub Tci_fail_led(tci_bit As Bit)

      ' set pass led bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   If Tci_bit = Tci_on Then Tci_data.4 = 0
   If Tci_bit = Tci_off Then Tci_data.4 = 1
   Call Tci_wr_dio(2 , Tci_gpio , Tci_data)

End Sub


Sub Tci_buzzer(tci_bit As Bit)

      ' set buzzer bit

   Call Tci_rd_dio(2 , Tci_gpio , Tci_data)
   If Tci_bit = Tci_on Then Tci_data.7 = 0
   If Tci_bit = Tci_off Then Tci_data.7 = 1
   Call Tci_wr_dio(2 , Tci_gpio , Tci_data)

End Sub


Sub Tci_get_tw(tci_byte As Byte)

      ' get thumbwheel setting

   Call Tci_rd_dio(1 , Tci_gpio , Tci_byte)

End Sub


'******************************************************************************
'*      CHAR related LCD subroutines                                          *
'******************************************************************************
'

Sub Tci_set_lcd_blight(tci_bit As Bit)

      ' Configure back light

   Call Tci_chk_lcd_busy
   Call Tci_rd_dio(0 , Tci_gpio_b , Tci_data)                 ' Rd LCd Control bits
   If Tci_bit = 0 Then Tci_data.6 = 0                         ' back light off
   If Tci_bit = 1 Then Tci_data.6 = 1                         ' back light on
   Call Tci_wr_dio(0 , Tci_gpio_a , Tci_data)                 ' Wr LCD data

End Sub


Sub Tci_wr_lcd_char(tci_char As String)

      ' Byte write

   Call Tci_chk_lcd_busy
   Tci_data = Asc(tci_char)
   Call Tci_wr_dio(0 , Tci_gpio_a , Tci_data)                 ' Wr LCD data
   Call Tci_rd_dio(0 , Tci_gpio_b , Tci_data)                 ' Rd LCd Control bits
   Tci_data = Tci_data And &HF8                               ' Mask control bits
   Tci_data.0 = 1                                             ' wr char
   Call Tci_lcd_drive_e(tci_data)                             ' Toggle E signal

End Sub


Sub Tci_set_lcd_pos(tci_line_num As Byte , Tci_char_num As Byte)

         ' Position cursor on display

   Decr Tci_char_num
   If Tci_lcd_sel <= 2 Then                                   ' 1x16 or 1x20

      Tci_data = &H80

   Elseif Tci_lcd_sel = 3 Or Tci_lcd_sel = 4 Then             ' 2x20 or 2x24

      If Tci_line_num = 1 Then Tci_data = &H80
      If Tci_line_num = 2 Then Tci_data = &HC0
      Tci_data = Tci_data + Tci_char_num

   Elseif Tci_lcd_sel = 5 Then                                ' 4x16

      If Tci_line_num = 1 Then Tci_data = &H80
      If Tci_line_num = 2 Then Tci_data = &HC0
      If Tci_line_num = 3 Then Tci_data = &H90
      If Tci_line_num = 4 Then Tci_data = &HD0

   Elseif Tci_lcd_sel = 6 Then                                ' 4x20

      If Tci_line_num = 1 Then Tci_data = &H80
      If Tci_line_num = 2 Then Tci_data = &HC0
      If Tci_line_num = 3 Then Tci_data = &H94
      If Tci_line_num = 4 Then Tci_data = &HD4

   End If

   Tci_data = Tci_data + Tci_char_num
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_set_lcd_disp

      ' Configure display

   Call Tci_chk_lcd_busy
   Tci_data = &H08                                            ' Select base command
   Tci_data.0 = Tci_lcd_blink                                 ' Set cursor blink
   Tci_data.1 = Tci_lcd_curs                                  ' Cursor On/Off
   Tci_data.2 = Tci_lcd_ena                                   ' Display On/Off
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_set_lcd_entry

      ' Configure entry mode

   Call Tci_chk_lcd_busy
   Tci_data = &H04                                            ' Select base command
   Tci_data.0 = Tci_lcd_shift                                 ' Shift on/off
   Tci_data.1 = Tci_lcd_dir                                   ' Cursor direction
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_set_lcd_cursor

      ' Configure cursor/display shift

   Call Tci_chk_lcd_busy
   Tci_data = &H10                                            ' Select base command
   Tci_data.2 = Tci_lcd_sd                                    ' Shift direction
   Tci_data.3 = Tci_lcd_move                                  ' Move cursor
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_set_lcd_function

      ' Configure function set

   Call Tci_chk_lcd_busy
   Tci_data = &H30                                            ' Select base command
   If Tci_lcd_sel > 4 Then Tci_data.3 = 1                     ' Select 1 or multiple line display
   If Tci_lcd_font = 1 Then Tci_data.2 = 1                    ' Select font
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_lcd_clr

      ' Clear LCD

   Call Tci_chk_lcd_busy
   Tci_data = &H01
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_lcd_home

      ' Send cursor to Home position

   Call Tci_chk_lcd_busy
   Tci_data = &H02
   Call Tci_go_lcd(tci_data)

End Sub


Sub Tci_go_lcd(tci_data As Byte)

      ' Update display

   Call Tci_wr_dio(0 , Tci_gpio_a , Tci_data)                 ' Wr LCD data
   Call Tci_rd_dio(0 , Tci_gpio_b , Tci_data)                 ' Rd LCd Control bits
   Tci_data = Tci_data And &HF8                               ' Mask control bits
   Call Tci_lcd_drive_e(tci_data)                             ' Toggle E signal

End Sub


Sub Tci_chk_lcd_busy

      ' Check busy status

   Call Tci_wr_dio(0 , Tci_iodir_a , &H00)                    ' Change bus direction to read
   Call Tci_rd_dio(0 , Tci_gpio_b , Tci_data)                 ' Rd LCD control bits
   Tci_data_tmp = Tci_data And &HFA                           ' Mask control bits
   Call Tci_wr_dio(0 , Tci_gpio_b , Tci_data_tmp)             ' Wr control bits
   Delay
   Do
      Tci_data_tmp.2 = 1                                      ' Set E to 1
      Call Tci_wr_dio(0 , Tci_gpio_b , Tci_data_tmp)
      Delay
      Call Tci_rd_dio(0 , Tci_gpio_a , Tci_data)              ' Rd LCD busy bit
      Tci_lcd_addr = Tci_data And &H7F
      Tci_data = Tci_data And &H80
      Tci_data_tmp.2 = 0                                      ' Reset E to 0
      Call Tci_wr_dio(0 , Tci_gpio_b , Tci_data_tmp)
      Delay
   Loop Until Tci_data = 0                                    ' Exit when not busy
   Call Tci_wr_dio(0 , Tci_iodir_a , &HFF)                    ' Change bus direction to write

End Sub


Sub Tci_lcd_drive_e(tci_data As Byte)

      ' Seal the deal

   For Tci_loop = 0 To 2
      If Tci_loop = 1 Then Tci_data.2 = 1                     ' Set E to 1
      If Tci_loop = 2 Then Tci_data.2 = 0                     ' Reset E to 0
      Call Tci_wr_dio(0 , Tci_gpio_b , Tci_data)              ' Wr control bits
      Delay
   Next Tci_loop

End Sub


'******************************************************************************
'*      RTC related subroutines                                               *
'******************************************************************************
'

Sub Tci_rtc_ampm(tci_bit As Bit , Tci_str As String)

   Call Tci_rtc_rd(tci_hour_reg , Tci_reg_val)
   If Tci_bit = Tci_rd Then
      If Tci_reg_val.5 = True Then Tci_str = "PM"
      If Tci_reg_val.5 = False Then Tci_str = "AM"
   Else
      If Tci_str = "PM" Then
         Tci_reg_val.5 = 1
         Tci_reg_val.6 = 1
      End If
      If Tci_str = "AM" Then
         Tci_reg_val.5 = 0
         Tci_reg_val.6 = 1
      End If
      Call Tci_rtc_wr(tci_hour_reg , Tci_reg_val)
   End If

End Sub


Sub Tci_rtc_time(tci_bit As Bit , Tci_str As String)

   If Tci_bit = Tci_rd Then                                   ' read time

      For Tci_num = 1 To 5

         If Tci_num = 1 Then Call Tci_rtc_rd(tci_hour_reg , Tci_reg_val)
         If Tci_num = 3 Then Call Tci_rtc_rd(tci_min_reg , Tci_reg_val)
         If Tci_num = 5 Then Call Tci_rtc_rd(tci_sec_reg , Tci_reg_val)

         If Tci_num <> 2 And Tci_num <> 4 Then
            If Tci_reg_val < 10 Then
               Tci_str_tmp = "0" + Str(tci_reg_val)
            Else
               Tci_str_tmp = Str(tci_reg_val)
            End If
         Else
            Tci_str_tmp = ":"
         End If

         If Tci_num = 1 Then Mid(tci_str , 1 , 2) = Tci_str_tmp
         If Tci_num = 2 Then Mid(tci_str , 3 , 1) = Tci_str_tmp
         If Tci_num = 3 Then Mid(tci_str , 4 , 2) = Tci_str_tmp
         If Tci_num = 4 Then Mid(tci_str , 6 , 1) = Tci_str_tmp
         If Tci_num = 5 Then Mid(tci_str , 7 , 2) = Tci_str_tmp

      Next Tci_num

   Else                                                       ' write time

      For Tci_num = 1 To 3

         If Tci_num = 1 Then Tci_str_tmp = Mid(tci_str , 1 , 2)
         If Tci_num = 2 Then Tci_str_tmp = Mid(tci_str , 4 , 2)
         If Tci_num = 3 Then Tci_str_tmp = Mid(tci_str , 7 , 2)

         Tci_reg_val = Val(tci_str_tmp)
         If Tci_num = 2 Or Tci_num = 3 Then
            If Tci_reg_val > 59 Then Tci_str = "--------"
         Else
            If Tci_reg_val > 12 Then Tci_str = "--------"
         End If
         If Tci_str = "--------" Then Exit Sub                ' wrong value

         If Tci_num = 1 Then Call Tci_rtc_wr(tci_hour_reg , Tci_reg_val)
         If Tci_num = 2 Then Call Tci_rtc_wr(tci_min_reg , Tci_reg_val)
         If Tci_num = 3 Then Call Tci_rtc_wr(tci_sec_reg , Tci_reg_val)

      Next Tci_num

   End If

End Sub


Sub Tci_rtc_date(tci_bit As Bit , Tci_str As String)

   If Tci_num = Tci_rd Then                                   ' read date

      For Tci_num = 1 To 5

         If Tci_num = 1 Then Call Tci_rtc_rd(tci_month_reg , Tci_reg_val)
         If Tci_num = 3 Then Call Tci_rtc_rd(tci_date_reg , Tci_reg_val)
         If Tci_num = 5 Then Call Tci_rtc_rd(tci_year_reg , Tci_reg_val)

         If Tci_num <> 2 And Tci_num <> 4 Then
            If Tci_reg_val < 10 Then
               Tci_str_tmp = "0" + Str(tci_reg_val)
            Else
               Tci_str_tmp = Str(tci_reg_val)
            End If
         Else
            Tci_str_tmp = "/"
         End If

         If Tci_num = 1 Then Mid(tci_str , 1 , 2) = Tci_str_tmp
         If Tci_num = 2 Then Mid(tci_str , 3 , 1) = Tci_str_tmp
         If Tci_num = 3 Then Mid(tci_str , 4 , 2) = Tci_str_tmp
         If Tci_num = 4 Then Mid(tci_str , 6 , 1) = Tci_str_tmp
         If Tci_num = 5 Then Mid(tci_str , 7 , 2) = Tci_str_tmp

      Next Tci_num

   Else                                                       ' write date

      For Tci_num = 1 To 3

         If Tci_num = 1 Then Tci_str_tmp = Mid(tci_str , 1 , 2)
         If Tci_num = 2 Then Tci_str_tmp = Mid(tci_str , 4 , 2)
         If Tci_num = 3 Then Tci_str_tmp = Mid(tci_str , 7 , 2)

         Tci_reg_val = Val(tci_str_tmp)
         If Tci_num = 1 And Tci_reg_val > 13 Then Tci_str = "--------"
         If Tci_num = 2 And Tci_reg_val > 31 Then Tci_str = "--------"
         If Tci_num = 3 And Tci_reg_val > 99 Then Tci_str = "--------"
         If Tci_str = "--------" Then Exit Sub                ' wrong value

         If Tci_num = 1 Then Call Tci_rtc_wr(tci_month_reg , Tci_reg_val)
         If Tci_num = 2 Then Call Tci_rtc_wr(tci_date_reg , Tci_reg_val)
         If Tci_num = 3 Then Call Tci_rtc_wr(tci_year_reg , Tci_reg_val)

      Next Tci_num

   End If

End Sub


Sub Tci_rtc_wr(tci_reg_addr As Byte , Tci_reg_val As Byte)

   Tci_word = 0
   If Tci_reg_addr <= &H0F Then Tci_reg_val = Makebcd(tci_reg_val)
   Tci_word = Tci_reg_addr + &H80
   Shift Tci_word , Left , 8
   Tci_word = Tci_word + Tci_reg_val                          ' get lsb
   Set Sclk
   Delay
   Set Tci_rtc_cs
   Delay                                                      ' chip select
   For Tci_cnt = 15 Downto 0                                  ' write serial data
      Reset Sclk
      Delay
      Dout = Tci_word.tci_cnt
      Set Sclk
      Delay
   Next Tci_cnt
   Reset Tci_rtc_cs                                           ' chip de-select

End Sub


Sub Tci_rtc_rd(tci_reg_addr As Byte , Tci_reg_val As Byte)

   Tci_word = 0
   Tci_word = Tci_reg_addr                                    ' get msb
   Shift Tci_word , Left , 8
   Set Sclk
   Delay
   Set Tci_rtc_cs
   Delay                                                      ' chip select
   For Tci_cnt = 15 Downto 0                                  ' read serial data
      Reset Sclk
      Delay
      If Tci_cnt > 7 Then Dout = Tci_word.tci_cnt
      If Tci_cnt < 8 Then Tci_reg_val.tci_cnt = Din
      Set Sclk
      Delay
   Next Tci_cnt
   Reset Tci_rtc_cs
   If Tci_reg_addr <= &H0F Then Tci_reg_val = Makedec(tci_reg_val)

End Sub


'******************************************************************************
'*      AUX. DIO bits                                                         *
'******************************************************************************


Sub Tci_auxdio_dir(tci_bit As Bit , Tci_data As Byte)

               ' configure I/O direction

   Tci_data_tmp = Tci_data
   Call Tci_rd_dio(3 , Tci_iodir , Tci_data)
   If Tci_bit = 1 Then Exit Sub
   Tci_data = Tci_data And &HF0
   Tci_data = Tci_data Or Tci_data_tmp
   Call Tci_wr_dio(3 , Tci_iodir , Tci_data)

End Sub


Sub Tci_auxdio_pup(tci_bit As Bit , Tci_data As Byte)

               ' configure weak pull-ups

   Tci_data_tmp = Tci_data
   Call Tci_rd_dio(3 , Tci_gppu , Tci_data)
   If Tci_bit = 1 Then Exit Sub
   Tci_data = Tci_data And &HF0
   Tci_data = Tci_data Or Tci_data_tmp
   Call Tci_wr_dio(3 , Tci_gppu , Tci_data)

End Sub


Sub Tci_auxdio_data(tci_bit As Bit , Tci_data As Byte)

               ' write I/O bits

   Tci_data_tmp = Tci_data
   Call Tci_rd_dio(3 , Tci_gpio , Tci_data)
   If Tci_bit = 1 Then Exit Sub
   Tci_data = Tci_data And &HF0
   Tci_data = Tci_data Or Tci_data_tmp
   Call Tci_wr_dio(3 , Tci_gpio , Tci_data)

End Sub


'******************************************************************************
'*      DIO low-level support subroutines                                     *
'******************************************************************************
'

Sub Tci_wr_dio(tci_dev_sel As Bit , Tci_reg_sel As Byte , Tci_data As Byte)

         ' condition device 0
   If Tci_dev_sel = 0 Then Tci_byte = Tci_opcode_0

         ' condition device 1
   If Tci_dev_sel = 1 Then Tci_byte = Tci_opcode_1

         ' condition device 2
   If Tci_dev_sel = 2 Then Tci_byte = Tci_opcode_2

         ' condition device 3
   If Tci_dev_sel = 3 Then Tci_byte = Tci_opcode_3

         ' chip select enable
   Reset Tci_dio_cs

         ' send opcode
   Call Tci_tx(tci_byte)

         ' send reg select
   Call Tci_tx(tci_reg_sel)

         ' send data
   Call Tci_tx(tci_data)

         ' disable chip select
   Set Tci_dio_cs

End Sub


Sub Tci_rd_dio(tci_dev_sel As Bit , Tci_reg_sel As Byte , Tci_data As Byte)

         ' condition device 0
   If Tci_dev_sel = 0 Then Tci_byte = Tci_opcode_0

         ' condition device 1
   If Tci_dev_sel = 1 Then Tci_byte = Tci_opcode_1

         ' condition device 2
   If Tci_dev_sel = 0 Then Tci_byte = Tci_opcode_2

         ' condition device 3
   If Tci_dev_sel = 1 Then Tci_byte = Tci_opcode_3

         ' set read condition
   Incr Tci_byte

         ' chip select enable
   Reset Tci_dio_cs

         ' send opcode
   Call Tci_tx(tci_byte)

         ' send reg select
   Call Tci_tx(tci_reg_sel)

         ' receive data
   Call Tci_rx(tci_data)

         ' disable chip select
   Set Tci_dio_cs

End Sub


Sub Tci_tx(tci_byte As Byte)

   Set Sclk

   For Tci_cnt = 7 Downto 0
      Reset Sclk
      Dout = Tci_byte.tci_cnt                                 ' Transmit serial data
      Set Sclk
   Next Tci_cnt

End Sub


Sub Tci_rx(tci_byte As Byte)

   Set Sclk

   For Tci_cnt = 7 Downto 0
      Reset Sclk
      Set Sclk
      Tci_data.tci_cnt = Din                                  ' Receive serial data
   Next Tci_cnt

End Sub


Skip_tci: