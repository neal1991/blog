---
title: "latex中large的作用域问题"
author: Neal
description: "在毕业论文的写作过程中，遇到了一个\large 作用域的问题。假设下面有三种写法：I am cool \large{you are right}, yeah, yeah, yeah
I am cool {\large you are right}, yeah, yeah, yeah
I am cool 
\begin{large}
you are right
\end{large}, yeah, y"
tags: [latex]
catefories: [论文写作]
date: "2017-01-06 22:09:53"
---
在毕业论文的写作过程中，遇到了一个`\large` 作用域的问题。假设下面有三种写法：
```[latex]
I am cool \large{you are right}, yeah, yeah, yeah
I am cool {\large you are right}, yeah, yeah, yeah
I am cool 
\begin{large}
you are right
\end{large}, yeah, yeah, yeah
```
我们希望的结果是you are right，这三个单词可以放大，而其他的文字仍然是正常大小，那么以后三个哪些是正确的呢？
下面且看这三个命令的分别显示结果：
![large1](http://img.blog.csdn.net/20170106220409363?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbmVhbDE5OTE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![large2](http://img.blog.csdn.net/20170106220438270?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbmVhbDE5OTE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![large3](http://img.blog.csdn.net/20170106220457091?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbmVhbDE5OTE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
很明显可以看的出来，第二个和第三个是正确的，而第一个不是正确的。第一个后面的文字都受到了前面`\large` 的影响，也变成了放大的字体。这就是`\large`的作用域问题，第一条命令并没有限制好作用域。可以看的出来，应该要把命令放在花括号中。第三种写法也是可以工作的，像一般的环境都是有这种写法的，但是这种写法比较麻烦，不是特别推荐。
