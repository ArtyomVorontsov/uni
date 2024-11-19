struct SLLNode
{
    struct SLLNode *nextNode;
    char *value;
};

struct SLL
{
    struct SLLNode *firstNode;
    void (*deleteNode)(struct SLL *self, char *value);
    void (*addNode)(struct SLL *self, char *value);
    void (*sortList)(struct SLL *self);
};

void deleteNode(struct SLL *self, char *value);
void addNode(struct SLL *self, char *value);
void sortList(struct SLL *self);
struct SLLNode *quickSort(struct SLLNode *firstNode);
struct SLL *getSLL();