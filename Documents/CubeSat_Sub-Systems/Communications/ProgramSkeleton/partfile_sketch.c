//Sketch of a program that will break a file into multiple parts


//header information: look up what is needed here


//Declare a global variable packsize

long packsize = 1024000  //number of bits per packet

file fd;  //declare a file descriptor
long size;  //this will be the size of the file to be broken
int num_pack, size_lpack; //size of the final packet in bits

fd = fopen('foo.txt', 'r'); //open the file and set to read mode

fseek(fd, 0L, SEEK_END); //puts fd to EOF

size = ftell(fd);  //get the size of the file  !!Check to see if this gives bytes of bits!!

rewind(fd); //reset to beginning of file 

num_pack = size/packsize; //number of packets of standard size.  One packet left over
size_lpack = size % packsize;

////////

//Label the parts in descending order.  The last part will have number zero, so then transmission will be known to be complete.

//for loop over num_pack

something = fopen('filename + strconcatenate(packnum)', 'w'); //fix this! make a file with a part number
//write bits of foo.txt to a buffer
//buffer is of size packsize
//paste the buffer into part file
fclose(something);

//end the for loop

//make the last part file (number 0) with the remaining size_lpack data

fclose(fd) //at the end

//now delete 'foo.txt' to make space for future data

