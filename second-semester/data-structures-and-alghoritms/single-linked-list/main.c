#include <stdlib.h>
#include <stdio.h>
#include "./sll.h"

int main()
{
    struct SLLNode *node;

    // Get new singly linked list
    struct SLL *sll = getSLL();

    // Add singly linked list values
    sll->addNode(sll, "7");
    sll->addNode(sll, "6");
    sll->addNode(sll, "12");
    sll->addNode(sll, "3");
    sll->addNode(sll, "13");
    sll->addNode(sll, "4");

    // Delete node by value
    sll->deleteNode(sll, "3");

    // Print singly linked list
    node = sll->firstNode;
    while (node != NULL)
    {
        printf("%s\n", node->value);
        node = node->nextNode;
    }

    // Sort singly linked list
    sll->sortList(sll);

    // Print singly linked list after sorting
    printf("\n\nQuick sort:\n");
    node = sll->firstNode;
    while (node != NULL)
    {
        printf("%s\n", node->value);
        node = node->nextNode;
    }

    return 0;
}