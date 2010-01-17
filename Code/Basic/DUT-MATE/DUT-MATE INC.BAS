

'---[ Software License Agreement ]----------------------------------------------
'
' The software supplied herewith by Overton Instruments (Oi) is intended and
' supplied to you for use solely and exclusively with products manufactured by
' Oi.
'
' The software is owned by Oi and/or a supplier, and is protected under
' applicable copyright laws.  All rights are reserved. Any use in violation of
' the foregoing restrictions may subject the user to criminal sanctions under
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
' File    : DUT-MATE INC.bas
' Version : 2.0 - designed for DUT-MATE version 5.0
' Author  : Overton Claborne, Oi
' Software; BASCOM-8051, MCS Electronics
'
'---[ Program Description ]-----------------------------------------------------
'
' This is an INCLUDE file which is a standard component within TES-MATE.
' It comprizes a collection of service routines that are designed to support the
' DUT-MATE, Device-Under-Test Power Switching Module, via the Oi-bus interface.
'

'---[ Compiler and Hardware related statements ]--------------------------------
'

$large
$default Xram


'---[ Variables ]---------------------------------------------------------------
'

Dim Dut_bit As Bit
Dim Dut_wr_cmd_reg As Word
Dim Dut_max_disc As Byte
Dim Dut_z As Word
Dim Dut_data As Byte
Dim Dut_reg_sel As Byte
Dim Dut_cnt As Byte
Dim Dut_byte As Byte
Dim Dut_word As Word
Dim Dut_model_num As Byte
Dim Dut_adc_val As Long
Dim Dut_dac_val As Word


'---[ Constants ]---------------------------------------------------------------
'
               ' DIO configuration registers

Dim Dut_iodir As Const &H00
Dim Dut_ipol As Const &H01
Dim Dut_gpinten As Const &H02
Dim Dut_defval As Const &H03
Dim Dut_intcon As Const &H04
Dim Dut_iocon As Const &H05
Dim Dut_gppu As Const &H06
Dim Dut_intf As Const &H07
Dim Dut_intcap As Const &H08
Dim Dut_gpio As Const &H09
Dim Dut_olat As Const &H10


Dim Dut_write As Const &H40
Dim Dut_read As Const &H41



'---[ Initialization ]----------------------------------------------------------
'

Dut_max_disc = 2                                              ' maximum discharge time in seconds
Dut_wr_cmd_reg = &H3000


'---[ Sub Routines ]------------------------------------------------------------
'

Declare Sub Dut_init
Declare Sub Dut_pwr_on
Declare Sub Dut_pwr_off
Declare Sub Dut_get_doc(dut_bit As Bit)
Declare Sub Dut_clr_oc
Declare Sub Dut_short(dut_bit As Bit)
Declare Sub Dut_rd_curmon(dut_adc_val As Long)
Declare Sub Dut_wr_ocb(dut_word As Word)
Declare Sub Dut_disc_rlyon
Declare Sub Dut_disc_rlyoff
Declare Sub Dut_wr_dio(dut_reg_sel As Byte , Dut_data As Byte)
Declare Sub Dut_rd_dio(dut_reg_sel As Byte , Dut_data As Byte)
Declare Sub Dut_tx(dut_byte As Byte)
Declare Sub Dut_rx(dut_byte As Byte)


Goto Skip_over_dut


Sub Dut_init

      ' initialize DUT-MATE hardware

               ' reset DIO chip
   Call Dut_reset

               ' set DIO configuration register
   Call Dut_wr_dio(dut_iocon , &H38)

               ' set DIO direction register
   Call Dut_wr_dio(dut_iodir , &H53)

               ' set DIO weak pull-ups
   Call Dut_wr_dio(dut_gppu , &H03)

               ' configure DIO
   Call Dut_wr_dio(dut_gpio , &HFF)

               ' get DUT-MATE model number
   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_model_num = Dut_data And &H03
   Incr Dut_model_num

               ' clear over-current condition
   Call Dut_clr_oc

               ' clear circuit breaker limit set-point
   Dut_word = &H0000
   Call Dut_wr_ocb(dut_word)

End Sub


Sub Dut_pwr_on

      ' enable DUT power

   'Call Dut_pwr_off
   'Call Dut_clr_oc
   'Call Dut_disc_rlyon
   'Waitms 100
   'Call Dut_disc_rlyoff
   'Waitms 100
   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_data.7 = 0
   Call Dut_wr_dio(dut_gpio , Dut_data)
   Waitms 100

End Sub


