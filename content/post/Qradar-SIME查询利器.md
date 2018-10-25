---
title: "Qradar SIEM--查询利器 AQL"
author: Neal
description: ""
tags: [siem, 安全]
categories: [安全]
date: "2018-10-26"
---

对于 SIEM 平台来说，好用的查询方式非常重要。之前有体验基于 ELK 搭建的平台，在 kibana 上面是可以通过一些 filter 来做一些过滤并且是支持 lucene 的语法，包括一些简单的逻辑查询以及 wildquery 等等。但是的确是在做一些汇聚之类时不是很方便，一般需要通过 json 来创建查询语句。后来好像也有转 SQL 之类的插件，但我也没有使用过，总的来说体验比较一般。

Qradar 是一款比较成熟的商业 SIEM 平台（尽管他们的 BUG 一大堆，但架不住别的更差啊），基本上也是属于业界 TOP 5。商业产品的好处就是不用自己太折腾，搞搞就可以用，缺点就是贵。AQL（Ariel Query Language）是 Qradar 中的一种查询语言，与普通的 SQL 的语句类似，但是阉割了一些功能也增加了一些功能。以下是 AQL 的基本流程：

![iyJDmD.png](https://s1.ax1x.com/2018/10/25/iyJDmD.png)

可以看出 AQL 是一种非常类似于 SQL 的语言，所以基本上你用过 SQL 学会 AQL 也就分分钟的事情，而且你也不会拿它去做特别复杂的嵌套查询（因为它也不支持。。。）

