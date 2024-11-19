#include <stdio.h>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>

#ifdef __unix
#define fopen_s(pFile,filename,mode) ((*(pFile))=fopen((filename),(mode)))==NULL
#endif


int main(){
	FILE *fp, *fp2;
	fopen_s(&fp, "rest_strings.txt", "r");

	char strToDelete[255];
	char str[255];
	printf("Enter string to delete: ");
	scanf("%s", strToDelete);

	int len = strlen(strToDelete);

}
