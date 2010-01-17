
'---[ SofDioare License Agreement ]----------------------------------------------
'
' The sofDioare supplied herewith by OVERTON CLABORNE (OI) is intended and
' supplied to you for use solely and exclusively with products manufactured by
' OI.
'
' The sofDioare is owned by OI and/or a supplier, and is protected under
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
' File    : DIO-MATE INC.bas
' Version : 0.1
' Author  : Overton Claborne, OVERTON INSTRUMENTS
'


'---[ Program Description ]-----------------------------------------------------
'
' This is an INCLUDE file which is a standard component within TES-MATE.
' It comprizes a collection of service routines that are designed to support all
' boards in the Switching Solutions family, i.e., 4Wire-MATE, Mux-MATE, Relay-
' MATE, Matrix-MATE and Switch-MATE.
'

'---[ Compiler and Hardware related statements ]--------------------------------
'

$large
$default Xram


'---[ Variables ]---------------------------------------------------------------
'

Dim Dio_bit As Bit
Dim Dio_dev_sel As Byte
Dim Dio_reg_sel As Byte

Dim Dio_num As Byte
Dim Dio_byte As Byte
Dim Dio_data As Byte
Dim Dio_cnt As Byte
Dim Dio_funct_num As Byte
Dim Dio_port_num As Byte


'---[ Constants ]---------------------------------------------------------------
'
               ' Dio configuration registers

Dim Dio_iodir As Const 1
Dim Dio_ipol As Const 2
Dim Dio_gpinten As Const 3
Dim Dio_defval As Const 4
Dim Dio_intcon As Const 5
Dim Dio_iocon As Const 6
Dim Dio_gppu As Const 7
Dim Dio_intf As Const 8
Dim Dio_intcap As Const 9
Dim Dio_gpio As Const 10
Dim Dio_olat As Const 11


Dim Dio_iodir_a As Const &H00
Dim Dio_iodir_b As Const &H01
Dim Dio_ipol_a As Const &H02
Dim Dio_ipol_b As Const &H03
Dim Dio_gpinten_a As Const &H04
Dim Dio_gpinten_b As Const &H05
Dim Dio_defval_a As Const &H06
Dim Dio_defval_b As Const &H07
Dim Dio_intcon_a As Const &H08
Dim Dio_intcon_b As Const &H09
Dim Dio_iocon_a As Const &H0A
Dim Dio_iocon_b As Const &H0B
Dim Dio_gppu_a As Const &H0C
Dim Dio_gppu_b As Const &H0D
Dim Dio_intf_a As Const &H0E
Dim Dio_intf_b As Const &H0F
Dim Dio_intcap_a As Const &H10
Dim Dio_intcap_b As Const &H11
Dim Dio_gpio_a As Const &H12
Dim Dio_gpio_b As Const &H13
Dim Dio_olat_a As Const &H14
Dim Dio_olat_b As Const &H15

Dim Dio_opcode_0 As Const &H42
Dim Dio_opcode_1 As Const &H44
Dim Dio_opcode_2 As Const &H48

Dim Dio_function_a(11) As Byte
Dim Dio_function_b(11) As Byte



'---[ Initialization ]----------------------------------------------------------
'

Dio_function_a(1) = Dio_iodir_a
Dio_function_a(2) = Dio_ipol_a
Dio_function_a(3) = Dio_gpinten_a
Dio_function_a(4) = Dio_defval_a
Dio_function_a(5) = Dio_intcon_a
Dio_function_a(6) = Dio_iocon_a
Dio_function_a(7) = Dio_gppu_a
Dio_function_a(8) = Dio_intf_a
Dio_function_a(9) = Dio_intcap_a
Dio_function_a(10) = Dio_gpio_a
Dio_function_a(11) = Dio_olat_a

Dio_function_b(1) = Dio_iodir_b
Dio_function_b(2) = Dio_ipol_b
Dio_function_b(3) = Dio_gpinten_b
Dio_function_b(4) = Dio_defval_b
Dio_function_b(5) = Dio_intcon_b
Dio_function_b(6) = Dio_iocon_b
Dio_function_b(7) = Dio_gppu_b
Dio_function_b(8) = Dio_intf_b
Dio_function_b(9) = Dio_intcap_b
Dio_function_b(10) = Dio_gpio_b
Dio_function_b(11) = Dio_olat_b




'---[ Sub Routines ]------------------------------------------------------------
'
Declare Sub Dio_init
Declare Sub Dio_reset
Declare Sub Dio_wr(dio_port_num As Byte , Dio_funct_num As Byte , Dio_data As Byte)
Declare Sub Dio_rd(dio_port_num As Byte , Dio_funct_num As Byte , Dio_data As Byte)
Declare Sub Dio_tx(dio_reg_sel As Byte)
Declare Sub Dio_rx(dio_reg_sel As Byte)

Goto Skip_over_dio


Sub Dio_init

      ' initial DIO-MATE hardware

   Call Dio_reset                                             ' reset DIO-MATE

               ' set configuration registers
   Call Dio_wr(0 , &H0A , &H3C)
   Call Dio_wr(1 , &H0A , &H3C)
   Call Dio_wr(2 , &H0A , &H3C)


