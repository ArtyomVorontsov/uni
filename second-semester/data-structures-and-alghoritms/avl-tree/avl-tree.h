
struct AVLTreeNode
{
    struct AVLTreeNode *leftChild;
    struct AVLTreeNode *rightChild;
    struct AVLTreeNode *parent;
    int value;
};

struct AVLTree
{
    struct AVLTreeNode *rootNode;
    void (*addNode)(struct AVLTree *self, int value);
    void (*removeNode)(struct AVLTree *self, int value);
    void (*printTree)(struct AVLTree *self);
    void (*_checkBalance)(struct AVLTree *self);
    void (*_balance)(struct AVLTree *self);
};

struct TreeDimension
{
    int width;
    int height;
};

struct AVLTree *getAVLTree();
void addNode(struct AVLTree *self, int value);
void removeNode(struct AVLTree *self, int value);
void _checkBalance(struct AVLTree *self);
void _balance(struct AVLTree *self);

void addNodeRecursively(struct AVLTreeNode *newNode, struct AVLTreeNode *avlTreeNode);
void removeNodeByValueRecursively(int value, struct AVLTreeNode *avlTreeNode);
void printTreeRecursively(struct AVLTreeNode *node, int *width, int *heigth, int **treeMatrix);
void getTreeDimensionRecursively(struct AVLTreeNode *node, int *width, int *height, int *maxWidth, int *maxHeight);
struct TreeDimension *getTreeDimension(struct AVLTreeNode *rootNode);
void printTree(struct AVLTree *self);