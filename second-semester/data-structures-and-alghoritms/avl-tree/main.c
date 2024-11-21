#include "./avl-tree.h"

int main()
{

    struct AVLTree *avlTree = getAVLTree();
    avlTree->addNode(avlTree, 11);
    avlTree->addNode(avlTree, 7);
    avlTree->addNode(avlTree, 5);
    avlTree->addNode(avlTree, 10);
    avlTree->addNode(avlTree, 18);
    avlTree->addNode(avlTree, 14);
    avlTree->addNode(avlTree, 12);
    avlTree->addNode(avlTree, 16);
    avlTree->addNode(avlTree, 22);
    avlTree->addNode(avlTree, 20);
    avlTree->addNode(avlTree, 24);
    avlTree->addNode(avlTree, 26);
    avlTree->addNode(avlTree, 28);

    avlTree->printTree(avlTree);

    return 0;
}