End Sub



Sub Dio_wr(dio_port_num As Byte , Dio_funct_num As Byte , Dio_data As Byte)

      ' write DIO port data

   If Dio_port_num = 0 Then

      Dio_dev_sel = 0
      Dio_reg_sel = Dio_function_a(dio_funct_num)

   Elseif Dio_port_num = 1 Then

      Dio_dev_sel = 0
      Dio_reg_sel = Dio_function_b(dio_funct_num)

   Elseif Dio_port_num = 2 Then

      Dio_dev_sel = 1
      Dio_reg_sel = Dio_function_a(dio_funct_num)

   Elseif Dio_port_num = 3 Then

      Dio_dev_sel = 1
      Dio_reg_sel = Dio_function_b(dio_funct_num)

   Elseif Dio_port_num = 4 Then

      Dio_dev_sel = 2
      Dio_reg_sel = Dio_function_a(dio_funct_num)

   Elseif Dio_port_num = 5 Then

      Dio_dev_sel = 2
      Dio_reg_sel = Dio_function_b(dio_funct_num)

   Else
   End If

   Set Sclk
   Delay

         ' chip select using alias port pin
   Reset Dio_cs

          ' enable chip select using 8255 port pin
   'Dio_byte = Inp(porta_addr)
   'Dio_byte.4 = 0
   'Out Porta_addr , Dio_byte

   Delay

         ' send opcode
   If Dio_dev_sel = 0 Then Call Dio_tx(dio_opcode_0)
   If Dio_dev_sel = 1 Then Call Dio_tx(dio_opcode_1)
   If Dio_dev_sel = 2 Then Call Dio_tx(dio_opcode_2)

         ' send reg select
   Call Dio_tx(dio_reg_sel)

         ' send byte
   Call Dio_tx(dio_data)

         ' disable chip select using alias port pin
   Set Dio_cs

         ' disable chip select using 8255 port pin
   'Dio_byte = Inp(porta_addr)
   'Dio_byte.4 = 1
   'Out Porta_addr , Dio_byte

End Sub


Sub Dio_rd(dio_port_num As Byte , Dio_funct_num As Byte , Dio_data As Byte)

      ' read DIO port data

   If Dio_port_num = 0 Then

      Dio_dev_sel = 0
      Dio_reg_sel = Dio_function_a(dio_funct_num)

   Elseif Dio_port_num = 1 Then

      Dio_dev_sel = 0
      Dio_reg_sel = Dio_function_b(dio_funct_num)

   Elseif Dio_port_num = 2 Then

      Dio_dev_sel = 1
      Dio_reg_sel = Dio_function_a(dio_funct_num)

   Elseif Dio_port_num = 3 Then

      Dio_dev_sel = 1
      Dio_reg_sel = Dio_function_b(dio_funct_num)

   Elseif Dio_port_num = 4 Then

      Dio_dev_sel = 2
      Dio_reg_sel = Dio_function_a(dio_funct_num)

   Elseif Dio_port_num = 5 Then

      Dio_dev_sel = 2
      Dio_reg_sel = Dio_function_b(dio_funct_num)

   Else
   End If

         ' condition device 0
   If Dio_dev_sel = 0 Then Dio_num = Dio_opcode_0

         ' condition device 1
   If Dio_dev_sel = 1 Then Dio_num = Dio_opcode_1

            ' condition device 2
   If Dio_dev_sel = 2 Then Dio_num = Dio_opcode_2

         ' set read condition
   Dio_num.0 = 1

   Set Sclk

         ' chip select using alias port pin
   Reset Dio_cs

          ' enable chip select using 8255 port pin
   'Dio_byte = Inp(porta_addr)
   'Dio_byte.4 = 0
   'Out Porta_addr , Dio_byte

   Delay

         ' send opcode
   Call Dio_tx(dio_num)

         ' send reg select
   Call Dio_tx(dio_reg_sel)

         ' receive byte
   Call Dio_rx(dio_data)

         ' disable chip select using alias port pin
   Set Dio_cs

         ' disable chip select using 8255 port pin
   'Dio_byte = Inp(porta_addr)
   'Dio_byte.4 = 1
   'Out Porta_addr , Dio_byte

End Sub


Sub Dio_tx(dio_byte As Byte)

      ' transmit serial data

   For Dio_cnt = 7 Downto 0
      Reset Sclk
      Delay
      Dout = Dio_byte.dio_cnt
      Set Sclk
      Delay
   Next Dio_cnt

End Sub


Sub Dio_rx(dio_byte As Byte)

      ' receive serial data

   For Dio_cnt = 7 Downto 0
      Reset Sclk
      Delay
      Set Sclk
      Delay
      Dio_byte.dio_cnt = Din
   Next Dio_cnt

End Sub


Sub Dio_reset

      ' reset DIO devices

   Reset Dio_rst
   Waitms 1
   Set Dio_rst

End Sub


Skip_over_dio: