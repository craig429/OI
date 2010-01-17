/*-------------------------------------------------------------------------
  Register Declarations for ATMEL 89x51 Processors    
  
   Written By - Bernd Bartmann 
    Bernd.Bartmann@picard.isdn.cs.tu-berlin.de (1999)
    based on reg51.h by Sandeep Dutta sandeep.dutta@usa.net
    KEIL C compatible definitions are included
    
   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
   
   In other words, you are welcome to use, share and improve this program.
   You are forbidden to forbid anyone else to use, share and improve
   what you give them.   Help stamp out software-hoarding!  
-------------------------------------------------------------------------*/

#ifndef AT89x51_H
#define AT89x51_H

/* BYTE addressable registers */
__sfr __at 0x80 P0;
__sfr __at 0x81 SP;
__sfr __at 0x82 DPL;
__sfr __at 0x83 DPH;
__sfr __at 0x87 PCON;
__sfr __at 0x88 TCON;
__sfr __at 0x89 TMOD;
__sfr __at 0x8A TL0;
__sfr __at 0x8B TL1;
__sfr __at 0x8C TH0;
__sfr __at 0x8D TH1;
__sfr __at 0x8E AUXR;
__sfr __at 0x8F CKCON0;
__sfr __at 0x90 P1;
__sfr __at 0x92 BMSEL;
__sfr __at 0x97 CKRL;
__sfr __at 0x98 SCON_0;
__sfr __at 0x99 SBUF_0;
__sfr __at 0x9A BRL_0;
__sfr __at 0x9B BDRCON_0;
__sfr __at 0x9C KBLS;
__sfr __at 0x9D KBE;
__sfr __at 0x9E KBF;
__sfr __at 0xA0 P2;
__sfr __at 0xA2 AUXR1;
__sfr __at 0xA6 WDTRST;
__sfr __at 0xA7 WDTPRG;
__sfr __at 0xA8 IEN0;
__sfr __at 0xA9 SADDR_0;
__sfr __at 0xAA SADDR_1;
__sfr __at 0xAF CKCON1;
__sfr __at 0xB0 P3;
__sfr __at 0xB1 IEN1;
__sfr __at 0xB2 IPL1;
__sfr __at 0xB3 IPH1;
__sfr __at 0xB7 IPH0;
__sfr __at 0xB8 IPL0;
__sfr __at 0xB9 SADEN_0;
__sfr __at 0xBA SADEN_1;
__sfr __at 0xBB BRL_1;
__sfr __at 0xBC BDRCON_1;
__sfr __at 0xC0 SCON_1;
__sfr __at 0xC1 SBUF_1;
__sfr __at 0xC3 SPCON;
__sfr __at 0xC4 SPSCR;
__sfr __at 0xC5 SPDAT;
__sfr __at 0xC8 T2CON;
__sfr __at 0xC9 T2MOD;
__sfr __at 0xCA RCAP2L;
__sfr __at 0xCB RCAP2H;
__sfr __at 0xCC TL2;
__sfr __at 0xCD TH2;
__sfr __at 0xD0 PSW;
__sfr __at 0xD1 FCON;
__sfr __at 0xD3 FSTA;
__sfr __at 0xD8 CCON;  
__sfr __at 0xD9 CMOD;
__sfr __at 0xDA CCAPM0;
__sfr __at 0xDB CCAPM1;
__sfr __at 0xDC CCAPM2;
__sfr __at 0xDD CCAPM3;
__sfr __at 0xDE CCAPM4;
__sfr __at 0xE0 ACC;
__sfr __at 0xE0 A;
__sfr __at 0xE8 P5;
__sfr __at 0xE9 CL;
__sfr __at 0xEA CCAP0L;
__sfr __at 0xEB CCAP1L;
__sfr __at 0xEC CCAP2L;
__sfr __at 0xED CCAP3L;
__sfr __at 0xEE CCAP4L;
__sfr __at 0xF0 B;
__sfr __at 0xF8 P6;
__sfr __at 0xF9 CH;
__sfr __at 0xFA CCAP0H;
__sfr __at 0xFB CCAP1H;
__sfr __at 0xFC CCAP2H;
__sfr __at 0xFD CCAP3H;
__sfr __at 0xFE CCAP4H;



/* BIT addressable registers */
/* P0 */
__sbit __at 0x80 P0_0;
__sbit __at 0x81 P0_1;
__sbit __at 0x82 P0_2;
__sbit __at 0x83 P0_3;
__sbit __at 0x84 P0_4;
__sbit __at 0x85 P0_5;
__sbit __at 0x86 P0_6;
__sbit __at 0x87 P0_7;

/* TCON */
__sbit __at 0x88 IT0;
__sbit __at 0x89 IE0;
__sbit __at 0x8A IT1;
__sbit __at 0x8B IE1;
__sbit __at 0x8C TR0;
__sbit __at 0x8D TF0;
__sbit __at 0x8E TR1;
__sbit __at 0x8F TF1;

/* P1 */
__sbit __at 0x90 P1_0;
__sbit __at 0x91 P1_1;
__sbit __at 0x92 P1_2;
__sbit __at 0x93 P1_3;
__sbit __at 0x94 P1_4;
__sbit __at 0x95 P1_5;
__sbit __at 0x96 P1_6;
__sbit __at 0x97 P1_7;

/* SCON */
__sbit __at 0x98 RI_0;
__sbit __at 0x99 TI_0;
__sbit __at 0x9A RB8_0;
__sbit __at 0x9B TB8_0;
__sbit __at 0x9C REN_0;
__sbit __at 0x9D SM2_0;
__sbit __at 0x9E SM1_0;
__sbit __at 0x9F SM0_0;

