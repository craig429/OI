/*------------------------------------------------------------------------------
TES-MATE.C

Copyright 2009 Overton Instruments, Inc.
------------------------------------------------------------------------------*/
#include <stdio.h>			/* define I/O functions */
#include <string.h>			/* define I/O functions */
#include "at89c51re2.h"		/* define 8051 registers */
#include "oidefs.h"			/* Overton Instruments definitions */

extern unsigned int irqCount;

bit LCD_DISPLAY_BIT;
bit LCD_CURSOR_BIT;
bit LCD_BLINK_BIT;
	
xdata char globalDisplayControl;

void lcdInit( void )
{
	int j;

	irqCount = 0;
	delay();

	globalDisplayControl = 0;

	//Set mode: 8 bit, 2 line, 5x8 font
	for( j=0; j < 4; j++ )
	{
		write16Buffer( IODIRA,0x00 );	// Port A Output
		write16Buffer( OLATA,0x38 );	// 8 bit, 2 line, 5x8
		write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
		write16Buffer( OLATB,0x04 );	// RS=0, R/W=0, E=1
		write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
		irqCount = 0;
		delay();
	}
}
		
void lcdSetFunction( void )
{
	char temp = 0x80;

	//Set mode: 8 bit, 2 line, 5x8 font
	write16Buffer( IODIRA,0x00 );	// Port A Output
	write16Buffer( OLATA,0x38 );	// 8 bit, 2 line, 5x8
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB,0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}
		
void lcdDisplayOnOff( char OnOff )
{
	char temp = 0x80;
	char ttemp=0x8;
	if( OnOff == ON )
		{
 		ttemp |= 0x4;
		LCD_DISPLAY_BIT = 1;
 		}	
	if( LCD_CURSOR_BIT == ON )
 		ttemp |= 0x2;
	if( LCD_BLINK_BIT == ON )
 		ttemp |= 0x1;

	write16Buffer( IODIRA,0x00 );	// Port A Output
	write16Buffer( OLATA,ttemp  );	// 
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB,0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}

void lcdCursorOnOff( char OnOff )
{
	char temp = 0x80;
	char ttemp=0x8;
	if( OnOff == ON )
		{
 		ttemp |= 0x2;
		LCD_CURSOR_BIT = 1;
 		}	
	if( LCD_DISPLAY_BIT == ON )
 		ttemp |= 0x4;
	if( LCD_BLINK_BIT == ON )
 		ttemp |= 0x1;

	write16Buffer( IODIRA,0x00 );	// Port A Output
	write16Buffer( OLATA,ttemp  );	// 
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB,0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}

void lcdBlinkOnOff( char OnOff )
{
	char temp = 0x80;
	char ttemp=0x8;
	if( OnOff == ON )
		{
 		ttemp |= 0x1;
		LCD_BLINK_BIT = 1;
 		}	
	if( LCD_DISPLAY_BIT == ON )
 		ttemp |= 0x4;
	if( LCD_CURSOR_BIT == ON )
 		ttemp |= 0x2;

	write16Buffer( IODIRA,0x00 );	// Port A Output
	write16Buffer( OLATA,ttemp  );	// 
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB,0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}

void lcdSetEntryMode( char increment, char shift )
{
	char temp = 0x80;
	char ttemp = 0x40;
	if( increment )
		ttemp |= 0x2;	
	if( shift )
		ttemp |= 0x1;
	write16Buffer( IODIRA, 0x00 );	// Port A Output
	write16Buffer( OLATA, ttemp );	// 
	write16Buffer( OLATB, 0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB, 0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB, 0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}

void lcdWriteString( char *str )
{
	int i,temp;
	
	if( strlen( str ) > 20 )
		temp = 20;
	else
		temp = strlen( str );
	for( i=0; i < temp; i++ )
		lcdWrite( *(str + i ) );
	for( i=temp; i < 20; i++ )
		lcdWrite( ' ' );
		
}

void lcdWrite( char symbol )
{
	char temp=0x80;
	write16Buffer( IODIRA, 0x00 );	// Port A Output
	write16Buffer( OLATA, symbol );	// Write H
	write16Buffer( OLATB, 0x01 );	// RS=1, R/W=0, E=0
	write16Buffer( OLATB, 0x05 );	// RS=1, R/W=0, E=1
	write16Buffer( OLATB, 0x01 );	// RS=1, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}

void lcdSetDDRAMAddress( char address )
{
	char temp = 0x80;
	address &= 0xef;				// address in lower 7 bits
	address |= 0x80;				// set command bit
	write16Buffer( IODIRA, 0x00 );	// Port A Output
	write16Buffer( OLATA, address );	// Write address
	write16Buffer( OLATB, 0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB, 0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB, 0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}

void lcdClearDisplay( void )
{
	char temp = 0x80;
	write16Buffer( IODIRA,0x00 );	// Port A Output
	write16Buffer( OLATA,0x01 );	// Clear display, DDRAM AC=0
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( OLATB,0x04 );	// RS=0, R/W=0, E=1
	write16Buffer( OLATB,0x00 );	// RS=0, R/W=0, E=0
	write16Buffer( IODIRA,0xff );	// Port A Input
	while( ( temp & 0x80 ) == 0x80 )
	{
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
		write16Buffer( OLATB,0x06 );	// RS=0, R/W=1, E=1
		temp = read16Buffer( GPIOA );
		write16Buffer( OLATB,0x02 );	// RS=0, R/W=1, E=0
	}
}
