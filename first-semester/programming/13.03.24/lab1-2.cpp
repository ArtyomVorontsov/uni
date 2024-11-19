#include <atomic>
#include <stdio.h>
#include <iostream>


struct Company {
	int code;
	int paid_taxes_amount;
	char * name;
};

void print_task_number();
Company ** add_new_company_record(int code, int paid_taxes_amount, char * name, Company ** arr_ptr);
void print_company(Company * c);
void get_company_data(int * code, int * paid_taxes_amount, char * name);

int main(){
	// Structure fields: company code, name, paid taxes amount. 
	// Operation: define company name that paid lowest taxes amount.
	print_task_number();

	int exit = false;
	int operation_code = 0;
	int company_list_length = 100;
	int company_amount = 0;
	Company ** company_list = (Company **) malloc(company_list_length * sizeof(Company *));
	Company ** company_list_p = company_list;
	Company ** lowest_taxes_amount_company = company_list_p;


	while(exit == false){
		std::cout << "Please type operation code number: \n"
			<< "0 - Exit.\n"
			<< "1 - Add company record.\n"
			<< "2 - Print all records of companies.\n"
			<< "3 - Define company name that paid lowest taxes amount.\n";

		std::cin >> operation_code;

		int code, paid_taxes_amount;
		char * name;

		switch(operation_code){
			case 0:
				exit = true;
				break;
			case 1:
				if(company_amount < company_list_length){
					name = (char *) malloc(100);
					get_company_data(&code, &paid_taxes_amount, name);
					company_list_p = add_new_company_record(code, paid_taxes_amount, name, company_list + (sizeof(Company *) * company_amount));
					company_amount++;
				} else {
					std::cout << "Error: Database is full\n";
				}
				break;

			case 2:
				for(int i = 0; i < company_amount; i++){
					print_company(*(company_list + (i * sizeof(Company *))));
				}
				break;

			case 3:
				if(company_amount > 0){
					for(int i = 0; i < company_amount; i++){
						if((*(company_list + (i * sizeof(Company *))))->paid_taxes_amount < (*lowest_taxes_amount_company)->paid_taxes_amount)
							lowest_taxes_amount_company = company_list + (i * sizeof(Company *));
					}
					std::cout << "Company which paid lowest taxes amount: \n";
					print_company(*lowest_taxes_amount_company);
				} else {
					std::cout << "Error: Database is empty\n";
				}
				break;

			default:
				exit = true;
				break;
		}

	}
};


void print_task_number(){
	int student_code = 83663;
	int amount_of_tasks = 20;
	int task_number = student_code % amount_of_tasks;

	std::cout << "Task number: " <<  task_number << "\n";
};

Company ** add_new_company_record(int code, int paid_taxes_amount, char * name, Company ** arr_ptr){
	Company ** new_company_ptr = arr_ptr;
	*new_company_ptr = (Company *) malloc(sizeof(Company *));

	(*new_company_ptr)->code = code;
	(*new_company_ptr)->paid_taxes_amount = paid_taxes_amount;
	(*new_company_ptr)->name = name;

	return new_company_ptr;
};

void print_company(Company * c){
	std::cout << "name: " << c->name << "\n"
		<< "code:" << c->code << "\n"
		<< "paid_taxes_amount:" << c->paid_taxes_amount << "\n"
		<< "=======================\n";
};

void get_company_data(int * code, int * paid_taxes_amount, char * name) {
	std::cout << "Type company code: ";
	std::cin >> *code;

	std::cout << "Type company paid_taxes_amount: ";
	std::cin >> *paid_taxes_amount;

	std::cout << "Type company name: ";
	std::cin >> name;
};

