#include "./hash-table.h"
#include "./linked-list.h"
#include <stdlib.h>
#define HASH_TABLE_SIZE 12

int hashFucntion(int key)
{	
	return key % HASH_TABLE_SIZE;
}

struct HashTable* getHashTable()
{
	struct HashTable* hashTable = (struct HashTable*)malloc(sizeof(struct HashTable));
	struct LinkedList** hashTableElements = (struct LinkedList**)malloc(sizeof(struct LinkedList*) * HASH_TABLE_SIZE);

	for (int i = 0; i < HASH_TABLE_SIZE; i++)
	{
		*(hashTableElements + i) = getLinkedList();
	}
	
	hashTable->elements = hashTableElements;
	hashTable->addElement = addElement;
	hashTable->deleteElementByKey = deleteElementByKey;

	return hashTable;
}

void addElement(struct HashTable* self, int key, char* value)
{
	int keyHash = hashFucntion(key);

	
	self->elements[keyHash]->add(self->elements[keyHash], key, value);
}

void deleteElementByKey(struct HashTable* self, int key)
{
	int keyHash = hashFucntion(key);

	self->elements[keyHash]->removeByKey(self->elements[keyHash], key);
}
