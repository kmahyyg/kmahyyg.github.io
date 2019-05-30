---
title: Java 语言笔记 - OOP - 使用现有的类与方法
date: 2019-04-09T20:28:14
description: "Java 语言的使用已有类和方法的一些基础代码"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["school","code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

# Java 语言笔记 - OOP - 使用现有的类与方法

Last Edited: Apr 09, 2019 5:50 PM

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

在一个包中，应当只有一个类有 Main 方法。JVM 在试图运行一个类之前，先检查该类是否包含一个特殊方法。这个方法必须是公有的，以便在任何位置都能访问得到。这个方法必须是 static 的，因为这个方法不能依赖任何该类的实例即可运行，而非 static 的方法，在运行之前要先创建该类的实例对象。

这样的自定义类，可能需要抽象类来进行辅助。抽象类一定是父类，不可创建实例，只有覆盖了抽象类的所有抽象方法之后的子类才可以实例化。抽象类的关键字是 abstract.

abstract 不能和哪些关键字一起用？

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

final，将一个类声明为最终（即非继承类），表示他不能被其他类继承。

friendly，默认的修饰符，只有在相同包中的对象才能使用这样的类。

***成员变量修饰符：***

public（公共访问控制符），指定该变量为公共的，他可以被任何对象的方法访问。

private（私有访问控制符）指定该变量只允许自己的类的方法访问，其他任何类（包括子类）中的方法均不能访问。

protected（保护访问控制符）指定该变量可以被自己的类和子类访问。在子类中可以覆盖此变量。

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

代码示例1：

```java
    import java.util.*;
    
    public class EmployeeTest {
    	public static void main(String[] args){
    		Employee staff = new Employee("hello",71000);
    		staff.raiseSalary(80000);
    		staff.getName();
    	}
    }
    
    class Employee {
    	public Employee(String n, int s){
    		name = n;
    		salary = s;
    	}
    
    	public String getName(){
    		System.out.println("My name: " + this.name);
    		return name;
    	}
    
    	public double raiseSalary(int newsala){
    		System.out.printf("My salary: %d \n", this.salary);
    		this.salary = newsala;
    		System.out.printf("My new salary: %d \n", this.salary);
    		return salary;
    	}
    
    	private String name;
    	private int salary;
    }
```

你会发现我在 EmployeeTest 里写了两个类，事实是：Java Compiler 会在启动时查找是否存在 Employee.class ，如果不存在就自动编译。末尾的 private 语句确保只有 Employee 类自身可以访问这些示例域，其他类的方法无法读写。

让我们继续来分析这段代码：这段代码包括了一个构造器和一个 getter，一个 setter，构造器在 new 对象时被调用，构造器与类同名、每个类可以有一个以上构造器和多个参数，构造器没有返回值。构造器中不能定义与实例域重名的局部变量，这样的局部变量会屏蔽了同名的实例域。

4.  显式参数与隐式参数

上面的代码中的 newSalary() 方法有两个参数, 第一个参数是隐式参数（即 Employee 类），第二个参数是显式参数，即括号中的参数。

5. 封装的优点

确保实例域不被第三方类进行未授权修改，修改内部方法不影响外部实现的同时，也可以通过修改修改器方法实现对数据的检查。

需要注意的一点是：不要编写返回引用可变对象的访问器方法，因为这样会同时更改一个可变对象，导致原有实例的私有域被更改。如果需要返回一个可变数据域的拷贝，可以使用克隆。

```java
    class Employee{
    	public Date getHireday(){
    			return (Date) hireDay.clone();	
    	}
    }
```

6. 静态

声明静态常量: `public static final int PI=8.99;`

使用静态方法: 这种方法仅适用于所需参数全部显式提供，并且只需要访问类的静态域的情况，例如 

```java
    public static int getNextID(){
    	return NextID;   // NOT: this.NextID;
    }
```

7. 一些特定的方法

`NumberFormat` 类中使用 `factory` 方法产生不同风格的格式化对象。

`Main` 方法是静态方法，不对任何对象进行操作。`Main` 方法的目的是执行并创建程序运行所需要的对象。

8. 方法参数

需要明确的一点是：Java 中和 C 中只存在 Call by Value&Reference, 不存在 Call by name 的情况。一个方法可以修改传递引用所对应的变量值，但是不能修改传递值。
