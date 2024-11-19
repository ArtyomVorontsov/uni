#include "./sll.h"
#include <stdlib.h>
#include <string.h>

void deleteNode(struct SLL *self, char *value)
{
    struct SLLNode *node = self->firstNode, *prevNode = NULL;

    while (node != NULL)
    {
        if (strcmp(node->value, value) == 0)
        {
            prevNode->nextNode = node->nextNode;
            free(node);
            break;
        }

        prevNode = node;
        node = node->nextNode;
    }
}

void addNode(struct SLL *self, char *value)
{
    struct SLLNode *newNode = (struct SLLNode *)malloc(sizeof(struct SLLNode)), *node = self->firstNode;

    newNode->value = value;
    newNode->nextNode = NULL;

    if (self->firstNode == NULL)
    {
        self->firstNode = newNode;
    }
    else
    {
        while (node->nextNode != NULL)
        {
            node = node->nextNode;
        }
        node->nextNode = newNode;
    }
}

void sortList(struct SLL *self)
{
    self->firstNode = quickSort(self->firstNode);
}

struct SLLNode *quickSort(struct SLLNode *firstNode)
{
    int listLength = 0;
    int middleIndex = 0;

    struct SLLNode *node = NULL;
    struct SLLNode *nodeLessThanMiddle = NULL;
    struct SLLNode *nodeGreaterThanMiddle = NULL;
    struct SLLNode *nodeLessThanMiddlePtr = NULL;
    struct SLLNode *nodeGreaterThanMiddlePtr = NULL;
    struct SLLNode *middleNode = NULL;

    // get length
    node = firstNode;
    while (node)
    {
        node = node->nextNode;
        listLength++;
    }

    // check base case
    // swap in case if length is equal 2
    if (listLength == 2)
    {
        node = firstNode;
        struct SLLNode *tempNode = node->nextNode;
        tempNode->nextNode = node;
        node->nextNode = NULL;
        return tempNode;
    }

    if (listLength <= 1)
    {
        node = firstNode;
        return node;
    }

    // get middle node
    middleIndex = listLength / 2;

    node = firstNode;
    for (int i = 0; i < middleIndex; i++)
    {
        node = node->nextNode;
    }
    middleNode = node;

    // sort by middle node
    node = firstNode;
    struct SLLNode *nextNode;
    while (node)
    {
        nextNode = node->nextNode;
        if (atoi(node->value) < atoi(middleNode->value))
        {
            if (nodeLessThanMiddlePtr)
            {
                nodeLessThanMiddlePtr->nextNode = node;
            }
            else
            {
                nodeLessThanMiddlePtr = node;
                nodeLessThanMiddle = node;
            }
            nodeLessThanMiddlePtr = node;
            node->nextNode = NULL;
        }
        else if (atoi(node->value) > atoi(middleNode->value))
        {
            if (nodeGreaterThanMiddlePtr)
            {
                nodeGreaterThanMiddlePtr->nextNode = node;
            }
            else
            {
                nodeGreaterThanMiddlePtr = node;
                nodeGreaterThanMiddle = node;
            }
            nodeGreaterThanMiddlePtr = node;
            node->nextNode = NULL;
        }

        node = nextNode;
    }

    // recursive call of quick sort
    nodeLessThanMiddle = quickSort(nodeLessThanMiddle);
    nodeGreaterThanMiddle = quickSort(nodeGreaterThanMiddle);

    // move to last node in the list
    nodeLessThanMiddlePtr = nodeLessThanMiddle;
    while (nodeLessThanMiddlePtr->nextNode)
    {
        nodeLessThanMiddlePtr = nodeLessThanMiddlePtr->nextNode;
    }

    nodeLessThanMiddlePtr->nextNode = middleNode;

    middleNode->nextNode = nodeGreaterThanMiddle;

    return nodeLessThanMiddle;
}

struct SLL *getSLL()
{
    struct SLL *newSll = (struct SLL *)malloc(sizeof(struct SLL));
    newSll->addNode = *addNode;
    newSll->deleteNode = *deleteNode;
    newSll->sortList = *sortList;

    return newSll;
}