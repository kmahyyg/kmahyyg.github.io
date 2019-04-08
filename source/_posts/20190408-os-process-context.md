---
title: 操作系统原理 - 用户空间、内核空间与上下文
date: 2019-04-08 00:51:52
tags:
  - School
---

# 警告

本文很长，均为 Linux 实现，并将附赠源代码链接。请做好长时间阅读的准备。

作者的精力有限，本文将仅讨论 Linux Kernel 5.0.6 的 x86_32 和 x86_64 架构的相关实现。ARM 和 MIPS 架构在部分内容上有较大的区别，请有兴趣的读者自行 Google.

# 内核空间与用户空间

下图是 Linux 的一个整体结构示意：

![Kernel Memory Space](https://alicdn.kmahyyg.xyz/asset_files/context_01_insidelinux.webp)

## 定义与铺垫

### 虚拟内存地址

我们首先需要明确的一点：现代操作系统为了性能考虑，全部采用了虚拟内存地址机制，来确保系统的高效运行。

那我们为什么需要采用虚拟内存地址：

- 编译器编译产生的二进制运行产生的内存映像（Process Image）是将二进制文件中所有内容加载到内存的一个镜像，每一个函数都有一个 hardcoded 的保存地址，如果没有虚拟内存，想象一下多个程序同时运行的情况，必然产生代码冲突。
- 还是和上面一样，假设加载到内存地址产生冲突，但是恰好两部分代码一致，其中某一个程序出错了，这段内存被改写。另一个进程会因为这段被改写的内存空间而导致 crash.
- 同样的多进程环境，部分内存为了系统安全，应当不允许被系统内核之外的程序读取。如果不使用虚拟内存机制，难以对这一点做出保证。
- 假设采取内存分页机制，如果直接使用 direct address，不停的进行页交换，必然会导致严重的性能损耗。
- 根据硬件的不同，部分地址为某些硬件运行而预留，第三方改写或非法读取可能造成严重后果。
- 早期电脑的运行内存较小，虚拟内存机制可以将主存的部分空间用于临时充当内存。

具体的对于内存地址的映射和管理问题，我们将在后续学习到内存调度时进一步阐述。

### 内核空间与用户空间

#### 32 位架构的机器

综上所述，我们在当前运行的电脑上（例如运行 gdb 调试程序时）看到的内存地址均为系统对物理内存进行映射后的虚拟地址。对于这部分地址的处理，Linux Kernel 在 32 位架构（最大内存寻址能力 4 GiB）的机器上将其分割为两部分，Low + High，比例为 Low: High = 3:1 ，具体的源代码可以参加 Linux 内核源码 [arch/x86/Kconfig Line 1361](https://elixir.bootlin.com/linux/v5.0.6/source/arch/x86/Kconfig#L1361)。对于 32 位架构，内存大于 4 GiB 的 Intel 机器，则内核会启用 Intel Physical Address Extension (PAE) 来扩展寻址到最大 64 GiB，这部分内容略去不表。

```
Linux uses only 4 segments:

2 segments (code and data/stack) for KERNEL SPACE from [0xC000 0000] (3 GB) to [0xFFFF FFFF] (4 GB)
2 segments (code and data/stack) for USER SPACE from [0] (0 GB) to [0xBFFF FFFF] (3 GB)
                               __
   4 GB--->|                |    |
           |     Kernel     |    |  Kernel Space (Code + Data/Stack)
           |                |  __|
   3 GB--->|----------------|  __
           |                |    |
           |                |    |
   2 GB--->|                |    |
           |     Tasks      |    |  User Space (Code + Data/Stack)
           |                |    |
   1 GB--->|                |    |
           |                |    |
           |________________|  __| 
 0x00000000
          Kernel/User Linear addresses
          
          
          
            ________________ _____                    
           |Other KernelData|___  |  |                |
           |----------------|   | |__|                |
           |     Kernel     |\  |____|   Real Other   |
  3 GB --->|----------------| \      |   Kernel Data  |
           |                |\ \     |                |
           |              __|_\_\____|__   Real       |
           |      Tasks     |  \ \   |     Tasks      |
           |              __|___\_\__|__   Space      |
           |                |    \ \ |                |
           |                |     \ \|----------------|
           |                |      \ |Real KernelSpace|
           |________________|       \|________________|
      
           Logical Addresses          Physical Addresses
```

而这两部分空间的左右是什么呢？怎样才能正确的操作这部分空间呢？（保留原汁原味，不翻译！）

> Kernel space is where the kernel (i.e., the core of the operating system) executes (i.e., runs) and provides its services.

> User space is that set of memory locations in which user processes (i.e., everything other than the kernel) run. A process is an executing instance of a program. One of the roles of the kernel is to manage individual user processes within this space and to prevent them from interfering with each other.

> Kernel space can be accessed by user processes only through the use of system calls. System calls are requests in a Unix-like operating system by an active process for a service performed by the kernel, such as input/output (I/O) or process creation. An active process is a process that is currently progressing in the CPU, as contrasted with a process that is waiting for its next turn in the CPU. I/O is any program, operation or device that transfers data to or from a CPU and to or from a peripheral device (such as disk drives, keyboards, mice and printers).

#### 64 位架构的机器

对于 64 位架构的机器，其最大内存寻址能力为 17179869184 GiB，足以覆盖目前常见的绝大多数机器装配的内存。故而 Linux kernel 不再区分 Low/High Memory，全部视为 Low Memory。User Space 和 Kernel Space 的 Limit 均相同。现今的内存分页机制其实非常复杂，由于分页层数的不同，导致虚拟地址空间的大小也不同，具体相关描述请查看内核源代码和内核文档。

![Linux Mapper of RAM_x64](https://alicdn.kmahyyg.xyz/asset_files/context_02_lvmm_64.svg)

下列的文档可能对你了解这部分内容有所帮助。

- https://en.wikibooks.org/wiki/The_Linux_Kernel/Memory

- https://elixir.bootlin.com/linux/v5.0.6/source/arch/x86/Kconfig#L1356

- https://elixir.bootlin.com/linux/v5.0.6/source/Documentation/vm/highmem.rst

> High memory (highmem) is used when the size of physical memory approaches or exceeds the maximum size of virtual memory. At that point it becomes impossible for the kernel to keep all of the available physical memory mapped at all times. This means the kernel needs to start using temporary mappings of the pieces of physical memory that it wants to access.

- https://elixir.bootlin.com/linux/v5.0.6/source/Documentation/x86/x86_64/mm.txt

> Architecture defines a 64-bit virtual address. Implementations can support
less. Currently supported are 48- and 57-bit virtual addresses. Bits 63
through to the most-significant implemented bit are sign extended.
This causes hole between user space and kernel addresses if you interpret them
as unsigned.

> The direct mapping covers all memory in the system up to the highest
memory address (this means in some cases it can also include PCI memory
holes).

### 关于内核空间与内存安全

那为什么要区分内核空间和用户空间呢？每个进程到底能用到多少的内存呢？

操作系统的核心是系统内核，内核独立于普通的应用程序，可以访问受保护的内存空间、拥有访问底层所有硬件设备的最高权限，保护这部分内存就显得尤为重要。针对 32 位 Linux 操作系统而言，将最高的 1 GiB（从虚拟地址 0xC0000000 到 0xFFFFFFFF ），供内核使用，称为内核空间，而将较低的 3 GiB（从虚拟地址 0x00000000 到 0xBFFFFFFF ），供各个进程使用，称为用户空间。每个进程可以通过系统调用进入内核，因此，Linux 内核由系统内的所有进程共享。于是，从具体进程的角度来看，每个进程可以拥有 4 GiB 的虚拟空间。

内核空间故名思议，存放的是内核代码和数据；而用户空间存放的是用的代码和数据，这两部分空间再次强调，都是保存在 **虚拟内存空间之内** 的。内核的数据需要悉心的保护，确保不被未授权第三方获取，Linux Kernel 使用了两层保护机制，即 Ring 0 和 Ring 3.

用户初始运行一个进程时，运行于 Ring 3（用户态），此时处理器工作在权限最低的 Ring 3, 程序请求提权发出中断信号，进而通过 TRAP 指令调用中断处理程序执行 System Call（系统调用），陷入 Ring 0（内核态）时便拥有了最高权限，执行的内核代码便会调用当前进程的内核栈，每个进程都有自己对应的内核栈。有名的 Rootkit 病毒便大多是提权到 Ring 0 来实现自我保护的。

#### 题外：那 Ring 1 和 Ring 2 呢？

X86 架构提供了四层分级保护域，Ring 0 到 Ring 3. Ring 0 具有最高权限，Ring 3 权限最低。Ring 1 大多用于加载虚拟化内核和硬件驱动（例如：VirtualBox Guest Kernel），Ring 2 大多用于加载 I/O 设备相关的驱动和一些被保护的函数库(I/O Privileged Code)，早期的 OS/2 的 Presentation Manager 代码便加载到这一层。个人认为，可以简单的理解为 Ring 1 、 Ring 2 和 Ring 0 的差异可以简化视为描述符不同的 Ring 0 层。

# 上下文 Context

## 明确相关概念

上下文：是从英文 Context 翻译过来，指的是一种环境。相对于进程而言，就是进程执行时的环境；具体来说就是各个变量和数据，包括所有的寄存器变量、进程打开的文件、内存信息等。主要分为中断上下文、进程上下文、原子上下文。

原子： Atom，本意是“不能被进一步分割的最小粒子”，而原子操作 (atomic operation) 意为"不可被中断的一个或一系列操作"。

原子上下文：内核的一个原则是：在处理 IRQ 过程中、以及持有自旋锁 (spin_lock) 的过程中，内核不能访问用户空间，内核不能调用任何引起睡眠的函数。如果一个进程正在处于上述状态之一，且不能被中断，则称该进程正在进行原子操作，该进程此时对应的上下文为原子上下文。

### 原子上下文

Linux 提供了以下六个宏来判断是否处于原子上下文的情况： [include/linux/preempt.h Line 87](https://elixir.bootlin.com/linux/v5.0.6/source/include/linux/preempt.h#L87)

```c
/*
 * Are we doing bottom half or hardware interrupt processing?
 *
 * in_irq()       - We're in (hard) IRQ context
 * in_softirq()   - We have BH disabled, or are processing softirqs
 * in_interrupt() - We're in NMI,IRQ,SoftIRQ context or have BH disabled
 * in_serving_softirq() - We're in softirq context
 * in_nmi()       - We're in NMI context
 * in_task()	  - We're in task context
 *
 * Note: due to the BH disabled confusion: in_softirq(),in_interrupt() really
 *       should not be used in new code.
 */
#define in_irq()		(hardirq_count())
#define in_softirq()		(softirq_count())
#define in_interrupt()		(irq_count())
#define in_serving_softirq()	(softirq_count() & SOFTIRQ_OFFSET)
#define in_nmi()		(preempt_count() & NMI_MASK)
#define in_task()		(!(preempt_count() & \
				   (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
```

[include/linux/preempt.h Line 142](https://elixir.bootlin.com/linux/v5.0.6/source/include/linux/preempt.h#L142)

```c
/*
 * Are we running in atomic context?  WARNING: this macro cannot
 * always detect atomic context; in particular, it cannot know about
 * held spinlocks in non-preemptible kernels.  Thus it should not be
 * used in the general case to determine whether sleeping is possible.
 * Do not use in_atomic() in driver code.
 */
#define in_atomic()	(preempt_count() != 0)
```

这些宏访问的地方都是： `thread_info->preempt_count` 这些中断计数和抢占计数任何地方返回不为 0 均为原子上下文，禁止违反上面说过的原则。令人奇怪的是，`in_atomic()` 这个宏提示是 unrealiable 的，为什么呢？

> 但是，对于 `in_atomic()` 来说，在启用抢占的情况下，它工作的很好，可以告诉内核目前是否持有自旋锁，是否禁用抢占等。但是，在没有启用抢占的情况下， `spin_lock` 根本不修改 `preempt_count()` ，所以即使内核调用了 `spin_lock` ，持有了自旋锁，`in_atomic()` 仍然会返回 0，错误的告诉内核目前在非原子上下文中。所以凡是依赖 `in_atomic()` 来判断是否在原子上下文的代码，在禁止线程抢占的情况下都是不可靠的。具体的显式声明禁止线程抢占由 `preempt_disable()` 实现。

### 关于 Linux Kernel 的 preempt_count

`preempt_count` 是 Linux 的线程抢占计数器，不过多深入，之后讲到线程调度和预防死锁的时候我们会详细介绍。具体的 `preempt_count` 的内容定义在 Linux 内核源代码的这里可以查到：[include/linux/preempt.h Line 13](https://elixir.bootlin.com/linux/v5.0.6/source/include/linux/preempt.h#L13)

```c
/*
 * We put the hardirq and softirq counter into the preemption
 * counter. The bitmask has the following meaning:
 *
 * - bits 0-7 are the preemption count (max preemption depth: 256)
 * - bits 8-15 are the softirq count (max # of softirqs: 256)
 *
 * The hardirq count could in theory be the same as the number of
 * interrupts in the system, but we run all interrupt handlers with
 * interrupts disabled, so we cannot have nesting interrupts. Though
 * there are a few palaeontologic drivers which reenable interrupts in
 * the handler, so we need more than one bit here.
 *
 *         PREEMPT_MASK:	0x000000ff
 *         SOFTIRQ_MASK:	0x0000ff00
 *         HARDIRQ_MASK:	0x000f0000
 *             NMI_MASK:	0x00100000
 * PREEMPT_NEED_RESCHED:	0x80000000
 */
#define PREEMPT_BITS	8
#define SOFTIRQ_BITS	8
#define HARDIRQ_BITS	4
#define NMI_BITS	1
```

具体的自己看代码注释吧，懒得过多解释了。

## 上下文切换简述

### 进程上下文

通过上面的介绍，我们知道处理器总处于下列三种状态的一种：

- 内核态，运行于进程上下文，内核代表进程运行于内核空间。
- 内核态，运行于中断上下文，内核代表硬件运行于内核空间。
- 用户态，运行于用户空间。

当用户需要请求某个物理设备或系统服务时，就需要通过系统调用使用户程序陷入内核空间后映射对应设备、服务地址到用户空间，才能继续执行。

相对于进程而言，上下文就是进程执行时的环境。当一个进程在执行时, CPU 的所有寄存器中的值、进程的状态以及堆栈中的内容、优先级、调度信息、审计信息、I/O状态、信号与事件信息等等被称为该进程的上下文，是一种对进程执行活动全过程的静态描述。当内核需要切换到另一个进程时，它需要保存当前进程的所有状态，即保存当前进程的上下文，以便在再次执行该进程时，能够必得到切换时的状态执行下去。在 LINUX 中，当前进程上下文均保存在进程的任务数据结构中。在发生中断时，内核就在被中断进程的上下文中，在内核态下执行中断服务例程。但同时会保留所有需要用到的资源，以便中继服务结束时能恢复被中断进程的执行。一个进程的上下文可以分为三个部分:用户级上下文、寄存器上下文以及系统级上下文。

（1）用户级上下文: 正文、数据、用户堆栈以及共享存储区；
（2）寄存器上下文: 通用寄存器、程序寄存器(IP)、处理器状态寄存器(EFLAGS)、栈指针(ESP)；
（3）系统级上下文: 进程控制块 task_struct、内存管理信息(mm_struct、vm_area_struct、pgd、pte)、内核栈。

当发生进程调度时，进行进程切换就是上下文切换(context switch). 操作系统必须对上面提到的全部信息进行切换，新调度的进程才能运行。而系统调用进行的模式切换(mode switch)。模式切换与进程切换比较起来，容易很多，而且节省时间，因为模式切换最主要的任务只是切换进程寄存器上下文的切换。进程上下文主要保存的内容是异常处理程序与内核线程，在进程上下文中引用 current 是有意义的。上下文切换的一个活动流程是：

- 挂起一个进程，将这个进程在 CPU 中的状态（上下文）存储于内存中的某处，
- 在内存中检索下一个进程的上下文并将其在 CPU 的寄存器中恢复
- 跳转到程序计数器所指向的位置（即跳转到进程被中断时的代码行），以恢复该进程

由于需要访问 Process Table (Maintained by Kernel)，故 Context Switch 能且仅能在 内核中 进行。

### 中断上下文

硬件通过触发信号，导致内核调用中断处理程序，进入内核空间。这个过程中，硬件的一些变量和参数也要传递给内核，内核通过这些参数进行中断处理。所谓的 “中断上下文” ，其实也可以看作就是硬件传递过来的这些参数和内核需要保存的一些其他环境（主要是当前被打断执行的进程环境）。这样的一个中断信号的发生是 random 的，中断处理和软中断无法预测何时发生、什么设备（进程）触发了这个中断，这样的一种中断，引用 current 可以，但没有意义。而中断时，内核不代表任何进程运行，它一般只访问系统空间，而不会访问进程空间，内核在中断上下文中执行时一般不会阻塞。

中断上下文是原子上下文的一部分，禁止被抢占，内核禁止其在中断上下文中执行下列操作：

- 占用互斥体
- 进入睡眠
- 执行耗时长的任务
- 访问用户空间
- 不允许中断处理例程被递归或并行调用
- 中断处理例程 **可以被更高级别 IRQ 中断**

常见的一个例子是：A 进程期待一个 I/O 写完成中断，实际在 B 进程执行、A 进程睡眠时发生。此时的中断信号打断 B 进程，唤醒 A 进程。

## Linux Kernel 的上下文切换 context_switch 实现

Linux Kernel 的上下文切换需要详细了解 Linux 内核调度器，迫于时间压力，先暂时把内核源码放在这里，有时间的话在慢慢深究。

[kernel/sched/core.c Line 2859: context_switch](https://elixir.bootlin.com/linux/v5.0.6/source/kernel/sched/core.c#L2859)

[include/linux/sched.h Line 72: task_struct](https://elixir.bootlin.com/linux/latest/source/include/linux/sched.h)

# Reference

#### 各类博客

https://www.cnblogs.com/openix/archive/2013/03/09/2952057.html
https://www.21qa.net/questions/167/167
http://www.cnblogs.com/Anker/p/3269106.html
https://blog.csdn.net/zqixiao_09/article/details/50877756
https://blog.csdn.net/gatieme/article/details/51872659
http://blog.sungju.org/2015/11/17/whats-virtual-address-limit-of-32bit64bit-linux-kernel-2/
http://compgroups.net/comp.lang.asm.x86/privilege-levels-1-and-2/162524
https://blog.csdn.net/baidu_17062867/article/details/37744863

#### 专业的问答网站和第三方文档

https://linux-kernel-labs.github.io
https://stackoverflow.com/questions/19349572/why-do-we-need-virtual-memory
https://en.wikipedia.org/wiki/Virtual_memory
https://support.symantec.com/en_US/article.TECH244351.html
https://en.wikibooks.org/wiki/The_Linux_Kernel/Memory
http://tldp.org/HOWTO/KernelAnalysis-HOWTO-7.html
https://stackoverflow.com/questions/6710040/cpu-privilege-rings-why-rings-1-and-2-arent-used
https://unix.stackexchange.com/questions/87625/what-is-difference-between-user-space-and-kernel-space
https://en.wikipedia.org/wiki/Context_switch
https://www.quora.com/Does-context-switching-happen-in-the-the-kernel-mode

#### Linux 内核源代码

https://elixir.bootlin.com/linux/v5.0.6/source

引用的图片和文字版权归原作者所有
