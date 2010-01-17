
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
' File    :Check-MATE INC.bas
' Version : 0.1
' Author  : Overton Claborne, OI
' Software; BASCOM-8051, MCS Electronics
'
'---[ Program Description ]-----------------------------------------------------
'
' This is an INCLUDE file which is a standard component within TES-MATE.
' It comprizes a collection of service routines that are designed to support the
' Check-MATE, Multifunction DAQ Module
'

'---[ Compiler and Hardware related statements ]--------------------------------
'

$large
$default Xram


'---[ Variables ]---------------------------------------------------------------
'

Dim Chk_bit As Bit
Dim Chk_mux_mode As Bit
Dim Chk_mux_pol As Bit
Dim Chk_dev_sel As Byte
Dim Chk_reg_sel As Byte
Dim Chk_dac_range As Bit

Dim Chk_num As Byte
Dim Chk_num_2 As Byte
Dim Chk_byte As Byte
Dim Chk_data As Byte
Dim Chk_cnt As Byte
Dim Chk_cnt_2 As Byte
Dim Chk_loop As Byte
Dim Chk_ch As Byte
Dim Chk_ch_tmp As Byte
Dim Chk_range_tmp As Byte
Dim Chk_cntl_byte As Byte
Dim Chk_range As Byte
Dim Chk_m_cnts As Byte
Dim Chk_long As Long

Dim Chk_mode As Byte
Dim Chk_pol As Byte
Dim Chk_val As Word

Dim Chk_dac_word As Word

Dim Chk_word As Word

Dim Chk_range_buf(4) As Byte
'Dim Chk_range_buf_d(4) As Byte
Dim Chk_ch_buf(8) As Byte
Dim Chk_ch_buf_d(4) As Byte
Dim Chk_conf_code As String * 4


'---[ Constants ]---------------------------------------------------------------
'


               ' DIO configuration registers

Dim Chk_iodir As Const &H00
Dim Chk_ipol As Const &H01
Dim Chk_gpinten As Const &H02
Dim Chk_defval As Const &H03
Dim Chk_intcon As Const &H04
Dim Chk_iocon As Const &H05
Dim Chk_gppu As Const &H06
Dim Chk_intf As Const &H07
Dim Chk_intcap As Const &H08
Dim Chk_gpio As Const &H09
Dim Chk_olat As Const &H10


Dim Chk_write As Const &H40
Dim Chk_read As Const &H41

               ' ADC related

Dim Chk_adc_5v5v As Const &B00000000
Dim Chk_adc_5v As Const &B00001000
Dim Chk_adc_10v10v As Const &B00000100
Dim Chk_adc_10v As Const &B00001100



'---[ Initialization ]----------------------------------------------------------
'

Chk_ch_buf(1) = &B10000000                                    ' single ended
Chk_ch_buf(2) = &B10010000
Chk_ch_buf(3) = &B10100000
Chk_ch_buf(4) = &B10110000
Chk_ch_buf(5) = &B11000000
Chk_ch_buf(6) = &B11010000
Chk_ch_buf(7) = &B11100000
Chk_ch_buf(8) = &B11110000

Chk_ch_buf_d(1) = &B00000000                                  ' differential ended
Chk_ch_buf_d(2) = &B00010000
Chk_ch_buf_d(3) = &B00100000
Chk_ch_buf_d(4) = &B00110000

Chk_range_buf(1) = Chk_adc_5v
Chk_range_buf(2) = Chk_adc_5v5v
Chk_range_buf(3) = Chk_adc_10v
Chk_range_buf(4) = Chk_adc_10v10v

'---[ Sub Routines ]------------------------------------------------------------
'
Declare Sub Chk_init
Declare Sub Chk_reset
Declare Sub Chk_wr_dio(chk_reg_sel As Byte , Chk_data As Byte)
Declare Sub Chk_rd_dio(chk_reg_sel As Byte , Chk_data As Byte)
Declare Sub Chk_tx(chk_byte As Byte)
Declare Sub Chk_rx(chk_byte As Byte)
Declare Sub Chk_rd_adc(chk_val As Word , Chk_ch As Byte , Chk_mode As Byte , Chk_pol As Byte , Chk_range As Byte)
Declare Sub Chk_wr_dac(chk_dac_word As Word)
Declare Sub Chk_dac_mode(chk_bit As Bit)

Goto Skip_chk


Sub Chk_init

   Chk_m_cnts = 1

               ' set DIO configuration register
   Call Chk_wr_dio(chk_iocon , &H38)

               ' Set to unipolar mode and zero the DAC
   Chk_dac_range = 1
   Call Chk_dac_mode(chk_dac_range)
   Chk_dac_word = 0
   Call Chk_wr_dac(chk_dac_word)


               ' select ch-1 and set ADC for 0-5V range

   Chk_ch = 1
   Chk_range = 1
   Chk_mode = 1
   Chk_pol = 0
   Call Chk_rd_adc(chk_val , Chk_ch , Chk_mode , Chk_pol , Chk_range)

