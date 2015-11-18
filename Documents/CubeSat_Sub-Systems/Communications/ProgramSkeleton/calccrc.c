;***********************************************************************************************
; LISTING 1 - C PROGRAM FOR CALCULATING CRC
;
; "C program calculates checksums," EDN, Feb 15, 2001, pg 150
; http://www.ednmag.com/ednmag/reg/2001/02152001/04d5.htm
;************************************************************************************************

/* file calccrc.c
 * calculates the 16 bit CRC of a file
 * in Borland C++, an int is 16 bit
 *
 * file should be read in binary as this will read every character,
 * when a file is read in binary mode, the carriage return (CR) and
 * line feed (LF) are both read; in text mode, only the LF is read
 * should a file have CR in part of the data, text mode may not read
 * it
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>

unsigned int INIT = 0xFFFF;  /* initial value of CRC */
unsigned int CRC16 = 0x1021; /* bits 12, 5 and 0 */
int SHIFT_CRC = 15;          /* how far to right shift crc */
int SHIFT_BYTE = 7;          /* how far to right shift byte */
int BYTE_SIZE = 8;           /* number of bits in a byte */


unsigned int calcCRC16(unsigned int, unsigned char);

int main(int argc, char *argv[]){

	unsigned int crc = INIT;
	long byteCounter = 0;
	FILE *Data;
	char ch;

if(argc  < 2){
		printf("\nNeed to supply file name for CRC calculation.");
		printf("\nProgram terminated.");
		exit(1);
	}

/* see if file can be opened*/
	if(NULL == (Data = fopen(argv[1], "rb"))){
		printf("\nUnable to open file %s, program terminated.", argv[1]);
		exit(1);
	}

	while(!feof(Data)){
		/* The end of file character is read and processed
		 * by these statements.
		*/
		ch = fgetc(Data);
		crc = calcCRC16(crc, ch);
		byteCounter++;
	}

	fclose(Data);
	/* Subtract one from byteCounter to compensate for the
	 * end of file character being read. This character is
	 * not counted when the operating system shows file
	 * size.
	*/
   byteCounter--;

	printf("\ncrc of %s is %x",argv[1], crc);
	printf("\n(read %ld bytes)", byteCounter);

	return 0;
}


unsigned int calcCRC16(unsigned int crc, unsigned char byte){

/* Algorithim XOR's bit 15 (the MSB) of the current CRC with the current
 * MSB of byte.  The current CRC and byte are then left shifted by one.
 * This value is then XOR'ed with bits 12, 5 and 0 of the current CRC.
 * This is done until all bits in byte have been processed.
 */
	unsigned int temp;
	int index;

	for(index = 0; index < BYTE_SIZE; index++){
		temp = (crc >> SHIFT_CRC) ^ (byte >> SHIFT_BYTE);  /*temp is now MSB of CRC X or'd
														 with MSB of byte */
		crc <<= 1;  /* left shift one space */

		if(temp){  /* if temp is 1, then XOR bits 12, 5 and 0 with 1
						* if temp is 0, no need to XOR because XOR with 0
						* does not change value */
			crc ^= CRC16;
		}

		byte <<= 1; /* left shift one to get to next bit */
	}

	return crc;
}