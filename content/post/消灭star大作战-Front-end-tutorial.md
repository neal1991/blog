---
title: "消灭 star 大作战--Front-end-tutorial"
tags: ["js"]
categories: ["前端"]
date: "2018-04-07
---

# 写在前面

Github star 往往非常简单，点击一个按钮，就 star 了。但是你还去看它么，这就未必了。因此很多库长年累月的堆积在你的 star list 里面无人问津。因此，会有这样一个具有一个非常中二的名字的计划。对于 star 仓库，从后往前，一个个理解消化，不要让它无意义地堆积。

操作步骤：

* fork it
* finish it

# 仓库信息

* 仓库名称：[Front-end-tutorial](https://github.com/neal1991/Front-end-tutorial)
* 主要内容：这是一个博客，里面主要是前端开发的内容，内容设计比较广泛，包括 HTML, CSS, JS 以及流行的框架，以及前端开发的其他内容。
* 消灭计划：内容较多，打算主要消化一些感兴趣的内容，主要应该集中于原生的东西或者一些性能方面的知识。

# 作战内容

## JavaScript

### 深拷贝

深拷贝可以说是一个老生重谈的问题，几乎每一个前端面试都可能会问这样的问题。Js 中的对象都是引用，所以浅拷贝时，修改拷贝后的对象会影响原对象。原仓库中其实讲的并不是很深入，我反倒是觉得评论里面的一篇文章[深入剖析 JavaScript 的深复制](http://jerryzou.com/posts/dive-into-deep-clone-in-javascript/)讲得更好。

有很多第三方库实现了对于对象的深拷贝。

* jQuery: `$.extend(true, {}, sourceObject)`
* loadsh: `_.clone(sourceObject, true)` 或者 `_.cloneDeep(sourceObject)`

另外有一个神奇的方法就是借助于 JSON 的 `parse` 和 `stringify` 方法，当时我才看到这个方法的时候惊为天人，这个方法还可以用来判断两个对象是否相等。当然，这个方法还是有一些限制，因为正确处理的对象只能是使用 json 可以表示的数据结构，对于函数可能就无能为力了。原文作者实现了一个深拷贝的方法，不过考虑了很多情况，在这里我们就实现一个简单版的深拷贝把。

```javascript
function deepCopy(obj) {
  const result = {};
  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      if (Object.prototype.toString.call(obj[key]).indexOf('Array') !== -1 ||
       Object.prototype.toString.call(obj[key]).indexOf('Object') !== -1) {
         result[key] = deepCopy(obj[key]);
       } else {
         result[key] = obj[key];
       }
    }
  }
  return result;
}
```

### call 和 apply

call 和 apply 应该是两个非常类似的方法，我的理解它们都是改变函数运行的作用域。不同之处就是参数不同，`apply` 接收两个参数，一个是函数运行的作用域，另外一个是参数数组，而 `call` 的第一个参数相同，后面传递的参数必须列举出来。

## Css

## flex

传统的布局方式是基于盒模型，而 flex 布局是一种新型的弹性布局方式，现在基本上所有浏览器都已经可以支持。Flex 布局主要包含 flex container 以及 flex item。

容器的属性主要有六种：

* flex-direction
* flex-wrap
* flex-flow
* justify-content
* align-items
* align-content

### flex-direction

* row（默认值）：主轴为水平方向，起点在左端
* row-reverse：主轴为水平方向，起点在右端
* column：主轴为垂直方向，起点在上沿
* column-reverse：主轴为垂直方向，起点在下沿

### flex-wrap

默认情况下，所有 items 排在一条线上。`flex-wrap` 属性定义如果一条轴线排不下，如何换行。

* nowrap（默认）：不换行
* wrap：换行，第一行在上面
* wrap-reverse：换行，第一行在下面

### flex-flow

flex-flow 属性是 flex-direction 和 flex-wrap 属性的简写形式，默认值是 `row nowrap`。

### justify-content

justify-content 定义了 items 在主轴上的对齐方式。

flex-start（默认值）：左对齐
flex-end：右对齐
center：居中对齐
space-between：两端对齐，items 之间的间隔相等
space-around：每个 item 两侧的间隔相等。所以，item 之间的间隔是 item 和边框之间的两倍

#### align-items

align-items 属性定义 items 在交叉轴上如何对齐。

* flex-start：交叉轴的起点对齐
* flex-end：交叉轴的终点对齐
* center：交叉轴的中点对齐
* baseline：items 的第一行文字的基线对齐
* stretch（默认值）：如果 item 未设置高度或者设置为 auto，则将占满整个容器

### align-content

align-content 定义了多个轴线的对齐方式，如果 items 只有一根轴线，则该属性不起作用。

* flex-start：与交叉轴的起点对齐
* flex-end：与交叉轴的终点对齐
* center：与交叉轴的中点对齐
* space-between：与交叉轴连段对齐，轴线之间的间隔均匀分布
* space-around：每根轴线两侧的间隔相等
* stretch（默认值）：轴线占满整个交叉轴

Item 的属性：

* order
* flex-grow
* flex-shrink
* flex-basis
* flex
* align-self

### order

order 定义 item 的排列顺序，数值越小，越靠前。

### flex-grow

flex-grow 定义 item 的放大比例

### flex-shrink

flex-shrink 定义 item 缩小比例

### flex-basis 

flex-basis 定义在分配多余空间之前，item 占据的主轴空间

### flex

flex 是 flex-grow, flex-shrink, flex-basis 缩写，默认 `0 1 auto`

### align-self

align-self 允许单个 item 使用与其它 item 不同的对齐方式，可以覆盖 align-items 的属性，默认值为 auto。

Flex 主要用于二维空间的布局，伸缩性好，目前在主流浏览器的支持情况也还可以。

## 结语

这个算是我当初刚刚入门的时候关注的一个仓库，不过的确是比较适合前端入门学习，有很多资源链接，但是质量么，这个就见仁见智了。主要是了解以上几个知识点作为这个仓库的阅读收获，至于框架之内的，就放到后面的系列去讲吧。





