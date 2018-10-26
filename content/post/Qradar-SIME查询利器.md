---
title: "Qradar SIEM--查询利器 AQL"
author: Neal
description: ""
tags: [siem, 安全]
categories: [安全]
date: "2018-10-26"
---

对于 SIEM 平台来说，好用的查询方式非常重要。之前有体验基于 ELK 搭建的平台，在 kibana 上面是可以通过一些 filter 来做一些过滤并且是支持 lucene 的语法，包括一些简单的逻辑查询以及 wildquery 等等。但是的确是在做一些汇聚之类时不是很方便，一般需要通过 json 来创建查询语句。后来好像也有转 SQL 之类的插件，但我也没有使用过，总的来说体验比较一般。

## Qradar

Qradar 是一款比较成熟的商业 SIEM 平台（尽管他们的 BUG 一大堆，但架不住别的更差啊），基本上也是属于业界 TOP 5。商业产品的好处就是不用自己太折腾，搞搞就可以用，缺点就是贵。AQL（Ariel Query Language）是 Qradar 中的一种查询语言，与普通的 SQL 的语句类似，但是阉割了一些功能也增加了一些功能。以下是 AQL 的基本流程：

![iyJDmD.png](https://s1.ax1x.com/2018/10/25/iyJDmD.png)

可以看出 AQL 是一种非常类似于 SQL 的语言，所以基本上你用过 SQL 学会 AQL 也就分分钟的事情，而且你也不会拿它去做特别复杂的嵌套查询（因为它也不支持。。。）

## Tips

虽然 AQL 终于让我们有枪可以搞一搞了，但是还是有一些地方值得吐槽的地方。第一就是很多 ID 不知道其具体的映射，就比如我们想查询一些事件的名称或者规则的名称，AQL 是不存在字段名是事件名称或者规则名称的。不过你可以通过函数来进行转换，比如使用 `QIDNAME(qid)` 来获取事件名称，`RULENAME(123)` 来获取规则名称。你没办法知道事件名称或者规则名称到底是对应什么 ID，目前我用的办法就是先去 IBM Develop API 里面先去查询。第二，AQL 查询的结果我发现有某个规则的查询结果和用 filter 查询的结果不一致，不知道这是不是特例。还有其他的，想到再说。

下面就是我在使用过程中一些小经验：

### 引号的使用

在 AQL 中，单引号和双引号的使用是有区别的。单引号一般可以表示字符串或者作为字段的别名，如果你的字段包含了空格，那么你必须使用单引号。双引号一般用来表示自定义属性的名称。还有一个值得注意的地方就是，但你在使用 `WHERE, GROUP BY, ORDER BY` 的时候，你必须要使用双引号来使用别名，而不是单引号，是不是有点绕。其实有个好的方法就是不要使用单引号了，直接使用帕斯卡命名或者使用下划线连接，比如 `EventName` 或者 `Event_Name`，其实你自己想怎么命名都可以啦。

### Rule 的匹配

Qradar 里面有很多内置的规则并且你能够自己定义特定的规则。其实对于某个 rule 来说，也是有特定的 rule ID 的，即 creeventlist，如果某个 rule 的 creeventlist 是 123，那么我们可以通过以下语句来找到这个 rule:

```sql
SELECT RULENAME(creaeventlist) FROM events
WHERE creeventlist = 123
```

## 场景案例

根据我的理解，Qradar 所有的查询归根到底应该都是通过 AQL 来实现的，但是官方并没有提供将普通的查询转换成 AQL 语句的工具。之前我有一些场景想通过 AQL 来实现，但是 IBM 的人说无法实现（此处应有吐槽），后来还是得靠自己来实现。

### 某 IP 某事件发生的时间大于特定的值

可能说起来有那么一点点绕，但这个场景还是蛮有必要的。因为经常有一些安全事件很长时间都没有即是处置，那我们如何将这些事件捞出来呢。即该事件（sourceip 指定）的第一次出现的时间和最近出现一次的时间的时间间隔大于特定的指，那么我们就可以通过这样的语句来把这样的事件找出来了。

```
SELECT QIDNAME(qid) AS EventName, MIN(starttime) AS FirstTime, MAX(starttime) AS LastTime
FROM events
WHERE LastTime - FirstTime > xxxx
GROUP BY sourceip,EventName
```

### 查询当前月份的事件

IBM 与日期相关的函数主要就是4个，即 `LAST, START, STOP, NOW`。日期实现的逻辑太单一了，你只能指定具体的起始时间以及终止时间或者是 `LAST 1 DAYS` 这种。但是有一个非常普遍的场景就是我需要知道当前月份的情况，这就无法通过这几个关键词直接来实现，因为 `Current Month IS NOT LAST 30 DAYS`.那么我们需要介绍一个函数 `DATEFORMAT`,通过这个函数我们可以将时间转化为字符串类型，结合 `NOW` 以及 `START, STOP` 函数，既可以实现。

```flow
st=>start: 使用 NOW 获取当前时间
op1=>opration: 将获取的时间
```
