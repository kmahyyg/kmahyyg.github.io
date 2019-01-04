---
title: 数据结构与算法课程 - Chap 7 图
date: 2019-01-05 01:16:11
tags:
  - School
  - Datastru
---

# 数据结构复习 - Chapter 7 图

## 图的相关概念

图是由顶点集合和顶点间的关系集合构成的一种数据结构。

图的 ADT:

```
ADT Graph {
  数据对象V：
    V是具有相同特性的数据元素的集合，称为顶点集。
  数据关系R：
    R={ VR }
    VR={<v,w>|v,w∈V且P(v,w)，<v,w>表示从v到w的弧，谓词P(v,w)定义了弧<v,w>的意义或信息}
  基本操作P：
	CreateGraph(&G,V,VR); // 按V和V R的定义构造图G
	DestroyGraph(&G);     // 销毁图G
	LocateVex(G, u);  // 若G中存在顶点u，则返回该顶点在图中位置；
	GetVex(G, v);         // 返回 v 的值
	PutVex(&G, v, value);   // 对 v 赋值value
	FirstAdjVex(G, v);  // 返回v的第一个邻接点。否则，则返回“空”
}ADT Graph
```

图的术语：

- 有向图 & 无向图
- 完全图：图中任意两个顶点间都有一条边相连接，无向完全图的边数是 n(n-1)/2，有向完全图的边数是 n(n-1)
- 稠密图/稀疏图：边数的判定界限为 nlogn
- 网络：带权图，路径上带有权值，其中非带权图的路径长度是指此路径上边的条数，带权图的路径长度是指路径上的各边的权之和。
- (非)简单路径：路径上的顶点不重复出现。

关于连通图：

- 连通图：（不一定直接连通）任意两顶点之间有路径可达，图中所有顶点均连通。
- 强连通图： 任意一对顶点存在正向路径也存在反向路径。
- 非（强）连通图的极大连通子图称为（强）连通分量。

关于邻接：

- 无向图：邻接、关联、依附于边：都是说边的两个顶点
- 有向图：从起点邻接到终点，终点邻接自起点，弧与顶点相关联

关于度：

- 度：无向图：和对应顶点关联的边的数目
- 出度：以 v 为终点的有向边数
- 入度：以 v 为起点的有向边数

生成：

- 生成树：极小连通子图，包含图的全部顶点，只能生成树的 n-1 条边，图中每个顶点间均存在路径。
- 生成森林： 有向图的一个顶点的入度为 0, 其他的顶点入度为 1, 则为有向树。生成森林包含若干个有向树

## 图的存储结构

### 邻接矩阵

1. 无向图： `edge[i][j]` 表示 i 到 j 之间有弧或边。（具有对称性，完全图的邻接矩阵中，对角线为 0，其他均为 1。）
2. 有向图： 第 i 行，表示出度边（尾）；第 j 列，表示入度边（头）。

### 邻接链表

1. 无向：`vertex | pointer` -> `pointer` == `neighbor vertex | pointer`
2. 有向：`vertex | pointer` -> `pointer` == `dest vertex | pointer`  (出边)
`vertex | pointer` -> `pointer` == `src vertex | pointer`  (入边)

## 图的遍历(aka. 搜素)

遍历的定义：从某一顶点出发，遍历其余顶点，且每个顶点仅被访问一次。实质是寻找邻接点。
其实与二叉树三序遍历等价。

DFS：计算机实现需借用辅助的 `visited[]` ，整体思路是先沿指针访问，访问后置 visited = 1, 然后直到到达的所有邻接节点都被访问过，回退，直到所有图中节点均被实现。

BFS： *NON-RECURSIVE*  辅助存储： `visited[] & Queue(Visited)` 。实现思路：从起点顺序访问，访问路径长度为 1 的节点，然后置节点为 visited = 1，并将该节点入队，当队列非空时，将队头元素出队，并置出队节点为当前节点，访问与出队节点距离为 1 的点并逐个入队，之后依次出队，将出队后的节点作为起始节点，重复上述过程。

## 图的连通性

### Kruskal 算法

1. 添加所有顶点
2. 选择最小权重边，不产生回路，直至完全连通。

### Prim 算法

1. 选择起始顶点，建立 `founded[]`
2. 将初始的辅助数组中各项元素初始化为 0 ，辅助数组结构为：

| Index | AdjVertex | LowCost |
|:-----:|:---------:|:-------:|
| 网中的节点v | 相邻点u | u与v之间的边的权重 |

其中第一次的网中节点为除了起点之外的其他节点。起始节点的 founded == 1。

3. 在对应的邻接矩阵的各点中找到最小权重的边。接下来以找到的最近的邻接点为起点，重复上述过程，直到所有节点的 founded == 1。 

时间复杂度：O(n^2)

## 有向无环图

### Activity on Vertices (AOV)

顶点表示活动，弧的起点和终点表示终点的活动必须先于起点进行。

#### 拓扑排序

目的：用于判断是否存在有向环

本质：重复选择没有直接前驱的结点

方法：

- 输入 AOV 网。
- 在 AOV 中选择没有直接前驱的点并输出，删除该顶点和发出的所有有向边。
- 重复，直至全部节点均被输出或跳出循环

若剩余有节点未被输出，则必然存在有向环。该排序方法为不稳定排序，结果不唯一。

### Activity on Edges (AOE)

顶点表示事件(Event)，有向边表示活动(Activity)，边上权值表示活动持续时间(Duration)。

入度为 0, 为 SRC，源点（开始点）；出度为 0, 为 DEST， 汇点（终点）。

Event 节点表示在 该节点之前所有活动已经完成，在它之后的活动可以开始。每边的起点为开始事件，终点为结束事件，可以看作进度条。

