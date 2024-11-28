#include <stdbool.h>

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
    void (*addNode)(struct AVLTree *self, struct AVLTreeNode *node);
    void (*removeNode)(struct AVLTree *self, int value);
    void (*printTree)(struct AVLTree *self);
    bool (*_checkBalance)(struct AVLTreeNode *newNode);
    void (*_balance)(struct AVLTree *self, struct AVLTreeNode *rotationNode);
};

struct TreeDimension
{
    int width;
    int height;
};

struct AVLTree *getAVLTree();
void addNode(struct AVLTree *self, struct AVLTreeNode *newNode);
struct AVLTreeNode *newNode(int value);
void removeNode(struct AVLTree *self, int value);
struct AVLTreeNode *_getInbalancedSubtreeRotationNode(struct AVLTreeNode *newNode);
void _balance(struct AVLTree *self, struct AVLTreeNode *node);
void addNodeRecursively(struct AVLTreeNode *newNode, struct AVLTreeNode *avlTreeNode);
void removeNodeByValueRecursively(int value, struct AVLTreeNode *avlTreeNode);
struct TreeDimension *getTreeDimension(struct AVLTreeNode *rootNode);
void printTree(struct AVLTree *self);
int _getTreeDepthRecursively(struct AVLTreeNode *node);
void printTreeRecursively(struct AVLTreeNode *node);