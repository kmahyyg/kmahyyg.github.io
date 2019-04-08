---
title: Java 语言笔记 - OOP - 相关概念综述
date: 2019-04-08 22:12:45
tags:
  - School
---

# Java 语言笔记 - OOP - 相关概念综述

Last Edited: Apr 08, 2019 10:11 PM

类(class)是构造(construct)实例(instance)的蓝图，类将对象(object)的数据和行为组合通过封装(encapsulation)组合在一个包中，一个对象中的数据称为实例域(instance fields)，操作数据的过程称为方法(method)，上述值的组合就是这个对象的当前状态。通过扩展一个类来建立另外一个类的过程，称为继承(inheritance)。

对象具有三个主要特性：

- 行为 behavior: 可以施加的操作 or 方法
- 状态 state: 施加对应方法时对象如何相应
- 表示 identity: 辨别具有相同行为与状态的不同对象

作为一个类的实例而存在的对象，每个对象的标识永远不同，状态也常常存在差异。

类之间的关系常见的包括：

- 依赖(dopendence)：一个类的方法操作另一个类的对象
- 继承(aggregation)：类 A 的对象包含类 B 的对象
- 聚合(inheritance)：扩展原有类的对象和方法

定义必须被严格遵循。

