#include <stdio.h>
#include <iostream>
#include <malloc.h>
#include <string.h>

int main(void){
	int i = 0;

	// create character map
	char *map = (char *) malloc(sizeof(char) * 128);

	// populate map with zeros
	while((*(map + i++) = (char) 0));

	// create buffer
	i = 0;
	char *a = (char *) malloc(sizeof(char) * 100);

	// get string	
	while((*(a + i++) = getchar()) != 10);
	a[i] = '\0';

	// count amount of chars
	i = 0;
	while(i < strlen(a)) map[*(a + i++)]++;

	// print characters 
	i = 0;
	while( i < 128){
		if(map[i] > 0 && i != 10)
			printf("%c %d\n", i, map[i]);
		i++;
	}
	

	return 0;
}