/* P2 */
__sbit __at 0xA0 P2_0;
__sbit __at 0xA1 P2_1;
__sbit __at 0xA2 P2_2;
__sbit __at 0xA3 P2_3;
__sbit __at 0xA4 P2_4;
__sbit __at 0xA5 P2_5;
__sbit __at 0xA6 P2_6;
__sbit __at 0xA7 P2_7;

/* IE */
__sbit __at 0xA8 EX0;
__sbit __at 0xA9 ET0;
__sbit __at 0xAA EX1;
__sbit __at 0xAB ET1;
__sbit __at 0xAC ES; 
__sbit __at 0xAD ET2;
__sbit __at 0xAE EC;
__sbit __at 0xAF EA;

/* P3 */
__sbit __at 0xB0 P3_0;
__sbit __at 0xB1 P3_1;
__sbit __at 0xB2 P3_2;
__sbit __at 0xB3 P3_3;
__sbit __at 0xB4 P3_4;
__sbit __at 0xB5 P3_5;
__sbit __at 0xB6 P3_6;
__sbit __at 0xB7 P3_7;

__sbit __at 0xB0 RXD;
__sbit __at 0xB1 TXD;
__sbit __at 0xB2 INT0;
__sbit __at 0xB3 INT1;
__sbit __at 0xB4 T0;
__sbit __at 0xB5 T1;
__sbit __at 0xB6 WR;
__sbit __at 0xB7 RD;

/* P4 */
__sbit __at 0xC0 XX4;
__sbit __at 0xC1 SM1_1;
__sbit __at 0xC2 SM2_1;
__sbit __at 0xC3 REN_1;
__sbit __at 0xC4 TB8_1;
__sbit __at 0xC5 RB8_1;
__sbit __at 0xC6 TI_1;
__sbit __at 0xC7 RI_1;


/* T2CON */
__sbit __at 0xC8 XXX1;
__sbit __at 0xC9 XXX2;
__sbit __at 0xCa TR2;
__sbit __at 0xCB EXEN2;
__sbit __at 0xCC TCLK;
__sbit __at 0xCD RCLK;
__sbit __at 0xCE EXF2;
__sbit __at 0xCF TF2;



/* IP */ 
__sbit __at 0xB8 PX0L;
__sbit __at 0xB9 PT0L;
__sbit __at 0xBA PX1L;
__sbit __at 0xBB PT1L;
__sbit __at 0xBC PSL; 
__sbit __at 0xBD PT2L;
__sbit __at 0xBE PPCL;

/* PSW */
__sbit __at 0xD0 PAR;
__sbit __at 0xD1 F1;
__sbit __at 0xD2 OV;
__sbit __at 0xD3 RS0;
__sbit __at 0xD4 RS1;
__sbit __at 0xD5 F0;
__sbit __at 0xD6 AC;
__sbit __at 0xD7 CY;

/* CCON */
__sbit __at 0xD8 CCF0;
__sbit __at 0xD9 CCF1;
__sbit __at 0xDA CCF2;
__sbit __at 0xDB CCF3;
__sbit __at 0xDC CCF4;
__sbit __at 0xDD XX3;
__sbit __at 0xDE CR;
__sbit __at 0xDF CF;


/* P5 */
__sbit __at 0xE0 P5_0;
__sbit __at 0xE1 P5_1;
__sbit __at 0xE2 P5_2;
__sbit __at 0xE3 P5_3;
__sbit __at 0xE4 P5_4;
__sbit __at 0xE5 P5_5;
__sbit __at 0xE6 P5_6;
__sbit __at 0xE7 P5_7;

/* P6 */
__sbit __at 0xF8 P6_0;
__sbit __at 0xF9 P6_1;


/* BIT definitions for bits that are not directly accessible */
/* PCON bits */
#define IDL             0x01
#define PD              0x02
#define GF0             0x04
#define GF1             0x08
#define SMOD            0x80

#define IDL_            0x01
#define PD_             0x02
#define GF0_            0x04
#define GF1_            0x08
#define SMOD_           0x80

/* TMOD bits */
#define M0_0            0x01
#define M1_0            0x02
#define C_T0            0x04
#define GATE0           0x08
#define M0_1            0x10
#define M1_1            0x20
#define C_T1            0x40
#define GATE1           0x80

#define M0_0_           0x01
#define M1_0_           0x02
#define C_T0_           0x04
#define GATE0_          0x08
#define M0_1_           0x10
#define M1_1_           0x20
#define C_T1_           0x40
#define GATE1_          0x80

#define T0_M0           0x01
#define T0_M1           0x02
#define T0_CT           0x04
#define T0_GATE         0x08
#define T1_M0           0x10
#define T1_M1           0x20
#define T1_CT           0x40
#define T1_GATE         0x80

#define T0_M0_          0x01
#define T0_M1_          0x02
#define T0_CT_          0x04
#define T0_GATE_        0x08
#define T1_M0_          0x10
#define T1_M1_          0x20
#define T1_CT_          0x40
#define T1_GATE_        0x80

#define T0_MASK         0x0F
#define T1_MASK         0xF0

#define T0_MASK_        0x0F
#define T1_MASK_        0xF0


/* Interrupt numbers: address = (number * 8) + 3 */
#define IE0_VECTOR      0       /* 0x03 external interrupt 0 */
#define TF0_VECTOR      1       /* 0x0b timer 0 */
#define IE1_VECTOR      2       /* 0x13 external interrupt 1 */
#define TF1_VECTOR      3       /* 0x1b timer 1 */
#define SI0_VECTOR      4       /* 0x23 serial port 0 */
 
#endif

