---
title: "如何用latex画一个简单的表格"
author: Neal
description: "latex毫无疑问是一个十分强大的论文写作工具，所以掌握它就显得非常有意义，讲一下如何画一个简单的表格，代码如下： "
tags: [latex]
categories: [论文写作]
date: "2015-09-26 08:40:35"
---
latex毫无疑问是一个十分强大的论文写作工具，所以掌握它就显得非常有意义，讲一下如何画一个简单的表格，代码如下：
\begin{table}
\centering
\begin{tabular}{||c|c||}
\hline
algorithm & time complexity\\
\hline
RM-MEDA & O(NM)\\
\hline
IRM-MEDA & O(NK)\\
\hline
\end{tabular}
\caption{The time complexity comparing result}
\label{TAB1}
\end{table}
呈现的效果如下：
![这里写图片描述](http://img.blog.csdn.net/20150926083944494)
是不是很简单

欢迎搜索微信号 mad_coder 或者扫描二维码关注公众号：

![93cfyj.jpg](https://user-gold-cdn.xitu.io/2018/2/10/1617eae1b59c001c?w=258&h=258&f=jpeg&s=27683)