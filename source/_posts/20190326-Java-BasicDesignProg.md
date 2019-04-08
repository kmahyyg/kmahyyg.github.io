---
title: Java 语言笔记 - 基础的程序设计结构
date: 2019-03-26 08:41:09
tags:
  - School
---

# Java 语言笔记 - 基础的程序设计结构

Last Edited: Mar 26, 2019 8:41 AM

1. 基本的程序设计结构

```java
    public class FirstSample{
    	public static void main(String[] args){
    		System.out.Println(“hello world”);	
    	}
    }
```

public - 访问修饰符，控制访问权限

class - 表明 Java 程序中的全部内容包含在类中，类是加载程序逻辑的容器，定义了应用程序的行为。Java应用程序的全部内容必须放置在类中。

class 后紧跟类名，不可使用保留字，推荐命名方法为驼峰命名。源代码命名与类名相同。

注释使用与 C 语言相同的注释符号，不同的是禁止嵌套注释符号。

2. 数据类型

Java 的数据类型分为 8 种基本类型（primitive type），剩下的都是 reference type.

int - 4 Bytes - 2^32

short - 2 Bytes - 2^16

long - 8 Bytes - 2^64

byte - 1 Byte - 2^8

float - 4 Bytes - 3.4E+38F

double - 8 Bytes - 1.79E+308D

Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY, Double.NaN

char - 单个字符， ‘’ 包围

3. 常用转义及对应 Unicode

\b - Backspace - \u0008       \” - “ -\u022      \’ - ‘ - \u0027

\r - CR - \u000d      \\ - 反斜杠 - \u005e       \t - Tab - 制表符

\n - LF - \u000a 

Boolean, false/true     

Standard: UTF-16

3. 变量与常量

Java 当中保留关键字包括 const 和 goto，

> 1. Keywords: Keywords has special meaning (functionality) to the compiler. For this reason they cannot be used as identifiers in coding.
2. Reserved words: When Java was developed Designers wanted to eliminate two words const and goto. Thinking so, they removed them from the Java language and released the first version JDK 1.0 (in the year 1995). But still they were doubtful whether a language can exist without these two words in future; in the sense, they may be required in future versions. For this reason, const and goto were placed in reserved list. That is, they may be brought back into the Java language anytime in future. Right now as on JDK 1.8, Java proved a language can exist without these two words.
Of course, const place is taken by final keyword in Java. goto is against to structured programming language where with goto, the Programmer looses control over the flow or the structure of coding.
3. Literals: The literals also cannot be used as identifiers but can be given as values to identifiers.

```java
    double salary = 12;  
    // Initialize can be discreted with Declarartion within the same file
    int vacationDays;   // cannot use reserved chars, 
    // java.Character.isJavaIndentifierStart , isJavaIdentifierPart
    int i,j; // both are integers
```

Java 中使用关键字 final 声明常量，表示仅可被赋值一次。 声明的不同位置决定了他的生命周期。下面以声明为类常量为例。

```java
    public class Constants2 {
    	public static void main(String[] args) {
    		double paperWidth = 8.5;
    		double paperHeight = 12;
    		System.out.println("Fuck you!" + CM_PER_INCH);
    	}
    	public static final double CM_PER_INCH = 2.54;
    }
```

4. 运算符

JVM 对于浮点运算采取 64 Bits 必须截断的做法，但对于中间运算结果允许采用扩展的精度。可以采用下列方法来表示必须采用严格的浮点计算。

```java
    public static strictfp void main(String[] args)
```

(1) 关于自增自减

```c
    int m = 7 ;
    int n = 7 ;
    int a = 2 * ++m;   // now a == 16, m == 8
    int b = 2 * n++;    // now b == 14, n == 8
```

(2) 关于 Boolean 运算

Java 包含多个关系运算符，大致上完全沿用了 C 语言的习惯且按照 “短路” 方式计算。当第一部分可以确定整个表达式的值时，后面的部分将自动不予计算。

三元操作： `condition ? exp1 : exp2` 当 condition == True 时执行 exp1, 否则执行 exp2

(3) 关于移位运算

& and, | or, ^ XOR, ~ NOT

>> 右移 1 位， << 左移1 位

>>> 运算符用 0 填充高位，>> 用符号位填充高位，没有 <<<

(4) 关于引入的常量

对于常用的常量，Pi、e，可以采用下列方法使用：

1. Math.Pi, Math.E
2. 
```java
    import static java.lang.Math.*;
    System.out.println("Hello, " + sqrt(PI));
```

(5) 关于类型转换： 与 C 语言完全相同

(6) 关于括号和运算符级别

[括号和运算符级别（按照给出顺序作为优先级）](https://alicdn.kmahyyg.xyz/asset_files/2019-java-basicdesign01.csv)

(7) enum

示例：定义一个 Size 类型，使用 enum 表示枚举。

```java
    enum Size {SMALL, MEDIUM, LARGE, EXTRA_LARGE};
    Size s = Size.MEDIUM;
    // Size 类型只能存储声明的 enum 值和 null
```
