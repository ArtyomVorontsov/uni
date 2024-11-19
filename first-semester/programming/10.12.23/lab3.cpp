#include <stdlib.h>
#include <stdio.h>
#include <iostream>

int main(){
	int x;

	std::cout << "Input: ";
	std::cin >> x;

	int powOfTwo = 2;
	bool found = false;

	while(powOfTwo <= x){
		if(x == powOfTwo){
			found = true;
			break;
		} 
		powOfTwo = powOfTwo * 2;
	}

	if(found) 
		std::cout << "Yes" << std::endl;
	else
		std::cout << "No" << std::endl;
}
