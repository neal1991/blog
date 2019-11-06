---
title: "被动扫描器之插件篇"
author: Neal
tags: [安全, web 安全, chrome 插件]
categories: [安全]
date: "2019-09-28" 
---

最近被动扫描器的话题如火如荼，好多公司都在做自己的被动扫描器。而获取质量高的流量是被动扫描器起作用的关键。笔者主要开发了两个被动扫描器的插件，[r-forwarder](https://github.com/neal1991/r-forwarder) 以及 [r-forwarder-burp](https://github.com/neal1991/r-forwarder-burp)，两个插件的代码都在 Github 上开源。两个插件分别为 Chrom 插件以及 Burp 插件，本文也从笔者开发这两个插件的经验来聊一聊被动扫描器中插件的开发。

## Chrome 插件

Chrome 插件是向 Chrome 浏览器添加或修改功能的浏览器拓展程序。一般通过 JavaScript, HTML 以及 CSS 就可以编写 Chrome 插件了。市面上有很多非常优秀的 Chrome 插件拥有非常多的用户。Chrome 插件的编写也比较简单，基本上你熟悉一点前端知识，然后熟悉一下 Chrome 插件的 API，你就可以编写 Chrome 插件。Chrome 插件的安装，如果你没有发布在 Chrome 商店的话（因为网络原因，可能没办法直接从商店下载），可以通过开发者模式安装 Chrome 插件。或者你也可以注册 Chrome 插件的开发者账号（只需要 5 美元，做多可以发布 20 个拓展）。

简单地介绍了一下 Chrome 插件的开发，咱们主要还是聊一下关于 Chrome 插件关于被动扫描器的方面的内容。对于 Chrome 插件，主要是通过插件的能力去获取经过浏览器的流量，并将流量转发给后端来进行处理。Chrome 插件关于网络流量的处理地 API 主要有两个：[chrome.devtools.network](https://developer.chrome.com/extensions/devtools_network) 以及 [chrome.webRequest](https://developer.chrome.com/extensions/webRequest)。但是前者使用的时候需要打开 Chrome 开发者工具，这个有一点不太方面，所以选择了后者，这也是对于被动流量获取一种常见的方式。

Chrome 插件中的 webrequest API 是以相应的事件驱动的，其中请求的生命周期图如下，主要有7个事件。只需要监听关键事件进行处理就可以满足被动扫描器获取流量的需求了。

![Mi0arD.png](https://s2.ax1x.com/2019/11/06/Mi0arD.png)

其实这些事件不难理解，基本通过事件的名称就可以知道事件的含义了，主要就是请求发送前，发送请求头之前，发送请求头等等事件。对于不同的事件，可以获取的流量数据也是不尽相同的。首先，考虑一下，对于被动扫描器来说，哪些流量数据是比较关心的。被动扫描器主要是通过收集业务的正常流量来进行测试，提高测试的效率，并能取得比主动扫描器更好的效果。那么一般来说，被动扫描器最关心的就是请求的 URL 以及请求头了，如果是 POST 请求，还需要请求体。对于扫描器来说，响应头和响应体则没那么重要，其实可以通过响应状态过滤一下，一般只需要能够正常响应的请求头以及请求体即可。



## 总结




