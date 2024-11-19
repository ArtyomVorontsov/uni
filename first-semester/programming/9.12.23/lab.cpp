#include <iostream>

void reverse_array(int * arr, int n);

int main(){
	/* int n;

	std::cout << "Enter elements count";
	std::cin >> n;

	int *arr = new int[n];

	for(int i = 0; i < n; i++)
		std::cin >> *(arr + i);

	std::cout << std::endl;
	reverse_array(arr, n);
	std::cout << std::endl;

	for(int i = 0; i < n; i++)
		std::cout << *(arr + i) << " ";

*/
	int a[5][5] = {
		{1, 2, 3, 0, 5},
		{1, 0, 3, 4, 5},
		{1, 2, 3, 4, 5},
		{1, 0, 3, 0, 5},
		{1, 2, 3, 4, 5},
	};


	for(int i = 0; i < 5; i++){
		int zero_count = 0;
		for(int j = 0; j < 5; j++){

			if(a[i][j] == 0)
				zero_count++;
		}

		std::cout << "Zero count " << zero_count << std::endl;

	}

	return 0;
}

void reverse_array(int * arr, int n){
	int tmp;
	for(int i = 0; i < n / 2; i++){
		tmp = *(arr + i);
		*(arr + i) = *(arr + n - 1 - i);
		*(arr + n - 1 - i) = tmp;
	}
}

