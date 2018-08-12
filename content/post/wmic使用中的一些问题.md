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

我起初是希望写一个 bat 脚本来获取计算机安装的程序和功能列表以及计算机最近安装的一些补丁信息。程序和功能列表以及补丁信息可以通过计算机的控制面板去查看，但是这样一点都不 geek，能用脚本解决的当然要用脚本去解决啦。

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

![htable.png](http://ozfo4jjxb.bkt.clouddn.com/htable.png)

如果不希望在结果中显示所有的字段，可以使用 `wmic qfe list brief` 或者 使用 `wmic qfe get hotfixid,installedon` 获取希望展示的字段。还可以使用其他的字段，比如 `description`, `installedby` 等等。

这样获取的是完整的补丁列表，如果仅仅希望获取2018年的补丁安装信息该怎么做呢？ Wmic 还支持 `where` 关键词来查询：

`wmic qfe where "installedon like '%/%/2018'" list brief`

这样就可以获取2018年内安装的补丁信息列表。但是很奇怪的一件事情就是这句话在命令行中执行是没有什么问题的，但是在 bat 脚本中执行这句话的时候，总是提示 `No Instance(s) Available.`。一开始我一直以为是 `where` 关键词有问题或者是 `wmic` 的问题。尝试使用：

`wmic path win32_quickfixengineering where (installedon like "%/%/2018") list bief`

同样地，这句话在命令中可以执行，但是在 bat 脚本中还是同样的问题。另外也排除了 `where` 关键词影响的可能性。最后才发现问题在于 `%` 上，因为在 bat 脚本中，% 有多种用途，在这里如果我们希望表示原始的 %，那么我们应该使用 %% 来表达，因此：

`wmic qfe where "installedon like '%%/%%/2018'" list brief`

## More

当然关于 wmic 还有很多更高阶的玩法。比如，就有 WMI Query Language 能够提供查询功能，有点类似于 SQL，部分关键字是一样的，比如常见的 where 以及 select。可以在一些工具中使用 WQL 语法，比如在运行中输入 `wbemttest` 就可以打开 wmi 的测试工具。

![wbemtest.png](http://ozfo4jjxb.bkt.clouddn.com/wbemtest.png)

在本地连接之后，就可以通过查询语句来查询一些信息了。比如，`select * from win32_process` 就可以看到一些进程相关的信息。关于测试工具的更过用法，参考[这篇文章](https://www.codeproject.com/Articles/46390/WMI-Query-Language-by-Example)。

关于 wmi 的更多用法，可以参考[微软的官方文档](https://msdn.microsoft.com/en-us/library/aa394572(v=vs.85).aspx)。


