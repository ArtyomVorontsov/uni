#include <stdio.h>


int main(void){
	char a = 'A';

	for(int i = 0; i < 26; i++)
		printf("%c", a++);


	printf("\n");

	return 0;
}
