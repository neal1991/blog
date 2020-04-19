---
title: "让你的SQL盲注快起来"
author: Neal
tags: [安全, web 安全]
keywords: [安全, web 安全, sql injection, sql 注入, 与运算, 暴力破解]
categories: [安全]
date: "2020-03-30" 
---

本文首发于 Freebuf 平台，https://www.freebuf.com/articles/web/231741.html

SQL 注入是当前 Web 安全中最常见的安全问题之一，其危害性也比较大，众多白帽子在渗透测试过程中往往会首先着重进行 SQL 注入的测试。盲注是 SQL 注入的重要的技术之一，在现实中的  SQL 注入案例中，往往很难将注入的结果直接回显出来。因此，盲注也就成为了 SQL 注入必不可少的手段之一。本文想分享一个如何大大提升盲注效率的技巧。

与或运算
与或运算，操作符分别为 & 以及 |，大多数人应该会在实际开发过程中很少使用到与或运算。如果你之前学过计算机组成原理，里面讲了很多关于补码、反码以及各种运算。当然，我们这里不需要理解那么多知识，这里我们只需要理解与或运算就可以了。

与运算
运算规则： 0 & 0 = 0; 0 & 1 = 0; 1 & 0 = 0; 1 & 1 = 1

即：两位同时为“1”，结果才为“1”，否则为0

或运算
运算规则：0 | 0 = 0; 0 | 1 = 1; 1 | 0 = 1; 1 | 1 = 1

即：参加运算的两个对象只要有一个为1，其值为1

假设参与运算的2个数据，一个数据是1，那么另外一个的值就可以确定了，假设另外一个值为 x：

1 & x = 0,  x = 0

1 & x = 1,  x = 1

所以通过与运算，假设其中的一个数据是已知的，那么另外的值就很好确定了。

通过与运算盲注

![JuhTS0.png](https://s1.ax1x.com/2020/04/19/JuhTS0.png)

看到这里，你可能还是一头雾水，与运算和盲注有啥关系？假设一个数字 104，我们可以将它转化为二进制，即 `104 = 64 + 32 + 8 = 2 ^ 6 + 2 ^ 5 + 2 ^ 3`，我们可以将它以比特位的形式将它表示出来：

![JuhOw4.png](https://s1.ax1x.com/2020/04/19/JuhOw4.png)

那么我们可以将104与 `1，2，4，8，16，32，64，128` 进行与运算，就可以获得每个比特位上的数据。

与1进行运算

![Ju4k0e.png](https://s1.ax1x.com/2020/04/19/Ju4k0e.png)

和2进行与运算

![Ju4ZtA.png](https://s1.ax1x.com/2020/04/19/Ju4ZtA.png)

和4进行与运算

![Ju4efI.png](https://s1.ax1x.com/2020/04/19/Ju4efI.png)

通过这样的方式，我们就可以确定104每个比特位上的数据是什么。那这和我们SQL盲注又有什么关系呢？对于SQL盲注，我们往往会使用到 substring，我们会对结果的每一个字符来进行枚举，将字符与可能字符来进行比较，这样枚举的效率可能会不太好，往往需要比较很多次。对于一个 acsii 字符，其范围是在0-127之间，那么只需要7个比特位就足够了。那么如果使用与运算的方式，我们只需要比较7次就可以确定这个字符的 ascii 码。通过与运算的方式，可以显著地提高效率，减少比较次数，而且往往字符越多，提升的效果就越明显。

![Ju4MX8.png](https://s1.ax1x.com/2020/04/19/Ju4MX8.png)

Talk is cheap, show me the code. 这里我们通过 python 的方式来实现：

```python
def compute_by_and(word):
    for ele in word:
        ele_b, times = get_character(ele)
        print(f"Guess the value {ele_b}:{chr(ele_b)} with {times} times")

def get_character(char):
    char_b = ord(char)
    value = 0
    times = 0
    for i in range(7):
        times = times + 1
        if char_b & (2 ** i):
            value = value + (2 ** i)
    return value, times

if name == "main":
    compute_by_and("hello")
```

很明显，每一个字符仅仅只需要7次比较就可以知道这个字符是什么字符了。如果没有数据支撑，这个结果可能对比不是很明显，那我们可以通过其与普通的枚举方式来进行对比，我们选取3个字符来进行对比，`myapp,myapp_card,myapp_card_perform`。我们枚举的方式选取 `string.printable`，这个也包含了所有的 ascii 字符。

```python
import string

def brute_force(word):
    times = 0
    for ele in word:
        for c in string.printable:
            times = times + 1
            if ele == c:
                break
    print(f"Brute force {word} with {times} times")

if name == "main":
    brute_force("hello_world")
```


                myapp            	                myapp_card            	                myapp_card_perform            
                枚举            	                121            	                276            	                526            
                与运算            	                35            	                70            	                126            

# 总结

通过上面的对比，我们可以看出在SQL盲注中，如果通过与运算来进行盲注，可以大大提升盲注的效率，减少请求的次数，这对于我们的测试的帮助意义还是比较大的。