---
title: "Java 语言笔记 - OOP - 包与包文档"
date: 2019-04-16T08:58:13+08:00
description: "Java 语言面向对象编程中包和包文档的相关内容"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["school","code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Java 中的包与包管理

## 类的使用、导入、存储

Java 中使用文件目录嵌套来作为一个包的存储结构，包与嵌套的包没有任何关系。包的包名应当以 `逆序域名 + 包的名称` 形式完成，例如：`xyz.kmahyyg.testpackage`

Java 中对于包的导入和 Python 一致，不再过多叙述。需要注意的是，Java 的包导入只能导入一个包，不能递归导入。因为 Java 存在 `static` 的方法和域，所以 `import static` 也是可行的。博主个人不建议带 `static` 使用 `import`。

Java 当中，如果一个类归属于一个包，需要在存储结构上置于同一目录之后，在类定义文件的首行加上 `package xyz.kmahyyg.testpackage;`

Java 对于类的路径使用 `classpath` 环境变量，编译器会自动在当前目录寻找相应文件，但 JVM 在 `classpath` 中没有包含 `.` 的情况下，不会查找当前目录。当然你可以在运行时添加 `-classpath` 参数显式指定，参数的内部分隔符是 `:`。

# JavaDocs

JavaDocs utility 从代码中抽取信息：

- 包
- 公有类和接口
- 公有和受保护的方法
- 公有和受保护的域

这样的几个部分的信息，应当使用 `/**.....*/` 的格式包含在注释中，注释中的文本标记使用的是 `@` 开头的 自由格式文本(free-form text)，兼容 HTML 语言。

类的注释必须放在 `import` 语句之后，类定义之前。域的注释应当只为静态域建立。

## 注释的撰写

### 方法的注释

方法的注释可以使用下列标记，应当放置在 方法定义 之前。

- `@param var desc`
- `@return desc`
- `@throws class exception-desc`

### 通用注释文本

- `@author author-name`
- `@version text`
- `@since version-text`
- `@deprecated migrate-help-text`
- `@see reference-link`  See also, 可以使用类似 HTML 的 CSS Selector 的方式跳转到其他类的注释，多个 `@see` 标记必须放在一起

### 包与概念注释

包的注释，有两种办法：

- 添加 `package.html` 在 `<body>` 标签之内的文本都会被抽取
- 添加 `package-info.java` 在 `package xyz.kmahyyg.testpackage;` 之后仅包含代码注释。

对于一个总体上的文档说明，应当放置在 `overview.html` 中，同样的，在 `<body>` 中的注释会被抽取。

## utility 的用法

- 官方有提供一个叫做 DocCheck 的小工具帮助对遗漏的文档注释搜索一组源程序文件
- `cd "xyz/kmahyyg/testpackage/../../../" && javadocs -d docDirectory <PackageName1 PackageName2 *.java>`

`javadocs` 还可以使用 `-link https://docs.oracle.com/javase/8/docs/api/ *.java` 为标准库的函数添加文档超链接，倘若你需要查看源代码，也可以转而使用 `-linksource` 选项，代码会被转换为类纯文本的 HTML 文件保存在 `docDirectory` 中。

# 一些传统推荐的类设计的实践

- 为了保证封装性，类中的数据建议设为 `private`
- 一定要对数据进行初始化
- 不要在类中使用过多的基本数据类型
- 不是所有的域都需要独立的 `getter` 和 `setter` ，但仍需遵循 JPA 标准
- 使用下列格式和顺序书写："public 访问特性 - 包作用域的访问特性 - private 访问特性"
- 每一个上述特性的部分，应当使用： "实例方法 - 静态方法 - 实例域 - 静态域"
- 将职责过多的类进行分解，尽可能模块化
- 命名注意类名和方法名应当能体现他们的职责

(END)
