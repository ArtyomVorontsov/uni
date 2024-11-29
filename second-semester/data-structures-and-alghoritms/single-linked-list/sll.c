#include "./sll.h"
#include <stdlib.h>
#include <string.h>
#include "./utils.h"
#include <stdio.h>

void deleteNode(struct SLL *self, char *value)
{
    struct SLLNode *node = self->firstNode, *prevNode = NULL;

    while (node != NULL)
    {
        if (strcmp(node->value, value) == 0)
        {
            if (prevNode == NULL)
            {
                self->firstNode = node->nextNode;
            }
            else
            {
                prevNode->nextNode = node->nextNode;
            }
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
    printf("%d\n", sumString(value));

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
        if (sumString(node->value) > sumString(tempNode->value))
        {
            tempNode->nextNode = node;
            node->nextNode = NULL;
            return tempNode;
        }
        else
        {
            tempNode->nextNode = NULL;
            return node;
        }
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
        if (sumString(node->value) < sumString(middleNode->value))
        {
            if (nodeLessThanMiddlePtr)
            {
                nodeLessThanMiddlePtr->nextNode = node;
            }
            else
            {
                nodeLessThanMiddle = node;
            }
            nodeLessThanMiddlePtr = node;
            node->nextNode = NULL;
        }
        else if (sumString(node->value) > sumString(middleNode->value))
        {
            if (nodeGreaterThanMiddlePtr)
            {
                nodeGreaterThanMiddlePtr->nextNode = node;
            }
            else
            {
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

    if (nodeLessThanMiddle)
    {
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
    else
    {
        middleNode->nextNode = nodeGreaterThanMiddle;
        return middleNode;
    }
}

struct SLL *getSLL()
{
    struct SLL *newSll = (struct SLL *)malloc(sizeof(struct SLL));
    newSll->addNode = *addNode;
    newSll->deleteNode = *deleteNode;
    newSll->sortList = *sortList;

    return newSll;
}