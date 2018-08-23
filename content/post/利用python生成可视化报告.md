---
title: "利用 python 生成可视化报告"
author: Neal
description: ""
tags: [python, 可视化]
categories: [python]
date: "2018-08-16"
---

Python 作为一种常用的胶水语言，可用于各种用途。最近有个需求需要获取 SIME 平台的数据并形成月度报告。我的想法就是通过平台的 API 获取数据，然后基于 word 以及 matplotlib 来生成可视化报告。在这里要介绍一个比较好用的 python 库，docxtpl。这个库是一个基于 python-docx 的库，可以通过模板来生成报告。下面就介绍一下如何使用这些库，以及使用过程中的一些小问题。

docxtpl 是基于 jinja2 引擎的语法，类似于常见的 html 模板语法，变量经常会放在 `{{}}` 中。假如我们希望在模板中设置变量 a 的值，那么我么可以在模板中填写 {{a}}。最后，我们通过 `render` 来渲染模板即可。

```python 
doc = Docxtpl(filename)
context = {
    "a": "13413"
}
doc.Render(context)
```

Matplotlib 是一个非常好的可视化作图工具，可以利用它制作各种图例。