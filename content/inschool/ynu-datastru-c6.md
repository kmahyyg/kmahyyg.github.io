---
title: 数据结构与算法课程 - Chap 6 树和二叉树
date: 2019-01-05T01:16:05
description: "数据结构与算法课程期末复习记录 Chapter 6"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_school.webp"
categories: ["school"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# 数据结构复习 - Chapter 6 树和二叉树

## 树的相关概念

树定义： 

1. 有限集合
2. 子集为互不相交的有限集

树表示：

- 图形、嵌套集合（Venn 图）、目录表示法
- 广义表表示法：根作为由子树森林组成的表的名字写在表的左边
   > (A(B(E(K,L),F),C(G),D(H(M),I,J))) 
- 左孩子、右兄弟表示

节点定义：

- 根节点：没有前驱
- 叶子节点：没有后继（度 == 0）
- 森林：指 m 棵不相交的树的集合
- 有序树：各子树从左至右有序，不可互换
- 节点的度： 节点挂接的子树的数目
- 节点的层次：从根（01 层）到该节点的层数
- 树的度： Max({各节点的度})
- 树的深度： Max({各节点的层次})

## 树的存储

- 顺序存储：从上至下，从左至右，无法复原、没有实用价值。
- 链式存储：一个前驱、n 个后继，过于浪费存储空间、结构和定义的数据类型过于复杂。

- 双亲表示：数组存储，根节点的 index 为 0,双亲 为 -1； 其他节点的双亲为 对应双亲的数组下标。
- 孩子表示：双亲存于数组，每个对应元素的指针域指向孩子，孩子与孩子间通过指针相连，没孩子则为 NULL。
- 带双亲的孩子表示法：数组的双亲节点可能同时是另一个节点的孩子，增加一个数据域存储双亲对应的数组下标。
- 孩子兄弟表示发： `firstchild | data | nextsibling`，左存储孩子，右存储兄弟，中间为数据。

## 重点：**树到二叉树的转换**

1. 对每个孩子进行从左到右的排序；
2. 在兄弟之间加一条连线；
3. 对每个结点，除了左孩子外，去除其与其余孩子之间的联系；
4. 以根结点为轴心，将整个树顺时针转45°。

## 次重点： **森林到二叉树的转换**

兄弟相连 长兄为父 孩子靠左 头根为根

## 次重点： **二叉树到森林的转换**

把最右边的子树变为森林，其余右子树变为兄弟

## 二叉树

所有树都能转为唯一对应的二叉树。 **是一种有序树**

满二叉树：深度为 k 且含有 2k-1 个结点的二叉树。

完全二叉树：树中所含的 n 个结点和满二叉树中编号为 1 至 n 的结点一一对应。上面的要满，左边的要满，只有最右边 1 个不满或空。具有 n 个结点的完全二叉树的高度为 `[log2n] + 1` 。

### 二叉树的存储结构

- 数组，BFS 遍历，顺序存储，但无法唯一复原
- 二叉链表： `lchild | data | rchild`
- 三叉链表： `lchild | data | parent | rchild`

### **重点：二叉树的遍历与重建**

对于森林的遍历，从左到右依次对每棵树进行遍历即可。

#### DFS 深度优先

3.1.1 先根次序遍历

先根次序遍历按照“根结点-左孩子-右孩子”的顺序进行访问。

（1）递归实现

```cpp
//先根递归遍历
void preOrderRecursion(BinaryTreeNode* root){
    if(root==NULL)
        return;
    cout<<" "<<root->m_key;   //visit
    preOrderRecursion(root->m_pLeft);
    preOrderRecursion(root->m_pRight);
}
```

（2）非递归实现 

根据前序遍历访问的顺序，优先访问根结点，然后再分别访问左孩子和右孩子。即对于任一结点，其可看做是根结点，因此可以直接访问，访问完之后，若其左孩子不为空，按相同规则访问它的左子树；当访问完左子树时，再访问它的右子树。因此其处理过程如下：

给定二叉树的根节点R： 

(a)并将根节点R入栈；

(b)判断栈是否为空，若不为空，取栈顶元素cur访问并出栈。然后先将cur的右子节点入栈，再将cur的左子节点入栈；

(c)重复(b)直到栈为空，则遍历结束。

```cpp
//先根非递归遍历，需要使用栈
void preOrderStack(BinaryTreeNode* root){
    if(root==NULL)
        return; 

    stack<BinaryTreeNode*> stack;
    stack.push(root);
    BinaryTreeNode* cur=NULL;
    while(!stack.empty()){
        cur=stack.top();
        cout<<" "<<cur->m_key; //visit
        stack.pop();
        if(cur->m_pRight!=NULL)
            stack.push(cur->m_pRight);
        if(cur->m_pLeft!=NULL)
            stack.push(cur->m_pLeft);
    }
}
```

3.1.2中根次序遍历

中序遍历按照“左孩子-根结点-右孩子”的顺序进行访问。 

 （1）递归实现

```
//中根递归遍历
void midOrderRecursion(BinaryTreeNode* root){
    if(root==NULL)
        return;
    midOrderRecursion(root->m_pLeft);
    cout<<" "<<root->m_key;   //visit
    midOrderRecursion(root->m_pRight);
}
```

（2）非递归实现 

根据中序遍历的顺序，对于任一结点，先访问其左孩子，而左孩子结点又可以看做一根结点，然后继续访问其左孩子结点，直到遇到左孩子结点为空的结点才进行访问，然后按相同的规则访问其右子树。因此其处理过程如下：

对于给定的二叉树根节点R， 

 (a)若其左孩子不为空，循环将R以及R左子树中的所有节点的左孩子入栈； 
 
 (b)取栈顶元素cur，访问cur并将cur出栈。然后对cur的右子节点进行步骤（a）那样的处理； 
 
 (c)重复（a）和（b）的操作，直到cur为空切栈为空。
 
```
//中根非递归遍历，需要使用栈
void midOrderStack(BinaryTreeNode* root){
    if(root==NULL)
        return; 

    stack<BinaryTreeNode*> stack;
    BinaryTreeNode* cur=root;
    while(!stack.empty()||cur!=NULL){  
        while(cur){  
            stack.push(cur);  
            cur=cur->m_pLeft;  
        }  
        cur=stack.top();  
        cout<<" "<<cur->m_key;   //visit
        stack.pop();  
        cur=cur->m_pRight;  
    }              
}
```

3.1.3后根次序遍历

后序遍历按照“左孩子-右孩子-根结点”的顺序进行访问。 

 （1）递归实现

```cpp
//后根递归遍历
void postOrderRecursion(BinaryTreeNode* root){
    if(root==NULL)
        return;
    postOrderRecursion(root->m_pLeft);
    postOrderRecursion(root->m_pRight);
    cout<<" "<<root->m_key;   //visit
}
```

（2）非递归实现 

后序遍历的非递归实现是三种遍历方式中最难的一种。因为在后序遍历中，要保证左孩子和右孩子都已被访问并且左孩子要在右孩子前被访问，才能访问根节点。这就为流程的控制带来了难题。

对于任一结点P，将其入栈，然后沿其左子树一直往下搜索，直到搜索到没有左孩子的结点，此时该结点出现在栈顶，但是此时不能将其出栈并访问，因此其右孩子还为被访问。所以接下来按照相同的规则对其右子树进行相同的处理，当访问完其右孩子时，该结点又出现在栈顶，此时可以将其出栈并访问。这样就保证了正确的访问顺序。可以看出，在这个过程中，每个结点都两次出现在栈顶，只有在第二次出现在栈顶时，才能访问它。因此需要多设置一个变量标识该结点是否是第一次出现在栈顶。

```cpp
//非递归后序遍历，版本1
void postOrderStack1(BinaryTreeNode* root){
    if(root==NULL)
        return; 

    stack<pair<BinaryTreeNode*,bool> > s;
    pair<BinaryTreeNode*,bool> cur=make_pair(root,true);
    while(cur.first!=NULL||!s.empty())
    {
        while(cur.first!=NULL) {             //沿左子树一直往下搜索，直至出现没有左子树的结点 
            s.push(cur);
            cur=make_pair(cur.first->m_pLeft,true);
        }
        if(!s.empty()){
            if(s.top().second==true){     //表示是第一次出现在栈顶 
                s.top().second=false;
                cur=make_pair(s.top().first->m_pRight,true); //将当前节点的右节点入栈
            }
            else{                        //第二次出现在栈顶 
                cout<<s.top().first->m_key<<" ";
                s.pop();
            }
        }
    }    
}
```

#### BFS 深度优先

广度优先周游的方式是按层次从上到下，从左到右的逐层访问，不难想到，可以利用一个队列来实现。基本思想是： 
 （1）首先把二叉树的根节点送入队列； 
 （2）队首的节点出队列并访问之，然后把它的右子节点和左子节点分别入队列； 
 （3）重复上面两步操作，直至队空。

```cpp
//广度优先遍历二叉树，使用队列实现
void breadthFirstOrder(BinaryTreeNode* root){
    if(root==NULL) return;
    queue<BinaryTreeNode*> queue;
    queue.push(root);
    while(!queue.empty()){
        BinaryTreeNode* cur=queue.front();
        cout<<" "<<cur->m_key;//visit
        queue.pop();
        if(cur->m_pLeft!=NULL)
            queue.push(cur->m_pLeft);
        if(cur->m_pRight!=NULL)
            queue.push(cur->m_pRight);
    }
}    
```

#### 先序+中序 重建

构建过程： 
 （1）前序遍历序列中的第一个数字为根节点，构造根节点； 
 （2）找到根节点在中序遍历序列中的位置，中序中根节点左右两边分别为左子树和有子树，前序序列根节点后面为左子树+右子树； 
 （3）递归处理处理左右子树，返回根节点，完成构造。

由于在中序遍历中，有三个左子树节点的值，因此在前序遍历的序列中，根节点后面的3个数字就是3个左子树节点的值，再后面的所有数字都是右子树节点的值。这样子我们就在前序序列和中序序列中找到了左右子书对应的子序列，然后再递归处理即可。
 
```cpp
//二叉树节点结构体
struct BinaryTreeNode{
    int m_key;
    BinaryTreeNode* m_pLeft;
    BinaryTreeNode* m_pRight;
};

/****************************************
func:根据前序序列和中序序列构建二叉树
para:preOrder:前序序列;midOrder:中序序列;len:节点数
****************************************/
BinaryTreeNode* construct(int* preOrder,int* midOrder,int len){
    if(preOrder==NULL||midOrder==NULL||len<=0)
        return NULL;

    //先根遍历（前序遍历）的第一个值就是根节点的键值
    int rootKey=preOrder[0];
    BinaryTreeNode* root=new BinaryTreeNode;
    root->m_key=rootKey;
    root->m_pLeft=root->m_pRight=NULL;
    if(len==1 && *preOrder==*midOrder)//只有一个节点
        return root;

    //在中根遍历（中序遍历）中找到根节点的值
    int* rootMidOrder=midOrder;
    int leftLen=0; //左子树节点数
    while(*rootMidOrder!=rootKey&&rootMidOrder<=(midOrder+len-1)){ 
        ++rootMidOrder;
        ++leftLen;
    }
    if(*rootMidOrder!=rootKey)//在中根序列未找到根节点,输入错误
        return NULL;

    if(leftLen>0){ //构建左子树
        root->m_pLeft=construct(preOrder+1,midOrder,leftLen);
    }
    if(len-leftLen-1>0){ //构建右子树
        root->m_pRight=construct(preOrder+leftLen+1,rootMidOrder+1,len-leftLen-1);
    }
    return root;
}
```

### 线索二叉树

**遍历的实质是对非线性结构的二叉树进行线性化处理**

存储结构： `lchild | ltag | data | rtag | rchild`
 
 Tag == 0, 正常指向孩子；Tag == 1, lchild 指向前驱，rchild 指向后继。(前驱和后继由遍历获得)

为解决悬空，在线索链表中添加了一个“头结点”，头结点的左指针指向二叉树的根结点，其右线索指向遍历序列中的最后一个结点，即头结点的 LTag =0; RTag = 1。遍历序列中第一个结点的 lchild 域和最后一个结点的 rchild 域都指向头结点。（没有头节点，则最后一个左孩子的 lchild 和 最后一个右孩子的 rchild 为 NULL 指针，悬空状态。 **实现过程注意检测是否为叶子节点即可** ）

### 非常重要： **Huffman Tree**

这是最优二叉树，带权路径最短。

- 树的带权路径长度：树中所有叶子结点的带权路径长度之和。
- 结点带权路径长度 WPL(Weighted Path Length)：结点到根的路径长度与结点上权的乘积。
- 路径长度：路径上的分支数目。
- 树的路径长度：从树根到每一结点的路径长度之和。

Huffman 编码：利用 Huffman 树可以构造一种不等长的二进制编码，并且构造所得的 Huffman 编码是一种最优前缀编码，即：需要传输的电文的总长度最短。任何一个字符的编码都不是同一字符集中另一个字符的编码的前缀。"左 0 右 1"

![huffman_tree](https://alicdn.kmahyyg.xyz/asset_files/Huffman_tree_2.svg)

**权重最低的为叶子节点，叶子节点的双亲节点为孩子的权重之和，依此类推，根节点的孩子节点的权重最高，对应单字符的权重最高、使用频率最高、电文最短。**
