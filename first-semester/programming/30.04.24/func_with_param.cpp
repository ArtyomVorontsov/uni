#include <stdio.h>
#include <iostream>
#include <string>

void my_function();
void my_function(char a);
void my_function(char *a);
void my_function_2(char &a);

void print_txt(char* str);
void print_txt(std::string str);
void print_txt(std::string * str);
void print_txt(std::string & str);

void string_modifier(std::string & str);

template <class Type>
Type maxT(Type a, Type b);


int main(){
	char x = 'o';
	char *xp = &x;

	my_function( (char) 'x');
	my_function(xp);
	my_function_2(x);

	char * str = (char *) "hello string p";
	std::string * s = (std::string *) "hello string";
	std::string sv = (std::string ) "hello string";

	print_txt(str);
	print_txt("Hello string");
	//print_txt(s);

	std::string gg = "hello modified string";
	std::cout << gg << '\n';
	string_modifier(gg);
	std::cout << gg << '\n';

	int max = maxT(10, 1);
	std::cout << "Max item " << max << std::endl;

	

}

template<class Type>
Type maxT(Type a, Type b){
	if(a > b){
		return a;
	} else {
		return b;
	}
}

void my_function(){
	std::cout << "Hello world!\n";
}

void my_function(char a){
	std::cout << "Hello world by value!" << a << "\n";
}


void my_function(char *a){
	std::cout << "Hello world by pointer!" << *a << "\n";
}


void my_function_2(char &a){
	std::cout << "Hello world by reference!" << a << "\n";
}


void print_txt(char* str){

	std::cout << str << " by pointer!" << std::endl;
}

void print_txt(std::string str){

	std::cout << str << " by string value!" << std::endl;
}

void print_txt(std::string * str){


	std::cout << *str << " by string pointer!" << std::endl;
}

void print_txt(std::string & str){

	std::cout << str << " by string reference!" << std::endl;
}


void string_modifier(std::string & str){
	str[0] = 'X';
}


