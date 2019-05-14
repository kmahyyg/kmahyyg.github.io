---
title: Java 语言笔记 - OOP - 对象构造
description: "Java 语言面向对象编程中一些基础的对象构造"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["school","code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
date: 2019-04-10T00:28:49
---

# Java 语言笔记 - OOP - 对象构造

Last Edited: Apr 10, 2019 12:26 AM

## 对象构造

(1) `overloading` 重载

多个构造器方法有相同的名字、不同的参数，便产生了重载。编译器必须挑选出具体执行哪个方法。如果找不到匹配的参数，或者找到多个，就会产生编译时错误。 Java 允许重载任何方法，因此描述一个方法，必须完整指明参数名和参数类型。

(2) 默认域

若构造器中没有显式赋予初值，则默认数值型 `0` 、布尔值 `False` 、对象引用 `null` ，不建议默认不赋值。默认构造器，则是指默认没有参数的构造器。显式的域初始化在 Java 中是允许的，也是可行的。

(3) 参数名

为了避免隐式参数屏蔽实例域，可以采用 this 这个关键字进行访问。代码如下：

```java
    class Employee{
    	public Employee(String aName, double aSalary){
    		this.name = aName;
    		this.salary = aSalary;
    	}
    	private String name;
    	private double salary;
    }
```

方法中的参数的一律采取 R-C-U 的方式实现，即：Read - Copy - Update (- Destroy)，再一次印证了 **Java 的对象引用的实质是值传递。**

### 关于 Overloading 的实践

使用 `this()` 调用同类中的不同构造器，其他构造器根据传入的参数返回实例化的对象：

```java
    import java.util.*;
    
    class Employee {
    
    	public Employee(double s){   // 构造器的使用与重载
    		this("John", s);
    	}
    
    	public Employee(String n, double s){
    		name = n;
    		salary = s;
    	}
    	
    	public String getName(){
    		return name;
    	}
    
    	private String name = "";
    	private double salary;
    	private static int cmpid;
    	private int id;
    	
    	static {   // 静态初始化块
    		Random generator = new Random();
    		cmpid = generator.nextInt(10000);
    	}
    
    	{    // 实例域初始化块
    		id = cmpid + 9;
    		cmpid++;
    	}
    }
```

对于构造器的调用，其具体的处理步骤如下：

1. 所有数据域初始化为默认值
2. 根据在类声明中出现的次序，依次执行所有域初始化语句和初始化块
3. 递归调用嵌套的构造器
4. 执行当前构造器

#### 析构器

析构器(deconstructor)， JVM 自己有 GC，所以 Java  不支持析构器。即使需要使用这一特性，Java 提供了 finalize() 方法，但是这个方法是不可靠、不安全的，无法确保被调用。如果使用了一些需要人工管理资源的类，请务必保证在使用完毕后调用类似 `dispose / close` 方法来完成相应清理操作。

## 参考文献

[When is the finalize() method called in Java?](https://stackoverflow.com/questions/2506488/when-is-the-finalize-method-called-in-java)

[Java 中的 static 使用之静态初始化块 - Mountain's_blog - 博客园](https://www.cnblogs.com/100thMountain/p/5374423.html)

