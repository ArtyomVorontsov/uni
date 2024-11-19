struct LinkedList
{
	void (*add)(struct LinkedList* self, int key, char* value);
	void (*removeByKey)(struct LinkedList* self, int key);
	struct LinkedListNode* firstNode;
};

struct LinkedListNode
{
	struct LinkedListNode* nextNode;
	char* value;
	int key;
};

void add(struct LinkedList* self, int key, char* value);
void removeByKey(struct LinkedList* self, int key);

struct LinkedList* getLinkedList();