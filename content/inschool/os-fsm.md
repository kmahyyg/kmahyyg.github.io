---
title: 操作系统原理 - 有限状态机
description: "有限状态机的基础概念的一些思考"
date: 2019-04-07T20:05:37
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_school.webp"
categories: ["school"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

## 前言

本学期的重点之一就是这一门操作系统课程。这个系列的文章会一直坚持写下去，记录我在学习过程中不断探索、询问的过程。

今天是这个系列的第一篇文章，讲述有限状态机，有限状态机为后面的多线程与进程调度做下铺垫。

本系列的所有文章的代码均在 GNU GCC 8.2.1 下编译通过，本地使用的 Linux Kernel 为 5.0.6 及以上版本，跟随 Arch Linux 稳定 core 仓库更新。 **不提供 Windows 支持。**

# 正文

## 定义

![FSM RYF](https://alicdn.kmahyyg.xyz/asset_files/fsm_01_ryf.webp)

定义：有限状态机（英语：finite-state machine，缩写：FSM）又称有限状态自动机，简称状态机，是表示有限个状态以及在这些状态之间的转移和动作等行为的数学模型。

简单说，它有三个特征：

- 状态总数（state）是有限的。
- 任一时刻，只处在一种状态之中。
- 某种条件下（当前 state + 特定 event），会从一种状态转变（transition）到另一种状态。

对，就是这么简单。

## FSM 的几种实现

### if+else 实现

大量的 `if` `else if` `else` 语句，程序简单易懂，但是代码执行效率不高，过于低端的同时造成了代码膨胀。如果状态的较少可以采用，但如果状态很多，就非常难受了。这类实现是我们这类初学者经常采用的。

### case+switch 实现

```c
switch(state){
    case status1:
        dosth();
        state = status2;
        break;
    case status2:
        dosth2();
        state = status3;
        break;
        ...
    default:
        printf("error");
        break;
}
```

这样的实现较上一种实现方法看起来简洁很多，代码执行效率有所提高，但主要存在两个问题：（1）规模难以扩大和维护  （2）忘写 `break;` 可能造成灾难性后果。所以也不推荐在大型项目或者操作系统层面使用。

### FSM 表实现

使用函数指针实现 FSM 的思路：建立相应的状态表和动作查询表，根据状态表、事件、动作表定位相应的动作处理函数，执行完成后再进行状态的切换。

当然使用函数指针实现的 FSM 的过程还是比较费时费力，但是这一切都是值得的，因为当你的程序规模大的时候，基于这种表结构的状态机，维护程序起来也是得心应手。


```c
#include <stdio.h>
#include <unistd.h>

void haltmc() {  // define what to do when triggered
    printf("Machine halted...\n");
}

void pwron() {
    printf("Powered on.\n");
}

void postchk() {
    printf("POST Successfully finished. Hardware OK!\n");
}

void start_os() {
    printf("Trying to boot up with kernel...\n");
    printf("Kernel prepared for calling up DE...\n");
}

void user_clickoff() {
    printf("DE called up and running smoothly.\n");
    sleep(3);
    printf("User clicked to power off...\n");
    printf("Software stopped...Disassembling stacked devices...\n");
    haltmc();
}

enum {
    POWER_ON,
    POST,
    INITIALIZE,
    USER_TURN_OFF,
};   // EVENTS

enum {
    POST_DONE,
    STARTED,
    USER_OFF,
    HALTED
}; // STATUS

typedef struct fsmtb_s {
    int event;
    int currstatus;
    void (*dosth)();
    int nextstatus;
} fsmtb_t, *fsmtb_ptr;   // fsm status table

fsmtb_t PCRUN[] = {
        // coming event, current status, to do sth, next status
        {POWER_ON,      HALTED,       pwron,         POST_DONE},
        {POST,          POST_DONE,    postchk,       STARTED},
        {INITIALIZE,    STARTED,      start_os,      USER_OFF},
        {USER_TURN_OFF, USER_OFF,     user_clickoff, HALTED},
};

typedef struct fsm_s {
    fsmtb_ptr fsm_status_tb;
    int currstatus;
}fsm_t, *fsm_ptr;    // machine status

int max_state_tb;   // max status in the status table

void initMC(fsm_ptr machine){
    max_state_tb = sizeof(PCRUN) / sizeof(fsmtb_t);
    machine->currstatus = HALTED;
    machine->fsm_status_tb = PCRUN;   // link status table to machine
}

void FSMNext(fsm_ptr machine, int state){
    machine->currstatus = state;
}

void FSMHandle(fsm_ptr machine, int event){
    fsmtb_ptr actTable = machine->fsm_status_tb;   // bind the whole status
    void (*eventAct)() = NULL;   // init a do something function ptr
    int nextStatus;
    int currentStatus = machine->currstatus;
    int done = 0;
    for (int i = 0; i < max_state_tb; i++){
        fsmtb_ptr currentActTable = &actTable[i];   // trying to recursive read the status table
        // and check if the status and event is corresponding: if true, dosth()
        if (event == currentActTable->event && currentStatus == currentActTable->currstatus){
            done = 1;
            eventAct = currentActTable->dosth;
            nextStatus = currentActTable->nextstatus;
            break;
        }
    }

    if (done){   // if status-event pair is satisfied
        if (eventAct){  // if action is not null
            eventAct();
        }
        FSMNext(machine, nextStatus);   // if done, transfer to next status
    }
    else {
        void;   // do nothing
    }
}

void gogogo(int *evnt){   // manually trigger the event
    if (*evnt == 3){*evnt = 0;}
    else {(*evnt)++;}
}

int main(){
    fsm_t machine;
    initMC(&machine);
    int startevnt = POWER_ON;
    while (1){
        // printf("EVENT 0: 开机, 1: 自检，2：加载，3: 用户关闭 \n");
        printf("----------------------------------\n");
        printf("Event %d is coming...\n", startevnt);
        FSMHandle(&machine, startevnt);
        // printf("STATUS 0: 自检完成，1: 开机运行，2: 用户关闭，3: 已关闭\n");
        printf("Current Status is %d...\n", machine.currstatus);
        printf("----------------------------------\n");
        gogogo(&startevnt);
        sleep(2);
    }
    return 0;
}
```

阅读代码可以看出，当且仅当在指定的状态下来了指定的事件才会发生函数的执行以及状态的转移，否则不会发生状态的跳转。这种机制使得这个状态机不停地自动运转，有条不絮地完成任务。

与前两种方法相比，使用函数指针实现FSM能很好用于大规模的切换流程，只要我们实现搭好了FSM框架，以后进行扩展就很简单了（只要在状态表里加一行来写入新的状态处理就可以了）。

### Reference

https://www.ruanyifeng.com/blog/2013/09/finite-state_machine_for_javascript.html
https://zh.wikipedia.org/wiki/%E6%9C%89%E9%99%90%E7%8A%B6%E6%80%81%E6%9C%BA
http://www.cnblogs.com/skyfsm/p/7071386.html
https://github.com/AstarLight/FSM-framework

图片版权归原作者所有
