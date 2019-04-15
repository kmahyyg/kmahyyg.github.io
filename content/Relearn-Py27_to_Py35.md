---
title: Relearn - Migrate from Python2.7 to Python 3.5
date: 2017-06-10
description: "Python 2.7 到 3.5 的一次迁移"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---


#  Part 1 : Introduction

In Python 3.5 , print() now regard as a function seriously , so if you want to print something , 
donnot forget to add brackets and quotes.

# Part 2 : Base
## 2-1 : Data Type
### Transcript - Type

转义字符\可以转义很多字符，比如\n表示换行，\t表示制表符，字符\本身也要转义，所以\\表示的字符就是\，可以在Python的交互式命令行用print()打印字符串看看.

如果字符串里面有很多字符都需要转义，就需要加很多\，为了简化，Python还允许用r''表示''内部的字符串默认不转义，可以自己试试：

如果字符串内部有很多换行，用\n写在一行里不好阅读，为了简化，Python允许用'''...'''的格式表示多行内容，可以自己试试：

> print('''line1
> line2
> line3''')

其他的 请 参阅 我的 Github("https://github.com/kmahyyg/learn_py3") 代码注释

## Argument in function and recursive function 

### 默认参数必须指向不变对象！

### Args in a func

函数参数设定必须遵循顺序：必选参数、默认参数、可变参数、命名关键字参数和关键字参数。必选参数、默认参数、可变参数、命名关键字参数和关键字参数。

### Recursive Func

 递归函数：

``` def fact(n):
        if n == 1 :
            return 1
        return n * fact(n-1)
```

但对于上述递归函数，如果输入1000，   ··· RuntimeError: maximum recursion depth exceeded in comparison ···

> 递归函数的优点是定义简单，逻辑清晰。理论上，所有的递归函数都可以写成循环的方式，但循环的逻辑不如递归清晰。

> 使用递归函数需要注意防止栈溢出。在计算机中，函数调用是通过栈（stack）这种数据结构实现的，每当进入一个函数调用，栈就会加一层栈帧，每当函数返回，栈就会减一层栈帧。由于栈的大小不是无限的，所以，递归调用的次数过多，会导致栈溢出。

> 解决递归调用栈溢出的方法是通过尾递归优化，事实上尾递归和循环的效果是一样的，所以，把循环看成是一种特殊的尾递归函数也是可以的。

> 尾递归是指，在函数返回的时候，调用自身本身，并且，return语句不能包含表达式。这样，编译器或者解释器就可以把尾递归做优化，使递归本身无论调用多少次，都只占用一个栈帧，不会出现栈溢出的情况。

> 上面的fact(n)函数由于return n * fact(n - 1)引入了乘法表达式，所以就不是尾递归了。要改成尾递归方式，需要多一点代码，主要是要把每一步的乘积传入到递归函数中。
