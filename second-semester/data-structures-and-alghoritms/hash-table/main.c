#include "./hash-table.h"
#include "./linked-list.h"
#include <stdlib.h>
#include <stdio.h>

int main()
{
	struct HashTable* ht = getHashTable();

	ht->addElement(ht, 1, (char *) "hello");
	ht->addElement(ht, 2, (char*) "world");
	ht->addElement(ht, 2, (char*)"a?");
	ht->addElement(ht, 3, (char*) "lol");
	ht->addElement(ht, 12, (char*)"coli");
	ht->addElement(ht, 24, (char*)"sion");
	ht->addElement(ht, 0, (char*)"check");


	// print hash table contents
	for (int i = 0; i < 4; i++)
	{
		struct LinkedListNode *lln = ht->elements[i]->firstNode;

		while (lln != NULL) {
			printf("key: %d, value: %s\n", lln->key, lln->value);
			lln = lln->nextNode;
		}
	}

	return 0;
}