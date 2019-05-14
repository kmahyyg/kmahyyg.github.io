---
title: Java 语言笔记 - 大数与数组
date: 2019-04-08T18:30:57
description: "Java 语言关于大数与数组的课程笔记"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["school","code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Java 语言笔记 - 大数与数组

Last Edited: Apr 08, 2019 6:30 PM

一、大数运算

类似于 Python，Java 的 java.math 包提供了实现了任意精度的整数和浮点数运算。使用静态的 ValueOf 方法可以将常规的数值转化为大数。

```java
    import java.util.*;
    import java.math.*;
    
    
    public class BigIntegerTest {
        public static void main(String[] args){
            Scanner in = new Scanner(System.in);
            System.out.print("How many numbers do you need to draw?");
            int k  = in.nextInt();
            System.out.print("What's the highest one?");
            int n = in.nextInt();
            BigInteger lotteryOdds = BigInteger.valueOf(1);
            for (int i=1; i <= k; i ++){
                lotteryOdds = lotteryOdds.multiply(BigInteger.valueOf(n - i + 1)).divide(BigInteger.valueOf(1));
            }
            System.out.println("Your odds are 1 in " + lotteryOdds + ". Good luck!");
        }
    }
```

大数运算中没有常见的运算符，需要使用对应类的对应方法完成运算。详情请参考 Java API Reference

二、数组

数组的声明方式为： 数据类型 - 数组名。同样可以使用 C-like 的方式声明，但是，更多的时候我们推荐采用 Java-like 的方式声明。

对于数组的长度获取，我们可以通过 array.length 方法获取长度。

（1）for-each 循环

类似于 Python，这样的循环可以用下列形式表示：  for (int element : array){do sth;}

for-each 循环会尝试遍历数组中每一个元素，而不用接触他们的下标值。

如果你需要打印数组中的所有值（像 Python List 一样），你可以使用 `Arrays.toString()` 方法。需要注意的是，这个 `toString` 方法仅适用于一维数组，如果你需要对二维数组使用，你需要使用 `Arrays.deepToString()` 方法。二维数组的声明是 `int[][] magicSquare;` 

Java 还可以通过类似的代码初始化一个匿名数组：

```java
    int[] smallPrimes = {2,3,4,5};
    new int[] {17,191,23};  // 新建一个匿名数组
    smallPrimes = new int[] {17,23,56,98};
    
    // Java 中允许数组中的长度允许为 0, 但不能为 null
    new elementType[0];
    
    // 数组的浅拷贝与深拷贝
    import java.util.Arrays;
    
    public class ArrayCopyTest {
        public static void main(String[] args) {
            int[] anonymous = {17, 18, 19};
            System.out.println(Arrays.toString(anonymous));
            int[] anon = new int[]{17, 19, 20};
            int[] smallprime = anon;
            smallprime[1] = 66;
            int[] copiedNumbers = Arrays.copyOf(anon, anon.length);   // Deepcopy
            copiedNumbers[0] = 58;
            System.out.println(Arrays.toString(copiedNumbers));
            System.out.println(Arrays.toString(smallprime));
            System.out.println(Arrays.toString(anon));
        }
    }
    // 数组元素到元素拷贝还可以使用 
    // java.lang.System.arraycopy(object from, int fromindex, object to, int toindex, int count);
```   

(2) 命令行参数

Java 的 main 方法中，程序名不存储在 args 中，如果你使用下列方法运行一个应用， `java Massage -g critical` , args[0] 的值为 `-g`

(3) 数组的排序问题

Java 中如果你需要对数值型数组数组进行排序，官方在 Arrays 类中提供了优化的快速排序算法，  `Arrays.sort()`

(4) 不规则数组

Java 中实际并不存在多维数组，二维数组实际被同 Python 类似的理解为数组中的数组。

Java 中的声明 `double[][] balances = new double[10][6];` 实际等价于C的是 `double** balances = new doubles*[10]; for(i=0;i < 10;i++){balances[i] = new double[6];}`
