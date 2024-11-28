#include "./avl-tree.h"

int main()
{

    struct AVLTree *avlTree = getAVLTree();
    avlTree->addNode(avlTree, newNode(11));
    avlTree->addNode(avlTree, newNode(10));
    avlTree->addNode(avlTree, newNode(12));
    avlTree->addNode(avlTree, newNode(5));
    avlTree->addNode(avlTree, newNode(7));
    avlTree->addNode(avlTree, newNode(14));
    avlTree->addNode(avlTree, newNode(16));
    avlTree->addNode(avlTree, newNode(18));
    avlTree->addNode(avlTree, newNode(20));
    avlTree->addNode(avlTree, newNode(22));
    avlTree->addNode(avlTree, newNode(24));
    avlTree->addNode(avlTree, newNode(26));
    avlTree->addNode(avlTree, newNode(28));
    avlTree->addNode(avlTree, newNode(10000));

    avlTree->printTree(avlTree);

    return 0;
}