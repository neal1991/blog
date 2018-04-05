---
title: "消灭 star 大作战-Front-end-tutorial"
tags: ["js"]
categories: ["前端"]
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


