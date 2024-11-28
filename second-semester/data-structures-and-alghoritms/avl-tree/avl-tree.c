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
    avlTree->printTree = printTree;

    return avlTree;
}

struct AVLTreeNode *newNode(int value)
{
    struct AVLTreeNode *newNode = (struct AVLTreeNode *)malloc(sizeof(struct AVLTreeNode));
    newNode->leftChild = NULL;
    newNode->rightChild = NULL;
    newNode->value = value;

    return newNode;
}

void addNode(struct AVLTree *self, struct AVLTreeNode *newNode)
{
    if (self->rootNode)
    {
        addNodeRecursively(newNode, self->rootNode);
    }
    else
    {
        self->rootNode = newNode;
    }

    struct AVLTreeNode *inbalancedNode = NULL;
    if (((inbalancedNode = _getInbalancedSubtreeRotationNode(newNode)) != NULL) && newNode->parent)
    {
        _balance(self, inbalancedNode);
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

struct AVLTreeNode *_getInbalancedSubtreeRotationNode(struct AVLTreeNode *newNode)
{
    int maxHeightLeftSubtree = 0;
    int maxHeightRightSubtree = 0;
    bool isBallanced = true;

    struct AVLTreeNode *node = newNode;

    while (node && isBallanced)
    {
        maxHeightLeftSubtree = _getTreeDepthRecursively(node->leftChild);
        maxHeightRightSubtree = _getTreeDepthRecursively(node->rightChild);

        isBallanced = abs(maxHeightLeftSubtree - maxHeightRightSubtree) <= 1;

        if (isBallanced == false)
        {
            if (maxHeightLeftSubtree - maxHeightRightSubtree > 0)
            {
                node = node->leftChild;
            }
            else
            {
                node = node->rightChild;
            }
            break;
        }

        maxHeightLeftSubtree = 0;
        maxHeightRightSubtree = 0;

        node = node->parent;
    }

    if (isBallanced)
        node = NULL;

    return node;
}

int _getTreeDepthRecursively(struct AVLTreeNode *node)
{
    if (!node)
        return -1;

    int heightLeft = _getTreeDepthRecursively(node->leftChild);
    int heightRight = _getTreeDepthRecursively(node->rightChild);

    return (heightLeft > heightRight ? heightLeft : heightRight) + 1;
}

void _balance(struct AVLTree *self, struct AVLTreeNode *rotationNode)
{
    struct AVLTreeNode *inbalancedNode = rotationNode->parent;
    struct AVLTreeNode *newParent = inbalancedNode->parent;
    struct AVLTreeNode *temp = NULL;
    int leftTreeDepth = 0;
    int rightTreeDepth = 0;

    leftTreeDepth = _getTreeDepthRecursively(inbalancedNode->leftChild);
    rightTreeDepth = _getTreeDepthRecursively(inbalancedNode->rightChild);

    if ((leftTreeDepth - rightTreeDepth) > 0)
    {

        if (rotationNode->rightChild != NULL && rotationNode->leftChild == NULL)
        {

            // double right rotation
            rotationNode = rotationNode->rightChild;
            rotationNode->leftChild = rotationNode->parent;
            rotationNode->parent->rightChild = NULL;

            if (inbalancedNode == inbalancedNode->parent->leftChild)
            {
                inbalancedNode->parent->leftChild = rotationNode;
                rotationNode->rightChild = rotationNode->parent;
                rotationNode->rightChild->parent = rotationNode;
                rotationNode->parent = newParent;
            }
            else
            {
                inbalancedNode->parent->rightChild = rotationNode;
                rotationNode->rightChild = rotationNode->parent;
                rotationNode->rightChild->parent = rotationNode;
                rotationNode->parent = newParent;
            }
            inbalancedNode->parent = rotationNode;
            rotationNode->rightChild = inbalancedNode;
            inbalancedNode->leftChild = NULL;
        }
        else
        {
            // right rotation
            if (rotationNode->rightChild)
            {
                temp = rotationNode->rightChild;
                temp->parent = NULL;
            }

            if (inbalancedNode->parent != NULL && inbalancedNode == inbalancedNode->parent->leftChild)
            {
                inbalancedNode->parent->leftChild = rotationNode;
                rotationNode->rightChild = rotationNode->parent;
                rotationNode->rightChild->parent = rotationNode;
                rotationNode->parent = newParent;
            }
            else if (inbalancedNode->parent != NULL && inbalancedNode == inbalancedNode->parent->rightChild)
            {
                inbalancedNode->parent->rightChild = rotationNode;
                rotationNode->rightChild = rotationNode->parent;
                rotationNode->rightChild->parent = rotationNode;
                rotationNode->parent = newParent;
            }
            else
            {
                rotationNode->rightChild = rotationNode->parent;
                rotationNode->rightChild->parent = rotationNode;
                rotationNode->parent = NULL;
                self->rootNode = rotationNode;
            }
            inbalancedNode->parent = rotationNode;
            inbalancedNode->leftChild = NULL;
        }

        if (temp != NULL)
        {
            addNode(self, temp);
        }
    }
    else
    {
        if (rotationNode->rightChild == NULL && rotationNode->leftChild != NULL)
        {

            // double left rotation
            rotationNode = rotationNode->leftChild;
            rotationNode->rightChild = rotationNode->parent;
            rotationNode->parent->leftChild = NULL;

            if (inbalancedNode == inbalancedNode->parent->leftChild)
            {
                inbalancedNode->parent->leftChild = rotationNode;
                rotationNode->parent = newParent;
            }
            else
            {
                inbalancedNode->parent->rightChild = rotationNode;
                rotationNode->parent = newParent;
            }
            inbalancedNode->parent = rotationNode;
            rotationNode->leftChild = inbalancedNode;
            inbalancedNode->rightChild = NULL;
        }
        else
        {
            if (rotationNode->leftChild)
            {
                temp = rotationNode->leftChild;
                temp->parent = NULL;
            }

            // left rotation
            if (inbalancedNode->parent != NULL && inbalancedNode == inbalancedNode->parent->leftChild)
            {
                inbalancedNode->parent->leftChild = rotationNode;
                rotationNode->leftChild = rotationNode->parent;
                rotationNode->leftChild->parent = rotationNode;
                rotationNode->parent = newParent;
            }
            else if (inbalancedNode->parent != NULL && inbalancedNode == inbalancedNode->parent->rightChild)
            {
                inbalancedNode->parent->rightChild = rotationNode;
                rotationNode->leftChild = rotationNode->parent;
                rotationNode->leftChild->parent = rotationNode;
                rotationNode->parent = newParent;
            }
            else
            {
                rotationNode->leftChild = rotationNode->parent;
                rotationNode->leftChild->parent = rotationNode;
                rotationNode->parent = NULL;
                self->rootNode = rotationNode;
            }
            inbalancedNode->parent = rotationNode;
            inbalancedNode->rightChild = NULL;
        }

        if (temp != NULL)
        {
            addNode(self, temp);
        }
    }
}

void printTree(struct AVLTree *self)
{

    if (self->rootNode)
    {
        printTreeRecursively(self->rootNode);
    }
}

void printTreeRecursively(struct AVLTreeNode *node)
{
    if (node->leftChild)
    {

        printTreeRecursively(node->leftChild);
    }

    printf("value: %d", node->value);
    if (node->leftChild)
        printf(", leftChildValue: %d", node->leftChild->value);
    if (node->rightChild)
        printf(", rightChildValue: %d", node->rightChild->value);
    printf("\n");

    if (node->rightChild)
    {
        printTreeRecursively(node->rightChild);
    }
}
