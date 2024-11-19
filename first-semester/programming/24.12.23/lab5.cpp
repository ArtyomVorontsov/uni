#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <time.h>

// 83663 % 30 = 23

int main(){
	int end = false;
	int m, n, fill_mode, from, to;
	int **arr;
	int number_of_rows;

	srand(time(NULL));

	while(end == false){
		number_of_rows = 0;
	
		std::cout << "Enter amount of rows" << std::endl;
		std::cin >> m;

		std::cout << "Enter amount of columns" << std::endl;
		std::cin >> n;


		// Populate array.
		std::cout << "Enter filling mode (0 - manual, 1 - automatic with random values)" << std::endl;
		std::cin >> fill_mode;

		arr = (int **) malloc(m * sizeof(int *));

		if(fill_mode == 1){
			std::cout << "Random values from: ";
			std::cin >> from;
			std::cout << "Random values to: ";
			std::cin >> to;
		}

		for(int i = 0; i < m; i++){
			*(arr  + i) = (int *) malloc(n * sizeof(int));
			
			if(fill_mode == 0)
				std::cout << "Enter " << i << " row values" << std::endl;

			for(int j = 0; j < n; j++){
				if(fill_mode == 0){
					// Manual.
					std::cin >> *(*(arr + i) + j);

				} else {
					// Automatic.
					int k = 0;
					while(k == 0){
						k = (rand() % to) + from;
						if(k >= from && k <= to)
							*(*(arr + i) + j) = k;
						else 
							k = 0;

					}
				}
			}
		}

		// Print 2 dimensional array.
		for(int i = 0; i < m; i++){
			for(int j = 0; j < n; j++){
				std::cout << *(*(arr + i) + j) << " ";
			}
			std::cout << std::endl;
		}

		int x = 0;
		std::cout << "Type a number: ";
		std::cin >> x;

		for(int i = 0; i < m; i++){
			int a = 0;
			for(int j = 0; j < n; j++)
				a += *(*(arr + i) + j);
			
			if((a / n) < x)
				number_of_rows++;
		}

		std::cout << "Number of rows where element average is less than entered value: ";
		std::cout << number_of_rows << std::endl;
	}
}

