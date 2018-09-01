---
title: "利用 python 生成可视化报告"
author: Neal
description: ""
tags: [python, 可视化]
categories: [python]
date: "2018-08-16"
---

Python 作为一种常用的胶水语言，可用于各种用途。最近有个需求需要获取 SIME 平台的数据并形成月度报告。我的想法就是通过平台的 API 获取数据，然后基于 word 以及 matplotlib 来生成可视化报告。在这里要介绍一个比较好用的 python 库，docxtpl。这个库是一个基于 python-docx 的库，可以通过模板来生成报告。下面就介绍一下如何使用这些库，以及使用过程中的一些小问题。

## 模板

docxtpl 是基于 jinja2 引擎的语法，类似于常见的 html 模板语法，变量经常会放在 `{{}}` 中。假如我们希望在模板中设置变量 a 的值，那么我么可以在模板中填写 {{a}}。最后，我们通过 `render` 来渲染模板即可。

```python 
doc = Docxtpl(filename)
context = {
    "a": "13413"
}
doc.Render(context)
```

那么如果我们希望在模板中插入一个图片该怎么做呢，可以使用 InlineImage 去实例化图片：

```python
from docxtpl import DocxTemplate, InlineImage
# for height and width you have to use millimeters (Mm), inches or points(Pt) class :
from docx.shared import Mm, Inches, Pt
import jinja2
from jinja2.utils import Markup

tpl=DocxTemplate('test_files/inline_image_tpl.docx')

context = {
    'myimage' : InlineImage(tpl,'test_files/python_logo.png',width=Mm(20)),
    'myimageratio': InlineImage(tpl, 'test_files/python_jpeg.jpg', width=Mm(30), height=Mm(60)),

    'frameworks' : [{'image' : InlineImage(tpl,'test_files/django.png',height=Mm(10)),
                      'desc' : 'The web framework for perfectionists with deadlines'},

                    {'image' : InlineImage(tpl,'test_files/zope.png',height=Mm(10)),
                     'desc' : 'Zope is a leading Open Source Application Server and Content Management Framework'},

                    {'image': InlineImage(tpl, 'test_files/pyramid.png', height=Mm(10)),
                     'desc': 'Pyramid is a lightweight Python web framework aimed at taking small web apps into big web apps.'},

                    {'image' : InlineImage(tpl,'test_files/bottle.png',height=Mm(10)),
                     'desc' : 'Bottle is a fast, simple and lightweight WSGI micro web-framework for Python'},

                    {'image': InlineImage(tpl, 'test_files/tornado.png', height=Mm(10)),
                     'desc': 'Tornado is a Python web framework and asynchronous networking library.'},
                    ]
}
# testing that it works also when autoescape has been forced to True
jinja_env = jinja2.Environment(autoescape=True)
tpl.render(context, jinja_env)
tpl.save('test_files/inline_image.docx')
```

同样还可以使用宽度高度单位来设置图片的大小。另外我们还可以利用表格的模板来动态设置数据，具体可以参考 [test](https://github.com/elapouya/python-docx-template/tree/master/tests)，里面有各种例子可以参考。

## Matplotlin

Matplotlib 是一个非常好的可视化作图工具，可以利用它制作各种图例。