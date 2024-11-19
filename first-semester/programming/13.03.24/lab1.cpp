#include <atomic>
#include <stdio.h>
#include <iostream>


struct Company {
	int code;
	int paid_taxes_amount;
	char * name;
	Company * next;
};

void print_task_number();
Company * add_new_company_record(int code, int paid_taxes_amount, char * name,Company * last_company);
void print_company(Company * c);
void get_company_data(int * code, int * paid_taxes_amount, char * name);

int main(){
	// Structure fields: company code, name, paid taxes amount. 
	// Operation: define company name that paid lowest taxes amount.
	print_task_number();

	int exit = false;
	int operation_code = 0;
	Company first = {
		.code = 0,
		.paid_taxes_amount = 0,
		.name = NULL,
		.next = NULL

	};
	Company * company_list_p = &first;
	Company * head_company = &first;


	while(exit == false){
		std::cout << "Please type operation code number: \n"
			<< "0 - Exit.\n"
			<< "1 - Add company record.\n"
			<< "2 - Print all records of companies.\n"
			<< "3 - Define company name that paid lowest taxes amount.\n";

		std::cin >> operation_code;

		int code, paid_taxes_amount;
		char * name = (char *) malloc(100);

		Company * lowest_taxes_amount_company = (&first)->next;
		Company * p = &first;

		switch(operation_code){
			case 0:
				exit = true;
				break;
			case 1:
				get_company_data(&code, &paid_taxes_amount, name);
				company_list_p = add_new_company_record(code, paid_taxes_amount, name, company_list_p);
				break;

			case 2:
				while((p = p->next), (p != NULL))
					print_company(p);
				break;

			case 3:
				while((p = p->next), (p != NULL))
					if(p->paid_taxes_amount < lowest_taxes_amount_company->paid_taxes_amount)
						lowest_taxes_amount_company = p;
				std::cout << "Company which paid lowest taxes amount: \n";
				print_company(lowest_taxes_amount_company);
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

Company * add_new_company_record(int code, int paid_taxes_amount, char * name, Company * last_company){
	Company * new_company = (Company *) malloc(sizeof (Company));
	last_company->next = new_company;

	new_company->code = code;
	new_company->paid_taxes_amount = paid_taxes_amount;
	new_company->name = name;
	new_company->next = NULL;

	return new_company;
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

