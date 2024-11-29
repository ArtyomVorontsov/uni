struct HashTable
{
	struct LinkedList** elements;
	void (*addElement)(struct HashTable* self, int key, char* value);
	void (*deleteElementByKey)(struct HashTable* self, int key);
};
int hashFucntion(int key);
struct HashTable* getHashTable();
void addElement(struct HashTable* self, int key, char* value);
void deleteElementByKey(struct HashTable* self, int key);
