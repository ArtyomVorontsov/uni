#include "./linked-list.h"
#include <stdlib.h>
#include <string.h>

struct LinkedList* getLinkedList()
{
	struct LinkedList* linkedList = (struct LinkedList*)malloc(sizeof(struct LinkedList));

	linkedList->firstNode = NULL;
	linkedList->add = add;
	linkedList->removeByKey = removeByKey;

	return linkedList;
}

void add(struct LinkedList* self, int key, char* value)
{
	struct LinkedListNode* newNode = (struct LinkedListNode*)malloc(sizeof(struct LinkedListNode));
	struct LinkedListNode* node = self->firstNode;

	newNode->key = key;
	newNode->value = value;
	newNode->nextNode = NULL;

	if (node != NULL) {

		while (true)
		{
			if (node->key == key) {
				node->value = value;
				break;
			}

			if (node->nextNode == NULL) {
				node->nextNode = newNode;
				break;
			}

			node = node->nextNode;
		}
	}
	else {
		self->firstNode = newNode;
	}
}
void removeByKey(struct LinkedList* self, int key)
{
	struct LinkedListNode* node = self->firstNode;
	struct LinkedListNode* prevNode = NULL;
	while (node->nextNode != NULL)
	{
		if (node->key == key)
		{
			if (prevNode)
			{
				prevNode->nextNode = node->nextNode;
			}
			else
			{
				self->firstNode = node->nextNode;
			}

			free(node);

			break;
		}

		prevNode = node;
		node = node->nextNode;
	}
}
