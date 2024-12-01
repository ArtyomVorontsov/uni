My task was to implement an AVL tree structure where each element consists of a pointer to the parent element, a left element, a right element, and a value (number).
I have used C programming language to implement AVL tree data structure.
In my program there are 2 main structs AVLTree and AVLTreeNode, AVLTree struct consists of references on procedures which manipulate AVLTree data structure and also reference on root node of AVL Tree.
Procedures on which AVLTree struct fields have references are addNode, removeNode, printTree, _getInbalancedSubtreeRotationNode and _balance. Procedure addNode adds node at in the tree, removeNode removes node from the list. _getInbalancedSubtreeRotationNode procedure returns first node which is inballanced, this is needed for balancing mechanism.  Procedure _balance balances tree.
Both procedures related to balancing are called after new node is added.
In main.c available example which uses procedure getAVLTree to create AVLTree object, later in a file demonstrated various usages of addNode, removeNode as well as balancing mechanism usage.

Compiler version - gcc 11.4.0