Sub Dut_pwr_off

      ' disable DUT power

   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_data.7 = 1
   Call Dut_wr_dio(dut_gpio , Dut_data)
   Waitms 100

End Sub


Sub Dut_get_doc(dut_bit As Bit)

      ' get DUT over-current status

   Call Dut_rd_dio(dut_gpio , Dut_data)
   If Dut_data.6 = 1 Then
      Dut_bit = 1
   Else
      Dut_bit = 0
   End If

End Sub


Sub Dut_clr_oc

      ' clear over-current

   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_data.5 = 0
   Call Dut_wr_dio(dut_gpio , Dut_data)
   Waitms 1
   Dut_data.5 = 1
   Call Dut_wr_dio(dut_gpio , Dut_data)
   Waitms 1

End Sub


Sub Dut_get_short(dut_bit As Bit)

      ' get short status

   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_data.2 = 0
   Call Dut_wr_dio(dut_gpio , Dut_data)
   Waitms 100
   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_bit = Dut_data.4
   Dut_data.2 = 1
   Call Dut_wr_dio(dut_gpio , Dut_data)
   Waitms 100

End Sub


Sub Dut_disc_rlyon

      ' enable discharge relay

   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_data.4 = 0
   Call Dut_wr_dio(dut_gpio , Dut_data)

End Sub


Sub Dut_disc_rlyoff

      ' disable discharge relay

   Call Dut_rd_dio(dut_gpio , Dut_data)
   Dut_data.4 = 1
   Call Dut_wr_dio(dut_gpio , Dut_data)

End Sub


Sub Dut_rd_curmon(dut_adc_val As Long)

      ' get DUT current reading

   Reset Sclk
   Dut_adc_val = 0

         ' check ready
   Do
      Reset Dut_adc_cs                                        ' enable device chip-select
      If Din = 0 Then Exit Do
      Set Dut_adc_cs
   Loop

         ' receive serial bit stream

   For Dut_cnt = 23 Downto 0
      Set Sclk
      Delay
      Dut_adc_val.dut_cnt = Din
      Reset Sclk
      Delay
   Next Dut_cnt
   Set Dut_adc_cs                                             ' disable device chip-select

End Sub


Sub Dut_wr_ocb(dut_word As Word)

      ' set over-current circuit breaker

   Reset Sclk
   Dut_dac_val = 0
   Dut_dac_val = Dut_wr_cmd_reg + Dut_word
   Reset Dut_dac_cs
   For Dut_cnt = 15 Downto 0                                  ' enable device chip-select
         ' Send serial bit stream
      Dout = Dut_dac_val.dut_cnt
      Set Sclk
      Delay
      Reset Sclk
      Delay
   Next Dut_cnt
   Set Dut_dac_cs                                             ' disable device chip-select

End Sub


'==============================================================================
'                           DIO Subroutines
'==============================================================================

Sub Dut_wr_dio(dut_reg_sel As Byte , Dut_data As Byte)

   Set Sclk
   Delay

         ' chip select enable
   Reset Dut_dio_cs
   Delay

        ' send opcode
   Call Dut_tx(dut_write)

         ' send reg select
   Call Dut_tx(dut_reg_sel)

         ' send byte
   Call Dut_tx(dut_data)

         ' disable chip select
   Set Dut_dio_cs

End Sub


Sub Dut_rd_dio(dut_reg_sel As Byte , Dut_data As Byte)


   Set Sclk
   Delay

         ' chip select enable
   Reset Dut_dio_cs
   Delay

         ' send opcode
   Call Dut_tx(dut_read)

         ' send reg select
   Call Dut_tx(dut_reg_sel)

         ' receive byte
   Call Dut_rx(dut_data)

         ' disable chip select
   Set Dut_dio_cs


End Sub


Sub Dut_tx(dut_byte As Byte)

      ' transmit dio data

   For Dut_cnt = 7 Downto 0
      Reset Sclk
      Delay
      Dout = Dut_byte.dut_cnt
      Set Sclk
      Delay
   Next Dut_cnt

End Sub


Sub Dut_rx(dut_byte As Byte)

      ' receive dio data

   For Dut_cnt = 7 Downto 0
      Reset Sclk
      Delay
      Set Sclk
      Delay
      Dut_byte.dut_cnt = Din
   Next Dut_cnt
   Dut_data = Dut_byte

End Sub


Sub Dut_reset

      ' reset dio device

   Reset Dut_rst
   Waitms 1
   Set Dut_rst

End Sub

Skip_over_dut: