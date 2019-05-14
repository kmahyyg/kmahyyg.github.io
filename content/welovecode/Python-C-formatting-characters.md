---
title: Python struct.pack() formatting characters
date: 2018-04-29T19:56:00
description: "Python 2 的占位模板符"
featuredImage: "https://alicdn.kmahyyg.xyz/asset_files/aether/cat_code.webp"
categories: ["code"]
draft: false
displayInMenu: false
displayInList: true
dropCap: false
---

Formatting Characters from [Python Referrence](https://docs.python.org/2/library/struct.html)


| Format | C Type               | Python type        | Standard size | Notes    |
| ------ | -------------------- | ------------------ | ------------- | -------- |
| `x`    | pad byte             | no value           |               |          |
| `c`    | `char`               | string of length 1 | 1             |          |
| `b`    | `signed char`        | integer            | 1             | (3)      |
| `B`    | `unsigned char`      | integer            | 1             | (3)      |
| `?`    | `_Bool`              | bool               | 1             | (1)      |
| `h`    | `short`              | integer            | 2             | (3)      |
| `H`    | `unsigned short`     | integer            | 2             | (3)      |
| `i`    | `int`                | integer            | 4             | (3)      |
| `I`    | `unsigned int`       | integer            | 4             | (3)      |
| `l`    | `long`               | integer            | 4             | (3)      |
| `L`    | `unsigned long`      | integer            | 4             | (3)      |
| `q`    | `long long`          | integer            | 8             | (2), (3) |
| `Q`    | `unsigned long long` | integer            | 8             | (2), (3) |
| `f`    | `float`              | float              | 4             | (4)      |
| `d`    | `double`             | float              | 8             | (4)      |
| `s`    | `char[]`             | string             |               |          |
| `p`    | `char[]`             | string             |               |          |
| `P`    | `void *`             | integer            |               | (5), (3) |
