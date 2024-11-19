#include <stdio.h>


int main(void){
	char A = 'A';
	char a = 'a';

	for(int i = 'a'; i <= 'z'; i++)
		printf("%c%c ", A++, A + (a-A));


	printf("\n");

	return 0;
}
