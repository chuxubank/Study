# 第7章 图

## 7.1 图的定义和术语

**顶点**\(Vertex\)

**弧**\(Arc\)

**有向图**\(Digraph\)

**边**\(Edge\)

**无向图**\(Undigraph\)

对于无向图：$$0\leq e\leq \dfrac {1}{2}n\left( n-1\right)$$ **完全图**\(Completed graph\)

对于有向图：$$0\leq e\leq n\left( n-1\right)$$ **有向完全图**

有很少条边或弧的图称为**稀疏图**\(Sparse graph\)，反之称为**稠密图**\(Dense graph\)

**权**\(Weight\)：可以表示一个顶点到另一个顶点的距离或耗费

**网**\(Network\)：带权的图

对于$$G=\left( V,\left\{ E\right\} \right)$$和$$G'=\left( V',\left\{ E'\right\} \right)$$，若$$V'\subseteq V$$且$$E'\subseteq E$$则称$$G'$$为$$G$$的**子图**\(Subgraph\)

**邻接点**\(Adjacent\) **依附**\(Incident\)

**度**\(Degree\) **入度**\(InDegree\) **出度**\(OutDegree\) TD=ID+OD

$$
e=\dfrac {1}{2}\sum ^{n}_{i=1}TD\left( r_{i}\right)
$$

**路径**\(Path\)

**回路**/**环**\(Cycle\)

**简单路径** **简单回路**/**环**

无向图：**连通图**\(Connected Graph\) **连通分量**

有向图：**强连通图** **强连通分量**

**生成树**

## 7.2 图的存储结构

### 7.2.1 数组表示法

邻接矩阵：容易判定两个顶点之间是否有边（或弧）相连，并求出各个顶点的度

构造时间复杂度：$$O\left( n^{2}+e\cdot n\right)$$

### 7.2.2 邻接表\(Adjacency List\)

边稀疏时，和边相关的信息较多时用

构造时间复杂度（输入的顶点信息即为顶点的编号）：$$O\left( n+e\right)$$

否则：$$O\left( n\cdot e\right)$$

### 7.2.3 十字链表\(Orthogonal List\)

