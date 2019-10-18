---
title: "Kibana 任意代码执行漏洞"
author: Neal
tags: [Kibana,漏洞,安全]
categories: [安全]
date: "2019-10-17"
---

今日，有人公开了 Kibana 任意代码执行漏洞（CVE-2019-7609）的 POC。这个漏洞的主要原理是因为 Kibana 中的 Timelion 中具有原形链污染漏洞，因此可以导致指定变量的原型链污染，通过传递 NODE 环境变量参数，利用 Kibana 的 Canvas 会创建新进程的特性可以达到远程执行命令的效果。

在本地尝试搭建环境复现，忙活了半天，一开始尝试的是 6.4.2 版本的 Kibana。尝试执行命令的时候，发现一直没有效果，才发现这个漏洞的利用还有一个重要的环节。在导致原型链污染之后，还需要点击 Canvas 菜单，因为点击 Canvas 菜单，Kibana 会尝试创建一个新的进程，从而可以达到远程命令执行的效果。不过在 Kibana 6.5 版本之前，Canvas 不是默认安装在 Kibana 中的。可以通过 kibana-plugin 去安装 Canvas 插件，不过我后来还是选择使用 6.5.4 版本，同时注意相应 elasticsearch 也需要升级到 6.5.4 版本。最后在使用反弹命令的时候，遇到了一点问题，可能与机器系统版本相关，可以多尝试几种命令。

漏洞的利用过程其实不是特别复杂，注意几点即可：

1. 漏洞的影响的版本是 5.6.15 版本以及 6.6.1 版本以前。
2. Kibana 需要安装了 Canvas 插件。
3. 目前公开的 POC 因为使用了 linux 特有的环境变量，所以目前这个 POC 只能作用于 linux 机器。

![KecZYd.png](https://s2.ax1x.com/2019/10/18/KecZYd.png)

## 原型链攻击

如果熟悉 JavaScript 的同学，对于原型链应该会比较熟悉。传统的 JavaScript 对象的集成就是基于原型链实现的。如果可以利用程序漏洞可以去修改 Object.protootype 就会导致所有的 JavaScript 的变量收到影响。针对本次漏洞，修复方式就是通过 hasOwnProperty 方法可以确保直接通过 __proto__ 属性直接去修改 prototype。

![Kernqe.png](https://s2.ax1x.com/2019/10/18/Kernqe.png)

原型链攻击现在一般虽然不能直接用于攻击，但是一般配合系统功能可以达到一些运行恶意命令的效果。如果一个程序有原型链漏洞，并且这个程序会创建新的进程，那么这个程序就极有可能有远程命令执行漏洞。

## 漏洞防范

1. 及时升级 Kibana 版本。
2. Kibana 增加用户授权访问。

## Reference

* https://slides.com/securitymb/prototype-pollution-in-kibana/