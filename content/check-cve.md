---
title: "cve check"
author: Neal
tags: [python]
categories: [安全开发]
date: "2019-07-04" 
---

今天想检查一下 Gitlab 11.9.0 产品受哪些 cve 的影响。其实网上已经有很多网站可以查询产品的相关 cve，但就是粒度比较粗。我想在 cve 列表中筛选出特定的版本，已经特定的版本，比如是社区版还是旗舰版。找了一下，没有发现完全符合这个要求的。后来在网上我就看到了一个网站是可以提供 cve 的 API 查询的。可以通过网站 API 可以获取特定的数据。

可以通过 https://cve.circl.lu/api/ 可以看到 API 文档。可以通过 cve id 以及 product 以及其他更多信息来查询。最有用的 API 就是这一个，

![ZUIwgH.png](https://s2.ax1x.com/2019/07/04/ZUIwgH.png)

可以通过 vendor 以及 product 获取指定 vendor 和 product 的