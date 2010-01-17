/*------------------------------------------------------------------------------
TES-MATE.C

Copyright 2009 Overton Instruments, Inc.
------------------------------------------------------------------------------*/
#include <stdio.h>			/* define I/O functions */
#include "at89c51re2.h"		/* define 8051 registers */
#include "oidefs.h"			/* Overton Instruments definitions */

void systemInit( void )
{
	char temp;
	
	CKCON0 = 0xFE;	/* Use 12 Clock */
	TH1 =  0xfb;	/* 9600 baud @ 18.432 MHz xtal */
	TL1 =  0xfb;	/* TL1 */
	TMOD = 0x20;	/* TMOD */
	TI_0 = 1;		/* */
	TR1 = 1;

	TR0 = 0;		/* Set Timer 0 to Hold */

	/* TMOD */
	/* 18.432 MHz / 12 / 1FFF = 188 Hz */
	TH0 = 0xff;		/* Upper 8 bits of Timer 0 */
	TL0 = 0x1f;		/* Lower 5 bits of Timer 0 */
	temp = TMOD;
	temp &= ~8;		/* Ignore external interrupt */
	temp &= ~4;		/* Timer mode */
	TMOD = temp;

	/* PCON */
	PCON = 0x10;	/* SMOD1_0 low, SMOD0_0 low (p106) */

	/* SCON_0 (p101) */
	SM0_0 = 0;
	SM1_0 = 1;
	REN_0 = 1;

	/* PCON */
	PCON = 0x50;	/* SMOD1_0 low, SMOD0_0 high (p106) */
	
	/* IEN0 */
	EX0 = 1;		/* External INT0 enable */
	ET0 = 1;		/* Timer 0 interrupt enable */
	ES = 1;			/* UART 0 interrupt enable */

	/* IPL0, IPH0 */
	PX0L = 1;		/* Timer 0 interrupt priority 2 */
	PT0L = 1;		/* Timer 0 interrupt priority 3 */
	IPH0 |= 1;

	/* IEN1 */
//	temp = 4;		/* ESPI high */
//	IEN1 = temp;

	/* IPL1, IPH1 */
	IPL1 = 4;		/* SPI interrupt priority not so high */
	IPH1 = 0;		/* SPI interrupt priority not so high */

	/* SPCON */
	temp = 0x75;	/* 0XXXXX01 = FCLK/4 */
					/* SPEN high */
					/* SSDIS high */
					/* MSTR high */
					/* CPOL low */
					/* CPHA high */
	SPCON = temp;

	/* SPSCR */
	temp = 2;		/* SPTEIE high */
	SPSCR = temp;

	// Initialize Real Time Clock
 	writeRTCControl(4);
//	writeRTCHours( 12 );
//	writeRTCMinutes( 16 );

	// Initialize patrallel ports
	write16Buffer( IOCON,0x88 );						// Bank enabled, INT mirror NC
														// seq enabled, slew enabled	
														// HAEN enabled, INT active drive	
														// INT active drive, INTPOL low	
	write16Buffer( GPPUA,0xff );						// Port A pullup 
	write16Buffer( GPPUB,0xff );						// Port B pullup
	write16Buffer( IODIRA,0x00 );						// Port A Output
	write16Buffer( IODIRB,0x00 );						// Port B Output

	write8Buffer( DUT_PORT, IOCON, 0x3c );				// sequential disabled, slew disabled,
														// hardware address enabled,
														// irq active drive, irq polarity low
	write8Buffer( DUT_PORT, GPPU, 0xff );				// Internal pullup 
	write8Buffer( DUT_PORT, IODIR, 0xc6 );				// Bit 0 - Audio annunmciator (output)
														// Bit 1 - DUT Presesent (input)
														// Bit 2 - Fixture ready (input)
														// Bit 3 - DUT fail (output)
														// Bit 4 - DUT pass (output)
														// Bit 5 - DUT run (output)
														// Bit 6 - DUT start (input)
														// Bit 7 - DUT stop (input)
	write8Buffer( DUT_PORT, GPINTEN, 0xc6 );			// Interrupt on bits 1,2,6,7
	write8Buffer( DUT_PORT, DEFVAL, 0xc6 );				// Default values are high
	write8Buffer( DUT_PORT, INTCON, 0xc6 );				// Compare to DEFVAL

	write8Buffer( THUMBWHEEL_PORT, IOCON, 0x3c );		// sequential disabled, slew disabled,
														// hardware address enabled,
														// irq active drive, irq polarity low
	write8Buffer( THUMBWHEEL_PORT, GPPU, 0xff );		// Internal pullup 
	write8Buffer( THUMBWHEEL_PORT, IODIR, 0xff );		// Bits 0-3 - Test mode thumbwheel (input)
														// Bits 4-7 - Test select thumbwheel (input)

	write8Buffer( AUX_PORT, IOCON, 0x3c );				// sequential disabled, slew disabled,
														// hardware address enabled,
														// irq active drive, irq polarity low
	write8Buffer( AUX_PORT, GPPU, 0xff );				// Internal pullup 
	write8Buffer( AUX_PORT, IODIR, 0xff );				// Bits 0-3 - Aux inputs (input)
														// Bits 4-7 - LCD module select (input)}
}

