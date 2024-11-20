#include "./avl-tree.h"

int main()
{

    struct AVLTree *avlTree = getAVLTree();

    avlTree->addNode(avlTree, 11);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 7);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 5);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 10);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 18);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 14);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 12);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 16);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 22);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 20);
    avlTree->printTree(avlTree);
    avlTree->addNode(avlTree, 24);

    // avlTree->removeNode(avlTree, 7);

    avlTree->printTree(avlTree);

    return 0;
}