/*------------------------------------------------------------------------------
TES-MATE.C

Copyright 2009 Overton Instruments, Inc.
------------------------------------------------------------------------------*/
#include <stdio.h>			/* define I/O functions */
#include "at89c51re2.h"		/* define 8051 registers */
#include "oidefs.h"			/* Overton Instruments definitions */

extern bit terminalPresent;


char continuityTest()
{
	char str[20];

	if( terminalPresent == TRUE )
		printf( "Continuity Test\n" );
	lcdSetDDRAMAddress( 0x00 );
	sprintf( str, "Continuity Test" );
	lcdWriteString( str );	
	lcdSetDDRAMAddress( 0x40 );
 	sprintf( str, " " );
	lcdWriteString( str );
	oneSecond();
	oneSecond();
	oneSecond();
	oneSecond();
	oneSecond();

	return TRUE;
}