End Sub


'==============================================================================
'                           DIO Subroutines
'==============================================================================

Sub Chk_wr_dio(chk_reg_sel As Byte , Chk_data As Byte)

   Set Sclk
   Delay

         ' chip select enable
   Reset Dio_cs
   Delay

        ' send opcode
   Call Chk_tx(chk_write)

         ' send reg select
   Call Chk_tx(chk_reg_sel)

         ' send byte
   Call Chk_tx(chk_data)

         ' disable chip select
   Set Dio_cs

End Sub


Sub Chk_rd_dio(chk_reg_sel As Byte , Chk_data As Byte)


   Set Sclk
   Delay

         ' chip select enable
   Reset Dio_cs
   Delay

         ' send opcode
   Call Chk_tx(chk_read)

         ' send reg select
   Call Chk_tx(chk_reg_sel)

         ' receive byte
   Call Chk_rx(chk_data)

         ' disable chip select
   Set Dio_cs


End Sub


Sub Chk_tx(chk_byte As Byte)

   For Chk_cnt = 7 Downto 0
      Reset Sclk
      Delay
      Dout = Chk_byte.chk_cnt
      Set Sclk
      Delay
   Next Chk_cnt

End Sub


Sub Chk_rx(chk_byte As Byte)

   For Chk_cnt = 7 Downto 0
      Reset Sclk
      Delay
      Set Sclk
      Delay
      Chk_byte.chk_cnt = Din
   Next Chk_cnt
   Chk_data = Chk_byte

End Sub


Sub Chk_reset

   'Reset Chk_rst
   'Waitms 1
   'Set Chk_rst

End Sub



'==============================================================================
'                           ADC Subroutine
'==============================================================================

Sub Chk_rd_adc(chk_val As Word , Chk_ch As Byte , Chk_mode As Byte , Chk_pol As Byte , Chk_range As Byte)


     Chk_long = 0

     If Chk_mode = 1 Then
        Chk_ch = Chk_ch_buf(chk_ch)                           ' configure SE
     Else
        Chk_ch = Chk_ch_buf_d(chk_ch)                         ' configure Differential
        If Chk_pol = 0 Then Chk_num.6 = 0                     ' configure Polarity
        If Chk_pol = 1 Then Chk_num.6 = 1                     ' configure Polarity
     End If

     Chk_range = Chk_range_buf(chk_range)                     ' configure Range
     Chk_cntl_byte = Chk_range Or Chk_ch                      ' configure Control Byte

                  ' Select analog channel
     Chk_cntl_byte = Chk_range Or Chk_ch

     Reset Sclk
     Delay

                  ' take X measurements
     For Chk_loop = 0 To Chk_m_cnts
         Chk_word = 0

                  ' check busy flag
         While Adc_busy = 0
         Wend

                     ' Select device
         Reset Adc_cs
         Delay
         For Chk_cnt = 15 Downto 0
                     ' transmit serial data
            If Chk_cnt >= 8 Then
               Chk_num = Chk_cnt - 8
               Dout = Chk_cntl_byte.chk_num
            End If
            Set Sclk
            'Delay
            'Chk_word = Din
            Delay
            Reset Sclk
         Next Chk_cnt

           ' disable device
         Set Adc_cs
         Delay

                  ' check busy flag
         While Adc_busy = 0
         Wend

                     ' Select device
         Reset Adc_cs
         Delay

         For Chk_cnt = 15 Downto 0
                     ' receive serial data
            If Chk_cnt >= 8 Then
               Chk_num = Chk_cnt - 8
               Dout = Chk_cntl_byte.chk_num
            End If
            Set Sclk
            Delay
            Chk_word = Din
            Delay
            Reset Sclk
         Next Chk_cnt

           ' disable device
         Set Adc_cs

         If Chk_loop > 0 Then Chk_long = Chk_long + Chk_word

     Next Chk_loop
                     ' compute average
     Chk_long = Chk_long / Chk_m_cnts

     Chk_val = Loww(chk_long)

End Sub


'==============================================================================
'                           DAC Subroutines
'==============================================================================

Sub Chk_wr_dac(chk_dac_word As Word)

   Chk_dac_word = Chk_dac_word Or &H4000
   'Chk_dac_word = &H800 Or &H4000
   Reset Sclk
   Delay
   Reset Dac_cs
   Delay
   For Chk_cnt = 15 Downto 0
      Dout = Chk_dac_word.chk_cnt
      Set Sclk
      Delay
      Reset Sclk
      Delay
   Next Chk_cnt
   Set Dac_cs
   Chk_dac_word = Chk_dac_word And &H0FFF

End Sub


Sub Chk_dac_mode(chk_bit As Bit)

   If Chk_bit = 0 Then Reset Uni_bip                          ' bipolar
   If Chk_bit = 1 Then Set Uni_bip                            ' unipolar

End Sub


Skip_chk: