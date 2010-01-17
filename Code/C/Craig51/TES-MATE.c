/*------------------------------------------------------------------------------
TES-MATE.C

Copyright 2009 Overton Instruments, Inc.
------------------------------------------------------------------------------*/
#include <stdio.h>			/* define I/O functions */
#include "at89c51re2.h"		/* define 8051 registers */
#include "oidefs.h"			/* Overton Instruments definitions */

extern bit LCD_DISPLAY_BIT; 
extern bit LCD_CURSOR_BIT; 
extern bit LCD_BLINK_BIT;

bit irq0;
bit terminalPresent;
bit nextUnit;
volatile bit startButton;
volatile bit stopButton;
volatile bit dutPresent;
volatile bit fixtureReady; 

xdata int timer0Count;
xdata int messageCount;
volatile xdata unsigned int irqCount;
xdata int toggle;
xdata unsigned char lcdString[32];
xdata unsigned char inBuf[16];
xdata unsigned char inIndex;
xdata unsigned char outIndex;
xdata unsigned char testMode;
xdata unsigned char testSelect;

void main (void) 
{
	char temp;
	char str[20];
	int i;
 
	for( i=0; i < 32; i++ ) lcdString[i] = 0x20;
	timer0Count = messageCount = i = 0;
	irqCount = 0;
	toggle = FALSE;
	P0_0 = 0;
	inIndex = outIndex = 0;
	terminalPresent = TRUE;

	systemInit();

	// These next 5 instructions should init trhe chip after power up
	// according to datasheet page 45 - Initializing by instruction.
	// Except the SetDDRAM instruction, but I can't get anything going
	// without it (!!!)
	lcdSetDDRAMAddress( 0x00 );	// Why do I need this before lcdinit()?
	lcdInit();					// Send 3 Function Set commands
	lcdSetFunction();			// Now the real Function Set
	lcdDisplayOnOff( OFF );		// etc.
	lcdClearDisplay();

	// LCD should now be initialized
	lcdSetEntryMode( 1, 0 );	// Cursor position increment, no dsiplay shift
	lcdDisplayOnOff( ON );
	lcdCursorOnOff( OFF );
	lcdBlinkOnOff( OFF );

	startInterrupts();

	lcdSetDDRAMAddress( 0x00 );
	sprintf( str, "   EMBEEDED TEST" );
	lcdWriteString( str );	
	lcdSetDDRAMAddress( 0x40 );
	sprintf( str, "     powered by:" );
	lcdWriteString( str );

	oneSecond();
	oneSecond();
	oneSecond();
	lcdSetDDRAMAddress( 0x00 );
	sprintf( str, "Overton Instruments" );
	lcdWriteString( str );	
	lcdSetDDRAMAddress( 0x40 );
 	sprintf( str, "** OI - microATE **" );
	lcdWriteString( str );

	oneSecond();
	oneSecond();
	oneSecond();
	
	temp = readThumbwheels();
	testMode = temp & 0xf0;
	testMode >>= 4;
	testMode &= 0x0f;
	testSelect = temp & 0x0f;
	
	if( ( testMode == 9 ) && ( testSelect == 9 ) )
	{
		// Run system configuration menu
		// Call System_config_menu 
		printf( "System Config Menu\n" );	
	}	

	nextUnit = FALSE;
	if( terminalPresent == TRUE )
	{
		printf( "NDS Test Fixture, Code Ver: %s\n", VERSION );
	}

	lcdClearDisplay();
	startButton = FALSE;
	stopButton = FALSE;
	fixtureReady = FALSE;
	dutPresent = FALSE;
	lcdSetDDRAMAddress( 0x00 );
	lcdWriteString( "Install DUT and" );
	lcdSetDDRAMAddress( 0x40 );
	lcdWriteString( "press Start" );

	oneSecond();
	oneSecond();
	oneSecond();

	while(1)
 	{
		if( ( startButton == TRUE ) && ( stopButton == FALSE ) )
		{
			if( ( fixtureReady == TRUE ) && ( dutPresent == TRUE ) )
			{
				printf( "Present and Ready\n" );
				if( continuityTest() == TRUE )
				{
					lcdSetDDRAMAddress( 0x40 );
					lcdWriteString( "      PASSED!" );
				}
				else
				{
					lcdSetDDRAMAddress( 0x40 );
					lcdWriteString( "         FAIL" );
				}
				startButton = FALSE;
				fixtureReady = FALSE;
				dutPresent = FALSE;
			}
			else
			{
				runLEDOnOff( ON );
				passLEDOnOff( ON );
				failLEDOnOff( ON );
				oneSecond();
				runLEDOnOff( OFF );
				passLEDOnOff( OFF );
				failLEDOnOff( OFF );
				oneSecond();
			}
		}

		// Reset IRQ if port pin has gone high again
		if( ( irq0 == TRUE ) && ( P3_2 == ON ) )
		{
			ext0Enable();
			irq0 = FALSE;
		}
 	}
}

void int0( void ) interrupt 0 using 1
{
	char temp;
	ext0Disable();
	irq0 = ON;
	temp = readDUTPort();
//	printf ( "INT0 Interrupt:%x\n", temp );
	if( !( temp & DUT_PRESENT ) )
		dutPresent = TRUE,printf ( "DUT Present\n" );		
	if( !( temp & FIXTURE_READY ) )
		fixtureReady = TRUE,printf ( "Fixture Ready\n" );
	if( !( temp & DUT_STOP ) )
		stopButton = TRUE,printf ( "DUT Stop\n" );
	if( !( temp & DUT_START ) )
		startButton = TRUE,printf ( "DUT Start\n" );}

void timer0( void ) interrupt 1 using 1
{
	if( timer0Count++ > 188 )
	{
//		sprintf( lcdString, "      %02d:%02d:%02d", readRTCHours(), readRTCMinutes(), readRTCSeconds() );
//  		lcdSetDDRAMAddress( 0x40 );
//		lcdWriteString( lcdString );	
		timer0Count = 0;
		irqCount++;

		if( toggle == FALSE ) toggle = TRUE, annunciatorOnOff( ON );
		else toggle = FALSE, annunciatorOnOff( OFF );
	}
}

void delay( void)
{
	int i,j;
	for(j=0; j < 10; j++ )for(i=0; i < 10000; i++ );
}

void uart0( void ) interrupt 4 using 1
{
	P0_0 = 1;
	if( RI_0 )
	{
		inBuf[(++inIndex) & 0xf] = SBUF_0;		// Read in the byte
		RI_0 = 0;						// Clear receive interrupt bit
	}
	if( SM0_0 )
	{
		SM0_0 &= 0;						// Clear Framing Error bit
	}
	P0_0 = 0;
}

void spi( void ) interrupt 9 using 1
{
//		printf ( "SPI Interrupt\n" );
}

void oneSecond( void)
{
	irqCount = 0;
	while( irqCount < 1 );
}





