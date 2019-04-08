---
title: Java 语言笔记 - 字符串与输入输出流
date: 2019-03-30 14:39:29
tags:
  - School
---

# Java 语言笔记 - 字符串与输入输出流

Last Edited: Mar 30, 2019 2:39 PM

一、字符串

(1) 定义

字符串的识别和 C 中完全相同，“” 表示一个字符串，‘’表示一个字符，并且字符串的保存采用的是 Unicode 序列的形式。

(2) 字符串 String 类的各个方法

```java
    String e = " ";
    String greeting = "Hello world!";
    String s = greeting.substring(0,3); // return Hel
    String message = e + greeting; // Connect two strings
    // Java 的字符串一旦定义就不可变，如果你需要修改，应当截取子串后拼接
    "Hello".equals(greeting)   // 不可以用 ==
    "Hello".equalsIgnoreCase("Hello w") 
    // 检测字符串是否相同，只有字符串常量可以共享，操作后的结果不是共享的
```

具体的 API 官方文档，请参见： 

[String (Java Platform SE 8 )](https://docs.oracle.com/javase/8/docs/api/java/lang/String.html)

(3) 代码点和代码单元

每一个字串中的字符都是一个代码单元，常用的 Unicode 字符只占用 **1 个 char**，部分字符需要占用 **2 个 char**：

```java
    String greeting = "Hello";
    int n = greeting.length(); // return 5
    int cpcount = greeting.codePointCount(0, greeting.length());
```
    
返回特定位置的代码单元和代码点：

```java
    char first = greeting.charAt(0); // return 'H'
    int index = greeting.offsetByCodePoints(0,4); // 获取第4个代码点(Start from 0)
    int cp = greeting.codePointAt(index);
```

![](https://alicdn.kmahyyg.xyz/asset_files/2019-java-stdnstr1.webp)

有的朋友可能会问了：这个玩意貌似没啥卵用啊？请看下面这个例子。

```java
    // Character.isSupplementaryCodePoint();   Return Boolean
    
    import java.nio.charset.StandardCharsets;
    
    public class Main {
        public static void main(String[] args) {
            byte[] bytes = new byte[]{(byte) 0xF0,
                                      (byte) 0x90,
                                      (byte) 0x8A,
                                      (byte) 0xB7};
    
            String string = new String(bytes, StandardCharsets.UTF_8);
            System.out.println(string);
        }
    }

    public class Main {
        public static void main(String[] args) {
                    String greeting = "\uD800\uDEB7 is a mountain.";
               // https://www.fileformat.info/info/unicode/char/102b7/index.htm
                    System.out.println(greeting);
                    int cp = greeting.codePointAt(0);
                    System.out.println(Character.isSupplementaryCodePoint(cp));
    								// 辅助字符的第一部分则返回 True
        }
    }
```

![](https://alicdn.kmahyyg.xyz/asset_files/2019-java-stdnstr2.webp)

![](https://alicdn.kmahyyg.xyz/asset_files/2019-java-stdnstr3.webp)

(4) StringBuilder

使用字符串拼接的方式构建的字符串，浪费空间、效率极低，所以 Java 提供了 StringBuilder 类来尽可能的提高效率。

[StringBuilder (Java Platform SE 8 )](https://docs.oracle.com/javase/8/docs/api/java/lang/StringBuilder.html)

```java
    StringBuilder builder = new StringBuilder();
    builder.append('c');
    builder.append("Hello");
    builder.insert(2, 'c');
    builder.insert(2, "Hi");
    String hel = builder.toString();
```

二、输入输出流

(1) STDIN

Java 使用的类不再属于基本包 java.lang 时，需要手动导入

```java
    import java.util.*;
    
    public class Inpout{
    	public static void main(String[] args){
    		Scanner in = new Scanner(System.in); // Bind stdin to scanner
    		System.out.print("What is your name?")
    		String name = in.nextLine();   // Get user input as a line, stop with LF
    		String middle_name = in.next();   // Get user input as a word, stop with space
    		System.out.print("How old are you?");
    		int age = in.nextInt();   // Get user input as an integer
    	}
    }
```

[Scanner (Java Platform SE 8 )](https://docs.oracle.com/javase/8/docs/api/java/util/Scanner.html)

如果用户需要使用控制台或者输入密码等操作，请参考下列官方文档：

常用的方法有： java.lang.System.console();  java.io.Console.readPassword(String prompt, Object ... args); java.io.Console.readLine(String prompt, Object ... args);

[System (Java Platform SE 8 )](https://docs.oracle.com/javase/8/docs/api/java/lang/System.html)

(2) STDOUT

 - 1 格式化输出

Java 的格式化输出基本上沿用了 C 的格式化模式，常见的转换符有如下几个：

%d int, %x Hex, %o Octet, %f FixedFloat, %e 10^x, %g Float, %a HexFloat, %s String

%c char, %b Boolean, %h hash, %t* Time, %% %, %n Related to platform.

下列字符可用于格式化输出中的对齐或使用标准格式

%+ 正负号，%<Space> 添加空格 ， %0 数字前补0，%- 左对齐，

%( 将负数括在括号内，%<Comma> 添加分组分隔符， %#f 包含小数点，

%#x 添加前缀0x，%1$d 以十进制整数打印第一个参数，%d%<x 表示以十进制和十六进制打印同一个数值。

下列字符可用于格式化时间输出：

[Java String Format Examples - DZone Java](https://dzone.com/articles/java-string-format-examples)

 - 2 文件输入输出

```java
    public static void main(String[] args) throw FileNotFoundException{
    	Scanner in = new Scanner(new File("C:\\hello.txt"));
    	// You need to use \\ to represent \, / doesn't need escape
    	PrintWriter out = new PrintWriter(new File("/tmp/hello.txt"));
    	String cwd = System.getProperty("user.dir");
    }
```
