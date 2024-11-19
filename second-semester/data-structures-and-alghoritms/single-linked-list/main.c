#include <stdlib.h>
#include <stdio.h>
#include "./sll.h"

int main()
{

    struct SLL *sll = getSLL();

    sll->addNode(sll, "7");
    sll->addNode(sll, "6");
    sll->addNode(sll, "12");
    sll->addNode(sll, "3");
    sll->addNode(sll, "13");
    sll->addNode(sll, "4");

    struct SLLNode *node = sll->firstNode;

    // while (node != NULL)
    // {
    //     printf("%s\n", node->value);
    //     node = node->nextNode;
    // }

    node = sll->firstNode;
    sll->deleteNode(sll, "3");

    while (node != NULL)
    {
        printf("%s\n", node->value);
        node = node->nextNode;
    }

    printf("\n\nquick sort:\n");

    sll->sortList(sll);

    node = sll->firstNode;
    while (node != NULL)
    {
        printf("%s\n", node->value);
        node = node->nextNode;
    }

    return 0;
}