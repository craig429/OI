/*------------------------------------------------------------------------------
TES-MATE.C

Copyright 2009 Overton Instruments, Inc.
------------------------------------------------------------------------------*/
#include <stdio.h>			/* define I/O functions */
#include "at89c51re2.h"		/* define 8051 registers */
#include "oidefs.h"			/* Overton Instruments definitions */

extern volatile unsigned int irqCount;

void writeRTCControl( char input )
{
	char temp;
	P1_0 = 1; 
	SPDAT = 0x8f;		/* control register write address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = input;		/* write out control word */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	P1_0 = 0;
}

char readRTCSeconds( void )
{
	char temp, tens, secs;
	P1_0 = 1; 
	SPDAT = 0x00;		/* seconds read address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = 0x00;		/* dummy write to shift in result */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	temp = SPDAT;
	P1_0 = 0;
	secs = temp &0xf;
	tens = temp & 0xf0;
	tens >>= 4;
	temp = tens*10 + secs;
	return temp;
}

char readRTCMinutes( void )
{
	char temp, tens, mins;
	P1_0 = 1; 
	SPDAT = 0x01;		/* seconds read address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = 0x00;		/* dummy write to shift in result */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	temp = SPDAT;
	P1_0 = 0;
	mins = temp &0xf;
	tens = temp & 0xf0;
	tens >>= 4;
	temp = tens*10 + mins;
	return temp;
}

void writeRTCMinutes( char mins )
{
	char temp, temp1, temp2;
	RTC_CS = 1; 
	SPDAT = 0x81;		/* seconds read address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	temp1 = mins/10;
	temp2 = mins - temp1*10;
	temp1 <<= 4;
	temp1 |= temp2;
	SPDAT = temp1;		/* dummy write to shift in result */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	RTC_CS = 0;
}

char readRTCHours( void )
{
	char temp, hours;
	RTC_CS = 1; 
	SPDAT = 0x02;		/* seconds read address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = 0x00;		/* dummy write to shift in result */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	temp = SPDAT;
	RTC_CS = 0;
	hours = temp & 0xf;
	temp >>=4;
	hours += temp*10;
	return hours;
}

 void writeRTCHours( char hours )
{
	char temp;
	RTC_CS = 1; 
	SPDAT = 0x82;		/* seconds read address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	if( hours >= 20 )
		{
		temp = hours - 20;
		temp |= 0x30;
		printf ( "temp11: %x\n", temp );
		}
	else if( hours >= 10 )
		{
		temp = hours - 10;
		temp |= 0x10;
		printf ( "temp12: %x\n", temp );
		}
	else
		{
		temp = hours;
 //		temp |= 0x40;
		printf ( "temp31: %x\n", temp );
		}
	printf ( "Hours Pattern: %x\n", temp );
	SPDAT = temp;		/* dummy write to shift in result */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	RTC_CS = 0;
}

//void oneSecond( void)
//{
//	irqCount = 0;
//	while( irqCount < 1 );
//}

