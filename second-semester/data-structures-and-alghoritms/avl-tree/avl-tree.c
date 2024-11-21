#include "./avl-tree.h"
#include <stdlib.h>
#include <stdio.h>

struct AVLTree *getAVLTree()
{
    struct AVLTree *avlTree = (struct AVLTree *)malloc(sizeof(struct AVLTree));

    avlTree->rootNode = NULL;
    avlTree->addNode = addNode;
    avlTree->removeNode = removeNode;
    avlTree->_balance = _balance;
    avlTree->_checkBalance = _checkBalance;
    avlTree->printTree = printTree;

    return avlTree;
}

void addNode(struct AVLTree *self, int value)
{
    struct AVLTreeNode *newNode = (struct AVLTreeNode *)malloc(sizeof(struct AVLTreeNode));
    newNode->leftChild = NULL;
    newNode->rightChild = NULL;
    newNode->value = value;

    if (self->rootNode)
    {
        addNodeRecursively(newNode, self->rootNode);
    }
    else
    {
        self->rootNode = newNode;
    }
}

void addNodeRecursively(struct AVLTreeNode *newNode, struct AVLTreeNode *avlTreeNode)
{
    if (newNode->value > avlTreeNode->value)
    {
        if (avlTreeNode->rightChild == NULL)
        {
            newNode->parent = avlTreeNode;
            avlTreeNode->rightChild = newNode;
            return;
        }
        else
        {
            addNodeRecursively(newNode, avlTreeNode->rightChild);
        }
    }
    else
    {
        if (avlTreeNode->leftChild == NULL)
        {
            newNode->parent = avlTreeNode;
            avlTreeNode->leftChild = newNode;
            return;
        }
        else
        {
            addNodeRecursively(newNode, avlTreeNode->leftChild);
        }
    }
    return;
}

void removeNode(struct AVLTree *self, int value)
{
    removeNodeByValueRecursively(value, self->rootNode);
}

void removeNodeByValueRecursively(int value, struct AVLTreeNode *avlTreeNode)
{
    if (value > avlTreeNode->value)
    {
        removeNodeByValueRecursively(value, avlTreeNode->rightChild);
    }
    else if (value < avlTreeNode->value)
    {
        removeNodeByValueRecursively(value, avlTreeNode->leftChild);
    }
    else if (value == avlTreeNode->value)
    {
        struct AVLTreeNode *leftChild = avlTreeNode->leftChild;
        struct AVLTreeNode *rightChild = avlTreeNode->rightChild;
        struct AVLTreeNode *parent = avlTreeNode->parent;

        if (parent->leftChild->value == value)
        {
            free(parent->leftChild);
            parent->leftChild = NULL;
        }

        if (parent->rightChild->value == value)
        {
            free(parent->rightChild);
            parent->rightChild = NULL;
        }

        if (rightChild)
        {
            addNodeRecursively(rightChild, parent);
        }
        if (leftChild)
        {
            addNodeRecursively(leftChild, parent);
        }
    }
    return;
}

void _checkBalance(struct AVLTree *self)
{
}

void _balance(struct AVLTree *self)
{
}

void printTree(struct AVLTree *self)
{
    struct AVLTreeNode *leftMostNode;

    if (self->rootNode)
    {

        struct AVLTreeNode *leftMostNode;
        leftMostNode = self->rootNode;
        int height = 0;
        int width = 0;
        int maxHeight = 0;
        int maxWidth = 0;

        struct TreeDimension *treeDimension = getTreeDimension(self->rootNode);

        int **treeMatrix = malloc(sizeof(int *) * treeDimension->height + 1);
        // init tree matrix
        for (int i = 0; i < treeDimension->height + 1; i++)
        {
            treeMatrix[i] = malloc(sizeof(int *));
            for (int j = 0; j < (treeDimension->width + 1) * 2; j++)
            {
                treeMatrix[i][j] = malloc(sizeof(int));
                treeMatrix[i][j] = NULL;
            }
        }

        width = treeDimension->width + 1;

        printTreeRecursively(self->rootNode, &width, &height, treeMatrix);

        for (int i = 0; i < treeDimension->height + 1; i++)
        {
            for (int j = 0; j < (treeDimension->width + 1) * 2; j++)
            {
                if (treeMatrix[i][j] != NULL)
                {
                    printf(" %d ", treeMatrix[i][j]);
                }
                else
                {
                    printf("    ");
                }
            }
            printf("\n");
        }
    }
}
// TODO:
// work on correct values for treeDimension
void printTreeRecursively(struct AVLTreeNode *node, int *width, int *height, int **treeMatrix)
{

    if (node->leftChild)
    {
        *height = *height + 1;
        *width = *width - 1;
        printTreeRecursively(node->leftChild, width, height, treeMatrix);
        *height = *height - 1;
        *width = *width + 1;
    }

    printf("%d - width: %d height: %d\n", node->value, (*width), (*height));
    treeMatrix[*height][*width] = node->value;

    if (node->rightChild)
    {
        *width = *width + 1;
        *height = *height + 1;
        printTreeRecursively(node->rightChild, width, height, treeMatrix);
        *height = *height - 1;
    }
}

struct TreeDimension *getTreeDimension(struct AVLTreeNode *rootNode)
{

    int height = 0;
    int width = 0;
    int maxHeight = 0;
    int maxWidth = 0;

    getTreeDimensionRecursively(rootNode, &width, &height, &maxWidth, &maxHeight);
    struct TreeDimension *treeDimension = (struct TreeDimension *)malloc(sizeof(struct TreeDimension));
    treeDimension->height = maxHeight;
    treeDimension->width = maxWidth;

    printf("maxWidth %d, maxHeight %d \n", maxWidth, maxHeight);

    return treeDimension;
}

void getTreeDimensionRecursively(struct AVLTreeNode *node, int *width, int *height, int *maxWidth, int *maxHeight)
{
    if (*maxWidth < *width)
    {
        *maxWidth = *width;
    }

    if (*maxHeight < *height)
    {
        *maxHeight = *height;
    }

    if (node->leftChild)
    {
        *height = *height + 1;
        getTreeDimensionRecursively(node->leftChild, width, height, maxWidth, maxHeight);
    }

    if (node->rightChild)
    {
        *width = *width + 1;
        *height = *height + 1;
        getTreeDimensionRecursively(node->rightChild, width, height, maxWidth, maxHeight);
    }
}