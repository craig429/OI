
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
' File    : DAQ-MATE INC.bas
' Version : 0.1
' Author  : Overton Claborne, OI
' Software; BASCOM-8051, MCS Electronics
'
'---[ Program Description ]-----------------------------------------------------
'
' This is an INCLUDE file which is a standard component within TES-MATE.
' It comprizes a collection of service routines that are designed to support the
' DAQ-MATE, 32-CH Data Acquisition Module

'---[ Compiler and Hardware related statements ]--------------------------------
'

$large
$default Xram


'---[ Variables ]---------------------------------------------------------------
'

Dim Daq_bit As Bit
Dim Daq_mode As Byte
Dim Daq_pol As Byte
Dim Daq_dev_sel As Byte
Dim Daq_reg_sel As Byte

Dim Daq_dev As Byte
Dim Daq_num As Byte
Dim Daq_byte As Byte
Dim Daq_data As Byte
Dim Daq_cnt As Byte
Dim Daq_cnt_2 As Byte
Dim Daq_ch As Byte
Dim Daq_cntl_byte As Byte
Dim Daq_range As Byte
Dim Daq_m_cnts As Byte

Dim Daq_val As Word
Dim Daq_word As Word
Dim Daq_long As Long

Dim Daq_range_buf(4) As Byte
'Dim Daq_range_buf_d(16) As Byte
Dim Daq_ch_buf(8) As Byte
Dim Daq_ch_buf_d(4) As Byte

Dim Daq_conf_code As String * 5



'---[ Constants ]---------------------------------------------------------------
'

               ' ADC related

Dim Daq_adc_5v5v As Const &B00000000
Dim Daq_adc_5v As Const &B00001000
Dim Daq_adc_10v10v As Const &B00000100
Dim Daq_adc_10v As Const &B00001100


'---[ Initialization ]----------------------------------------------------------
'

Daq_m_cnts = 1

Daq_ch_buf(1) = &B10000000                                    ' single ended
Daq_ch_buf(2) = &B10010000
Daq_ch_buf(3) = &B10100000
Daq_ch_buf(4) = &B10110000
Daq_ch_buf(5) = &B11000000
Daq_ch_buf(6) = &B11010000
Daq_ch_buf(7) = &B11100000
Daq_ch_buf(8) = &B11110000

Daq_ch_buf_d(1) = &B00000000                                  ' differential inputs
Daq_ch_buf_d(2) = &B00010000
Daq_ch_buf_d(3) = &B00100000
Daq_ch_buf_d(4) = &B00110000

Daq_range_buf(1) = Daq_adc_5v
Daq_range_buf(2) = Daq_adc_5v5v
Daq_range_buf(3) = Daq_adc_10v
Daq_range_buf(4) = Daq_adc_10v10v

'---[ Sub Routines ]------------------------------------------------------------
'
Declare Sub Daq_init

Declare Sub Daq_rd_adc(daq_val As Word , Daq_ch As Byte , Daq_mode As Byte , Daq_pol As Byte , Daq_range As Byte)


Goto Skip_over_daq


Sub Daq_init

      ' initialize DAQ-MATE hardware

               ' select ch-0 and set ADC for 0-5V range

   For Daq_cnt = 1 To 32
      Daq_range_buf(daq_cnt) = 1
   Next Daq_cnt
   Daq_ch = &B10000000
   Daq_range = Daq_adc_5v
   Call Daq_rd_adc(daq_val , Daq_ch , Daq_range)
   Daq_conf_code = "01S01"
   Daq_mode = 1
   Daq_pol = 0

End Sub


'==============================================================================
'                           ADC Subroutine
'==============================================================================

Sub Daq_rd_adc(daq_val As Word , Daq_ch As Byte , Daq_mode As Byte , Daq_pol As Byte , Daq_range As Byte)

      ' configure analog channel and read voltage

     Daq_long = 0

                  ' Select analog channel

      If Daq_ch < 9 Then
         Daq_dev = 0
      Elseif Daq_ch => 9 And Daq_ch <= 16 Then
         Daq_num = Daq_ch - 8
         Daq_dev = 1
      Elseif Daq_ch => 17 And Daq_ch <= 24 Then
         Daq_num = Daq_ch - 16
         Daq_dev = 2
      Elseif Daq_ch => 25 And Daq_ch <= 32 Then
         Daq_num = Daq_ch - 24
         Daq_dev = 3
      End If

      If Daq_mode = 1 Then
         Daq_ch = Daq_ch_buf(daq_num)                         ' configure SE
      Else
         Daq_ch = Daq_ch_buf_d(daq_num)                       ' configure Differential
         If Daq_pol = 0 Then Daq_ch.6 = 0                     ' configure +/- Polarity
         If Daq_pol = 1 Then Daq_ch.6 = 1                     ' configure -/+ Polarity
      End If

      Daq_range = Daq_range_buf(daq_range)                    ' configure Range
      Daq_cntl_byte = Daq_range Or Daq_ch                     ' configure Control Byte

      Reset Sclk
      Delay

                  ' take X measurements
      For Daq_cnt = 1 To Daq_m_cnts
         Daq_word = 0

                  ' check busy flag
         While Daq_adc_busy = 0
         Wend

               ' assert low using alias port pin
         If Daq_dev = 0 Then Reset Daq_adc_cs0
         If Daq_dev = 1 Then Reset Daq_adc_cs1
         If Daq_dev = 2 Then Reset Daq_adc_cs2
         If Daq_dev = 3 Then Reset Daq_adc_cs3

         For Daq_cnt = 15 Downto 0
                     ' transmit serial data
            If Daq_cnt >= 8 Then
               Daq_num = Daq_cnt - 8
               Dout = Daq_cntl_byte.daq_num
            End If
            Set Sclk
            Delay
            'Daq_word = Din
            'Delay
            Reset Sclk
         Next Daq_cnt

            ' assert high using alias port pin
         Set Daq_adc_cs0
         Set Daq_adc_cs1
         Set Daq_adc_cs2
         Set Daq_adc_cs3

                  ' check busy flag
         While Daq_adc_busy = 0
         Wend

               ' assert low using alias port pin
         If Daq_dev = 0 Then Reset Daq_adc_cs0
         If Daq_dev = 1 Then Reset Daq_adc_cs1
         If Daq_dev = 2 Then Reset Daq_adc_cs2
         If Daq_dev = 3 Then Reset Daq_adc_cs3

         For Daq_cnt = 15 Downto 0
                     ' receive serial data
            If Daq_cnt >= 8 Then
               Daq_num = Daq_cnt - 8
               Dout = 1
            End If
            Set Sclk
            Delay
            Daq_word = Din
            Delay
            Reset Sclk
         Next Daq_cnt

            ' assert high using alias port pin
         Set Daq_adc_cs0
         Set Daq_adc_cs1
         Set Daq_adc_cs2
         Set Daq_adc_cs3

                     ' scale results

      'If Daq_range = Daq_adc_5v Then Daq_adc_tmp = 5.0 / 4096
      'If Daq_range = Daq_adc_10v Then Daq_adc_tmp = 10.0 / 4096
      'Daq_adc_tmp = Daq_adc_tmp * Daq_adc
         Daq_long = Daq_long + Daq_word
      'Waitms 1
     Next Daq_cnt
                     ' compute average
     Daq_val = Daq_long / Daq_m_cnts

End Sub


Skip_over_daq: