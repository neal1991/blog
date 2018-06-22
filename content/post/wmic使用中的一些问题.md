---
title: "Wmic 使用中的一些问题"
author: Neal
description: "Wmic, 即 Windows Management Instrumentation Command-Line Utility，通过这个工具我们可以获取计算本地的很多信息。"
tags: [wmic, windows]
categories: [windows]
date: "2018-06-21"
---

Wmic, 即 Windows Management Instrumentation Command-Line Utility，通过这个工具我们可以获取计算本地的很多信息。

## 起源

我起初是希望写一个 bat 脚本来获取计算机安装的程序和功能列表以及计算机最近大的一些补丁信息。程序和功能列表以及补丁信息可以通过计算机的控制面板去查看，但是这样一点都不 geek，能用脚本解决的当然要用脚本去解决啦。

## 程序和功能

通过 `wmic product` 我们可以获取程序和功能的安装信息。

`wmic product get name,description`

这样我们就可以获取计算机上安装的程序和功能列表以及其相应的描述。当然除了 `name` 以及 `description` 之外我们还可以使用 `vendor` 以及 `version` 来获取程序的厂商名称以及对应的版本号。另外，如果我们希望把结果导入到 txt 文件中，我们还可以使用万能的管道符号：

`wmic product get name, description > products.txt`

这样我们就可以获取结果的 txt 文件，是不是很方便。然而，当我们将使用 `wmic` 导出的结果和控制面板中的程序和功能相比较的话，我们会发现有些程序没有出现在结果中，比如 Google Chrome。

通过 `wmic` 只能获取大部分程序列表，它们的安装包一般都是使用 Windows Installer 制作的，安装过程中调用 Windows Installer 服务进行安装。但是 Windows Installer 并不是唯一的制作安装包的工具，因此 `wmic` 往往可能获取的还不是完整的程序和功能列表。至于完整的程序和功能列表，可以参考[这篇文章](http://www.4hou.com/technology/10206.html)。

## 补丁信息

经常我们需要获取计算机的补丁安装情况。通过 `systeminfo` 可以获取一部分补丁安装信息，但是信息一般比较少。在这里，我们依然可以通过使用 `wmic` 来获取补丁安装信息。

`wmic qfe list full`

这样我们就可以获取补丁的安装的相关信息了，但是这样的结果可能看起来不是很直观，所以我们还可以进行相应的格式化。`wmic qfe list full /format:table`，这样就可以把结果以表格的形式展现出来。加入我们还希望将结果导出来，我们可以将其导出比较好看的 html 表格形式：`wmic qfe list full /fomrmat:htble > qfe.html`。

如果不希望在结果中显示所有的字段，可以使用 `wmic qfe list brief` 或者 使用 `wmic qfe get hotfixid,installedon` 获取希望展示的字段。还可以使用其他的字段，比如 `description`, `installedby` 等等。
