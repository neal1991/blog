---
title: "Logstash 技巧之处理不同的 output"
author: Neal
tags: [ELK, Logstash]
keywords: [插件, logstash]
categories: [工具]
date: "2020-05-18" 
---

之前在用 Logstash 遇到了一个棘手的小问题，一直没找到好的解决方案，后来找到了一个有用的插件，分享一下。场景是这样的，Logstash 有两个 output，一个是 output 到 Kafka，另外一个则是 ES。但是对于 Kafka，希望能够移除日志中的 @timestamp 字段，对于 ES 则希望能够进行保留。

![YWmZlt.png](https://s1.ax1x.com/2020/05/18/YWmZlt.png)

在 filter 里面，其实可以使用 mutate 插件来修改字段的，但是在 output 里面，我没有找到有什么办法可以来进行区分。这个问题困扰了很长时间，直到别人告诉我一个新的插件，clone。通过 clone 插件，可以将事件备份一份，并且进行相应的处理。
