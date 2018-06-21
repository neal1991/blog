---
title: "Wmic 使用中的一些问题"
author: Neal
description: "我们作为 Elasticsearch 核心开发人员团队希望尽可能快地向可靠，健壮，安全，可扩展且易于使用的系统迁移。我们希望为创新而努力，取代传统的构造和功能，删除脆弱的代码，并致力于改善用户体验，同时在我们快速变化的同时保持用户增长。"
tags: [elastic, 团队, 翻译]
categories: [windows]
date: "2018-06-21"
---

Wmic, 即 Windows Management Instrumentation Command-Line Utility，通过这个工具我们可以获取计算本地的很多信息。

## 起源

我起初是希望写一个 bat 脚本来获取计算机安装的程序和功能列表以及计算机最近大的一些补丁信息。程序和功能列表以及补丁信息可以通过计算机的控制面板去查看，但是这样一点都不 geek，能用脚本解决的当然要用脚本去解决啦。

## 程序和功能

通过 `wmic product` 我们可以获取程序和功能的安装信息。
