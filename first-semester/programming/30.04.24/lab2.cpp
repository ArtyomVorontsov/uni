#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string>

void spaceTrim(char * str);
void spaceTrim(std::string &str);

int main(){
	int studentCode = 86336;
	int taskVarCount = 25;
	int stringsAmount = 0;

	std::cout << "Program number: " << studentCode % taskVarCount << std::endl;
	//Function deletes repeated spaces (replaces multiple spaces with single space) in the string.
	
	char ** c_strgs = (char **) malloc(sizeof(char *) * 3);

	// Gather strings	
	do{
		char * str = (char *) malloc(1000);

		// get c string
		char c;
		int i = 0;
		while((c = getchar()) != '\n'){
			*(str + i) = c;
			i++;
		}
		*(str + i) = '\0';

		*(c_strgs + sizeof(char **) * stringsAmount) = str;
		stringsAmount++;
	} while (stringsAmount < 3);

	// Copy c strings to new array as c++ strings
	std::string * cpp_strgs = (std::string *) malloc(sizeof(std::string) * 3);

	int i = 0;
	while(i < 3){
		std::string s = *(c_strgs + sizeof(char *) * i);
		*(cpp_strgs + i * sizeof(std::string *)) = s;
		i++;
	}
	
	// Trim strings
	i = 0;
	while(i < 3){
		spaceTrim((char *) *(c_strgs + sizeof(char *) * i));
		spaceTrim(*(cpp_strgs + i * sizeof(std::string *)));
		i++;
	}

	// Print strings 
	i = 0;	
	while(i < 3){
		std::cout << *(c_strgs + sizeof(char **) * i) << std::endl;
		std::cout << *(cpp_strgs + i * sizeof(std::string *)) << std::endl;
		i++;
	}

	return 0;
}

void spaceTrim(char * str) {
	bool spaceEncountered = false;

	char * str_end = 0, i = 0;
	int space_amount = 0;


	while(*(str + i++) != '\0');
	str_end = str + i;

	while(*(str++) != '\0'){
		if(spaceEncountered){
			int j, i = 0;
			char * start = str;

			while(*(str + i) != '\0' && *(str + i) == ' ') i++;

			space_amount+=i;

			j = i;

			while(*(str + i) != '\0'){
				*(start++) = *(str + i);
				i++;
			}

			str = str + j;
		}

		if(*str == ' ' && spaceEncountered == false){
			spaceEncountered = true;
		}

		if(*str != ' ')
			spaceEncountered = false; 

	}

	*(str_end - space_amount - 1) = '\0';
}

void spaceTrim(std::string &str) {
	bool spaceEncountered = false;

	int indx = 0;
	int from = -1, to = -1;
	char c;


	int space_amount = 0;
	while(str[indx++] != '\0'){
		if(str[indx] == ' ' && spaceEncountered == false){
			from = indx;
			spaceEncountered = true;
		}
		else if(str[indx] != ' ' && spaceEncountered == true){
			to = indx;
			spaceEncountered = false;

			if(to - from < 2){
				from = -1;
				to = -1;
			}
		} else if (spaceEncountered){
			space_amount++;
		}

		if(from > -1 && to > -1){
			str.erase(from + 1, space_amount);
			indx = from;
			space_amount = 0;
			from = -1;
			to = -1;
		}
	}

}


