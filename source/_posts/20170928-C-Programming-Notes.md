---
title: C Programming Notes
date: 2017-09-28 16:40:07
tags:
---

# Define a string var using char.

In C , string var is not like the python.
You have to declare it first , then make a pointer to the exact string.

Ref1 : https://stackoverflow.com/questions/8732325/how-to-declare-strings-in-c
Ref2 : https://stackoverflow.com/questions/4337217/difference-between-signed-unsigned-char
Ref3 : https://stackoverflow.com/questions/3862842/difference-between-char-str-string-and-char-str-string

At the end of each string , the system will add "\0" at the end. You could use ``` sizeof() ``` func to show its length.

Example Code:  see practice_c2.c

Use %s to fill the blank instead of %c , otherwise you will get an error notification from both the compiler and the Clion IDE.

# Other things

For more details , plz see https://github.com/kmahyyg/learn_cprimer_plus
All related notes are placed there in order to sync with the cloud convenniently.