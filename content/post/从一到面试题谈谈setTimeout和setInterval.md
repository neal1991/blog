---
title: "从一道面试题谈谈 setTimeout 和 setInterval"
tags: ["JavaScript", "面试题"]
categories: ["前端"]
date: "2018-04-21"
---

最近有看到一道题目，隔一秒打印一个数字，比如第 0 秒打印 0，第 1 秒打印打印 1 等等，如何去实现？

假如我们尝试使用 setTimeout 去实现：

```javascript
for (var i = 0; i < 5; i++) {
    setTimeout(function() {
        console.log(i);
    }, i * 1000);
}
```

这样可以么，执行的结果是什么呢？你可以将这段代码粘贴到 浏览器的 Console 中运行一下。结果是，每隔一秒打印一个 5 ，一共打印 5 次。这是为什么呢，为什么不是打印 0, 1, 2, 3, 4 呢？众所周知，JavaScript 是一种单线程语言，主线程的语句和方法会阻塞定时任务的执行，在 JavaScript 执行引擎之外，存在一个任务队列。当代码中调用 setTimeout 方法时，注册的延时方法会挂在浏览器其他模块处理，等达到触发条件是，该模块再将要执行的方法添加到任务队列中。这个过程是与执行引擎主线程独立，只有在主线程方法全部执行完毕的时候，才会从该模块的任务队列中提取任务来执行。这就是为什么 setTimeout 中函数延迟执行的时间往往大于设置的时间。

因此，对于上述的代码块，每一个 setTimeout 函数都被添加到了任务队列中。然后，这还涉及到了函数作用于的问题。因为当任务队列中的函数执行的时候，其作用域其实是全局作用域。setTimeout 中的打印函数执行的时候就会在全局作用域中寻找变量 i，而此时全局作用域的变量 i 的值已经变成 5 了。这也就是为什么打印的数字都是 5。那么应该如何达到我们一开始预期的效果呢？这里我们就需要考虑到函数执行上下文的问题，可以通过立即执行函数（IIFE）来改变函数作用域。


```javascript
for (var i = 0; i < 5; i++) {
    (function(i) {
        setTimeout(function() {
            console.log(i);
        }, i * 1000);
    })(i);
}
```

你可以将这段代码执行一下，可以看看执行的效果，应该就可以达到预期的效果了。通过立即执行函数改变函数运行的作用域，并且将要打印的变量传入到函数参数中，如此就能打印出正确的数字了。那么除了 setTimeout，我们是不是还有其它的方法呢？答案是有的，我们可以使用 setInterval 方法。

根据 MDN 文档，`WindowOrWorkerGlobalScope` 的 `setInterval()` 方法重复调用一个函数或执行一个代码段，在每次调用之间具有固定的时间延迟。主要有两种使用方法：

```javascript
let intervalID = window.setInterval(func, delay[, param1, param2, ...]);
let intervalID = window.setInterval(code, delay);
```

`intervalID` 是函数执行的唯一辨识符，可以作为参数传给 `clearInterval()`。第二种方法不推荐使用，主要处于安全原因考虑。那么我该如何使用 `setInterval()` 方法来达到预期的效果呢？

```javascript
var i = 0;
var a = setInterval(function() {
    console.log(i++);
    if (i == 5) {
        clearInterval(a);
    }
}, 1000);
```

这样就可以了，setInterval 在设置的时间间隔后都会去执行，如果我们不使用 `clearInterval()` 方法的话，那么函数就会一直执行。

那还有没有其它的方法呢，比如 promise?

```javascript
fn = (i) => {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve(i);
    }, i * 1000)
  })
}

Fn = async () => {
  for (let i = 0; i < 5; i++) {
    const res = await fn(i);
    console.log(res);
  }
}
Fn()
```

这样我们通过 promise 可以实现“同步”地逐个打印的效果。

以上就是对于这个面试题的解答，以及介绍了一下 setTimeout 和 setInterval 的区别，如果大家还有更好的解决思路的话，欢迎留言。

以上。

欢迎搜索微信号 mad_coder 或者扫描二维码关注公众号：

![9tMvlT.jpg](https://s1.ax1x.com/2018/02/17/9tMvlT.jpg)
