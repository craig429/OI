/*------------------------------------------------------------------------------
OIDEFS.H

Copyright 2009 Overton Instruments, Inc.
------------------------------------------------------------------------------*/
#define VERSION '1.0'
#define TRUE	1
#define FALSE	0
#define ON		TRUE
#define OFF		FALSE

#define	RTC_CS		P1_0				
#define	IO_CS		P1_1
		
#define IODIR		0x0
#define IODIRA		0x0
#define IPOL		0x1
#define IPOLA		0x1
#define GPINTEN		0x2
#define GPINTENA	0x2
#define DEFVAL		0x3
#define DEFVALA		0x3
#define INTCON		0x4
#define INTCONA		0x4
#define IOCON		0x5
#define GPPU		0x6
#define GPPUA		0x6
#define INTF		0x7
#define INTFA		0x7
#define INTCAP		0x8
#define INTCAPA		0x8
#define GPIO		0x9
#define GPIOA		0x9
#define OLAT		0xa
#define OLATA		0xa
#define IODIRB		0x10
#define IPOLB		0x11
#define GPINTENB	0x12
#define DEFVALB		0x13
#define INTCONB		0x14
#define GPPUB		0x16
#define INTFB		0x17
#define INTCAPB		0x18
#define GPIOB		0x19
#define OLATB		0x1a

// 23S08 Hardware addresses
#define THUMBWHEEL_PORT	0x01
#define DUT_PORT		0x02
#define AUX_PORT		0x03

// DUT Port bit defines
#define ANNUNCIATOR		0x01
#define DUT_PRESENT		0x02
#define FIXTURE_READY	0x04
#define DUT_FAIL		0x08
#define DUT_PASS		0x10
#define DUT_RUN			0x20
#define DUT_STOP		0x40
#define DUT_START		0x80


/*	
enum
{
	false,
	true
} bool;
*/

void systemInit( void );
void startInterrupts( void );
void putchar (char c);
void timer0ISR( void );
void displaySignOn( void );
int checkRTI();
void delay( void );
void oneSecond( void );
char continuityTest( void );
void writeRTCControl( char );
char readRTCSeconds( void );
char readRTCMinutes( void );
void writeRTCMinutes( char );
char readRTCHours( void );
void writeRTCHours( char );
// void port1( char biit, char state );
void write16Buffer( char address, char data );
char read16Buffer( char address );
void write8Buffer( char deviceAddress, char registerAddress, char data );
char read8Buffer( char deviceAddress, char registerAddress );
char readThumbwheels();
char readDUTPort();
void writeDUTPort( char data );
void annunciatorOnOff( char OnOff );
void runLEDOnOff( char OnOff );
void passLEDOnOff( char OnOff );
void failLEDOnOff( char OnOff );
void lcdInit( void );
void lcdSetFunction( void );
void lcdSetEntryMode( char increment, char shift );
void lcdSetDisplay( char displayOn, char cursorOn, char cursorBlink );
void lcdDisplayOnOff( char OnOff );
void lcdCursorOnOff( char OnOff );
void lcdBlinkOnOff( char OnOff );
void lcdWriteString( char *str );
void lcdWrite( char symbol );
void lcdClearDisplay( void );
void lcdSetDDRAMAddress( char address );
void ext0Disable( void );
void ext0Enable( void );




















	