void startInterrupts( void )
{
	EA = 1;			/* Global interrupt enable */
	TR0 = 1;		/* Set Timer 0 to Run */
}

char readThumbwheels( void )
{
	char temp=0;
	temp = read8Buffer( THUMBWHEEL_PORT, GPIO );
	return temp;
}

char readDUTPort( void )
{
	char temp=0;
	temp = read8Buffer( DUT_PORT, GPIO );
	return temp;
}

void writeDUTPort( char daata )
{
	char temp=daata;
	write8Buffer( DUT_PORT, GPIO, temp );
}

void annunciatorOnOff( char OnOff )
{
	char temp = readDUTPort();
	if( OnOff == ON )
		temp |= ANNUNCIATOR;
	else
		temp &= ~ANNUNCIATOR;
	writeDUTPort( temp );
}
void runLEDOnOff( char OnOff )
{
	char temp = readDUTPort();
	if( OnOff == ON )
		temp |= DUT_RUN;
	else
		temp &= ~DUT_RUN;
	writeDUTPort( temp );
}

void passLEDOnOff( char OnOff )
{
	char temp = readDUTPort();
	if( OnOff == ON )
		temp |= DUT_PASS;
	else
		temp &= ~DUT_PASS;
	writeDUTPort( temp );
}

void failLEDOnOff( char OnOff )
{
	char temp = readDUTPort();
	if( OnOff == ON )
		temp |= DUT_FAIL;
	else
		temp &= ~DUT_FAIL;
	writeDUTPort( temp );
}

void write16Buffer( char address, char daata )
{
	char temp;
	IO_CS = 0;			/* select the device */
	SPDAT = 0x4e;		/* write out write opcode */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = address;	/* write out the register address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = daata;		/* write out the register data */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	IO_CS = 1;			/* deselect the device */
}

void write8Buffer( char deviceAddr, char registerAddr, char daata )
{
	char temp=0x40;
	deviceAddr <<=1;
	deviceAddr &= 0x6;
	temp |= deviceAddr;	// Set the device address
	IO_CS = 0;			// Select the device */
	SPDAT = temp;		/* write out opcode */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = registerAddr;	/* write out the register address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = daata;		/* write out the register data */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	IO_CS = 1;			/* deselect the device */
}

char read16Buffer( char registerAddr )
{
	char temp;
	IO_CS = 0;			/* select the device */
	SPDAT = 0x4f;		/* write out read opcode */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = registerAddr;	/* write out the register address */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = 0;			/* write out dummy data */
	temp = SPSCR;		/* wait for SPIF */
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	temp = SPDAT;		/* read the data */
	IO_CS = 1;			/* deselect the device */
	return temp;
}

char read8Buffer( char deviceAddr, char registerAddr )
{
	char temp=0x40;
	deviceAddr <<=1;
	deviceAddr &= 0x6;
	temp |= deviceAddr;		// Set the device address
	temp |= 1;				// Set the read bit

	IO_CS = 0;				// Select the device
	SPDAT = temp;			// Write out opcode
	temp = SPSCR;			// Wait for SPIF
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = registerAddr;	// Write out the register address
	temp = SPSCR;			// Wait for SPIF
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	SPDAT = 0;				// Write out dummy data
	temp = SPSCR;			// Wait for SPIF
	while( ( temp & 0x80 ) == 0 )temp = SPSCR;
	temp = SPDAT;			// Read the data
	IO_CS = 1;				// Deselect the device
	return temp;
}

void ext0Disable( void )
{
		EX0 = 0;
}

void ext0Enable( void )
{
		EX0 = 1;
}

void putchar( char c ) 
{
	SBUF_0 = c;
	while (!TI_0);
	TI_0 = 0;
	if( c == 0xa )
	{
		SBUF_0 = 0xd;
		while (!TI_0);
		TI_0 = 0;
	}
}