#### 事件之最

事件的 最早开始时间： 最长路径
事件的 最晚开始时间： 最长路径 - 出边的权值（结果取最小）

#### 活动之最

活动的 最早开始时间： 起始事件 的 最早开始时间
活动的 最迟开始时间（最长拖延时间）： 末尾事件的最晚开始时间 - 出边的权值

#### 关键路径

**活动** 的 **最早开始时间 == 最迟开始时间** 的路径

## 最短路径

http://wiki.jikexueyuan.com/project/easy-learn-algorithm/dijkstra.html

http://wiki.jikexueyuan.com/project/easy-learn-algorithm/floyd.html

### Floyd-Warshall 非负图的多源最短路径

时间复杂度：O(n^3)

1. 数组第 0 维，存储初始数据。 `[i][j]` 表示从 i 到 j 的 最短路径长度。最短路径经过的点使用链表方式，保存在另一个数组中。
2. 只允许经过一个特定的顶点 k 中转，重复上述过程。 从 i 到 j 只需判断 `[i][k] + [k][j] ?? [i][j]` 即可。
3. 推广到允许经过所有顶点中转。基本思想就是：最开始只允许经过 1 号顶点进行中转，接下来只允许经过 1 和 2 号顶点进行中转……允许经过 1~n 号所有顶点进行中转，求任意两点之间的最短路程。用一句话概括就是：从 i 号顶点到 j 号顶点只经过前k号点的最短路程。

```cpp
#include <stdio.h>

int main() {
    int e[10][10], k, i, j, n, m, t1, t2, t3;
    int inf = 99999999; //用inf(infinity的缩写)存储一个我们认为的正无穷值
    //读入n和m，n表示顶点个数，m表示边的条数
    scanf("%d %d", &n, &m);

    //初始化
    for (i = 1; i <= n; i++)
        for (j = 1; j <= n; j++)
            if (i == j) e[i][j] = 0;
            else e[i][j] = inf;
    //读入边
    for (i = 1; i <= m; i++) {
        scanf("%d %d %d", &t1, &t2, &t3);
        e[t1][t2] = t3;
    }

    //Floyd-Warshall算法核心语句
    for (k = 1; k <= n; k++)
        for (i = 1; i <= n; i++)
            for (j = 1; j <= n; j++)
                if (e[i][j] > e[i][k] + e[k][j])
                    e[i][j] = e[i][k] + e[k][j];

    //输出最终的结果
    for (i = 1; i <= n; i++) {
        for (j = 1; j <= n; j++) {
            printf("%10d", e[i][j]);
        }
        printf("\n");
    }

    return 0;
}
```

### Dijkstra 非负图的单源最短路径

时间复杂度：O(n^2)

> Talk is cheap, show me the code.  ---- Linus Torvalds

```python
#!/usr/bin/env python3
# -*- encoding:utf-8 -*-
# http://wiki.jikexueyuan.com/project/easy-learn-algorithm/dijkstra.html
# https://blog.csdn.net/qq_35644234/article/details/60870719
# https://www.geeksforgeeks.org/dijkstras-shortest-path-algorithm-greedy-algo-7/

from sys import maxsize as maxint

graph = [
    [0, 2, 5, 1, 0, 0],  # 0A, and no-route should be zero.
    [2, 0, 3, 2, 0, 0],  # 1B
    [5, 3, 0, 3, 1, 5],  # 2C
    [1, 2, 3, 0, 1, 0],  # 3D
    [0, 0, 1, 1, 0, 2],  # 4E
    [0, 0, 5, 0, 2, 0]  # 5F
]

global dist
src = int((input("Input Source: ")))  # start from source
vtx = 6  # total vertexes

dist = [maxint for i in range(vtx)]  # distance should be max at initial
foundset = []  # if shortest path found, append to here
prev = [-1] * vtx  # initate all front-driven == -1, if still -1, non-accessable


def str2Path(node):
    path = []
    n = node
    while n != src:  # insert a dest-node at front of the list, and insert its front-driven at the first
        path.insert(0, n)
        n = prev[n]
    path.insert(0, src)   # finally, insert src at the list.
    return '->'.join(list(map(str, path)))  # return built result string


def printsol(dist, vtx, src):
    print("Source:", src)
    print("\t Destination \t Length \t Shortest Path")
    for i in range(vtx):
        print(" \t\t", i, "   \t\t  ", dist[i], " \t\t  ", str2Path(i))


def mind(dist, foundset, vtx):
    from sys import maxsize as maxint
    min_idx = maxint
    min_dist = maxint
    for i in range(vtx):
        if i in foundset:
            continue
        if dist[i] < min_dist:  # find the minimal distance in not found vertexes
            min_dist = dist[i]
            min_idx = i
    return min_idx


def dj(dist, foundset, graph, vtx, src):
    dist[src] = 0
    for i in range(vtx):
        if graph[src][i] > 0:
            prev[i] = src  # if have route src->i, initate all front-driven with source
    for i in range(vtx):
        u = mind(dist, foundset, vtx)  # find the nearest neighbor
        foundset.append(u)  # set found

        for node in range(vtx):  # for all destination
            if not node in foundset:  # if that the shortest way to  destination have not found
                if graph[u][node] > 0:  # and have a way to destination
                    if dist[node] > dist[u] + graph[u][node]:
                        dist[node] = dist[u] + graph[u][node]  # update the shortest way with relay included
                        prev[node] = u  # if have shorter path, then modify its front-driven with relay vertex
    printsol(dist, vtx, src)  # print solution and shortest path length


dj(dist, foundset, graph, vtx, src)
```
