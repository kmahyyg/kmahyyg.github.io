---
title: Java 语言笔记 - OOP - 使用现有的类与方法
date: 2019-04-09 01:04:53
tags:
  - School
---

# Java 语言笔记 - OOP - 使用现有的类与方法

Last Edited: Apr 09, 2019 1:02 AM

1. 现有的类

构造器名与类名应当相同，下列关系有两个差别：

```java
    Date birthday;   // birthday doesn't refer to any object
    Date birthday = new Date();    // this is a new built variable
    GregorianCalendar deadline = new GregorianCalendar(1999, Calendar.DECEMBER, 31, 23, 59, 59)
```

最后一个实例使用的对应类封装了实例域，这个域保存了设置的信息，这样的一个类对外暴露了两个方法， `deadline.add(Calendar.MONTH, 3);` 和 `int weekday = birthday.get(Calendar.DAY_OF_WEEK);` 这两个方法，前者对实例与做出修改，称为更改器(mutator method)方法。后者仅访问实例域而不进行修改，称为访问器方法(accessor method)。对于实例化的类，我们需要关注的是类暴露出的方法而不是其内部实现。

Java 中非常注重本地化输出，对于这类需要 i18n 输出的，应当在第一行添加 `Locale.setDefault(Locale.ITALY)` 表明默认区域。

2. 用户自定义类

在一个包中，应当只有一个类有 `Main` 方法。JVM 在试图运行一个类之前，先检查该类是否包含一个特殊方法。这个方法必须是公有的，以便在任何位置都能访问得到。这个方法必须是 `static` 的，因为这个方法不能依赖任何该类的实例即可运行，而非 `static` 的方法，在运行之前要先创建该类的实例对象。

这样的自定义类，可能需要抽象类来进行辅助。抽象类一定是父类，不可创建实例，只有覆盖了抽象类的所有抽象方法之后的子类才可以实例化。抽象类的关键字是 `abstract`.

`abstract` 不能和哪些关键字一起用？

答：

- final ：最终不能更改，抽象肯定得定义抽象方法
- private ：明显….你都私有了不让别人用还抽象干嘛
- static : 静态直接能被类名调用，对抽象类来说是没有意义的

```java
    abstract class Worker{
        private String name;
        private String id;
        private double pay;
    
        // 构造函数，员工的3个属性
        public worker(String name,String id,double pay){
            this.name = name;
            this.id = id;
            this.pay = pay;
        }
    
        // 抽象行为：工作
        public abstract void work();
    }
    
    class Programmer extends Worker{
        // 构造函数
        public programmer(String name,String id,double pay){
            // 引用父类
            super(name,id,pay);
        }
    
        // 工作行为：代码
        public void work(){
            System.out.println("I'm coding");
        }
    }
    
    class Manager extends Worker{
        // 特有属性：奖金
        private double bonus;
        // 构造函数，经理属性
        public Manager(String name,String id,double pay,double bonus){
            super(name,id,pay);
            this.bonus = bonus;
        }
        // 工作行为：管理
        public void work(){
            System.out.println("I'm managing");
        }
    }
```

3. 关于修饰符

感谢亲亲可爱的小仙女的提问让我了解了这么多。

***类修饰符：***

public（访问控制符），将一个类声明为公共类，他可以被任何对象访问，一个程序的主类必须是公共类。

abstract，将一个类声明为抽象类，没有实现的方法，需要子类提供方法实现。

final，将一个类生命为最终（即非继承类），表示他不能被其他类继承。

friendly，默认的修饰符，只有在相同包中的对象才能使用这样的类。

***成员变量修饰符：***

public（公共访问控制符），指定该变量为公共的，他可以被任何对象的方法访问。

private（私有访问控制符）指定该变量只允许自己的类的方法访问，其他任何类（包括子类）中的方法均不能访问。

protected（保护访问控制符）指定该变量可以别被自己的类和子类访问。在子类中可以覆盖此变量。

friendly ，在同一个包中的类可以访问，其他包中的类不能访问。

final，最终修饰符，指定此变量的值不能变。

static（静态修饰符）指定变量被所有对象共享，即所有实例都可以使用该变量。变量属于这个类。

transient（过度修饰符）指定该变量是系统保留，暂无特别作用的临时性变量。

volatile（易失修饰符）指定该变量可以同时被几个线程控制和修改。

***方法修饰符***：

public（公共控制符）

private（私有控制符）指定此方法只能有自己类等方法访问，其他的类不能访问（包括子类）

protected（保护访问控制符）指定该方法可以被它的类和子类进行访问。

final，指定该方法不能被重载。

static，指定不需要实例化就可以激活的一个方法。

synchronize，同步修饰符，在多个线程中，该修饰符用于在运行前，对他所属的方法加锁，以防止其他线程的访问，运行结束后解锁。

native，本地修饰符。指定此方法的方法体是用其他语言在程序外部编写的。

## TODO: 未完待续

TODO
