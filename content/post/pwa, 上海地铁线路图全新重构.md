---
title: "pwa, 上海地铁线路图全新重构"
tags: [pwa, react]
---

之前一直有在维护一个上海地铁线路图的 pwa，最主要的特性就是 "offline first"。但是由于代码都是通过原生的 js 去实现，之前我都不是很喜欢去用框架，不想具有任何框架的偏好。但是到后期随着代码量的增加，代码的确变得混乱不堪，拓展新功能也变得尤为困难。因此，花了将近两个礼拜的时候对于应用进行了一次完整的重构。

## 准备

准备工作先做好，在 vue 和 react 之间，我还是选择了后者。基于 [create-react-app](https://github.com/facebook/create-react-app) 来搭建环境，crp 为你准备了一个开箱即用的开发环境，因此你无需自己亲手配置 webpack，因此你也不需要成为一名 webpack 配置工程师了。

另外一方面，我们还需要一些数据，包括站点信息，线路路径，文字说明等等。基于之前的应用，可以通过一小段的代码获取信息。就此如要我们获取我们以前的站点在 svg 图中的相关属性，普通的站点使用 circle 元素，为了获取其属性：

```javascript
const circles = document.querySelectorAll('circle');
let result = [];
circles.forEach(circle => {
  let ele = {
    cx: circle.cx,
    cy: circle.cy,
    sroke: circle.stroke, 
    id: circle.id
  };
  result.push(ele);
})
const str = JSON.stringify(result);
```

通过这样的代码我们就可以获取 svg 普通站点信息，同理还可获取中转站信息，线路路径信息以及站点以及线路 label 信息。还有，我们还需要获取每个站点的时刻表信息，卫生间位置信息，无障碍电梯信息以及出入口信息。这里是写了一些爬虫去官网爬取并做了一些数据处理，再次就不一一赘述。

## 设计

数据准备好之后，就是应用的设计了。首先，对组件进行一次拆分：

### 组件结构

将整个地图理解成一个 Map 组件，再将其分为 4 个小组件：

![map.png](http://ozfo4jjxb.bkt.clouddn.com/map.png)

* Label: 地图上的文本信息，包括地铁站名，线路名称
* Station: 地铁站点，包括普通站点和中转站点
* Line： 地铁线路
* InfoCard: 状态最复杂的一个组件，主要包含时刻表信息、卫生间位置信息、出入口信息、无障碍电梯信息

这是一个大致的组件划分，里面可能包含更多的其它元素，比如 InfoCard 就有 InfoCard => TimeSheet => TimesheetTable 这样的嵌套。

## 组件通信和状态管理

本地开发的最大的难点应该就是这一块的内容了。本来由于组件的层级并不算特别复杂，所以我并不打算上 Redux 这种类型的全局状态管理库。主要组件之间的通信就是父子通信和兄弟组件通信。父子组件通信比较简单，父组件的 state 即为子组件的 props，可以通过这个实现父子组件通信。兄弟组件略为复杂，兄弟组件通过共享父组件的状态来进行通信。假如这样的情景，我点击站点，希望能够弹出信息提示窗，这就是 Station 组件和 InfoCard 组件之间的通信，通过 Map 组件来进行共享。点击 Station 组件触发事件，通过回调更新 Map 组件状态的更新，同时也实现了 InfoCard 组件的更新。同时为了实现，点击其它区域就可以关闭信息提示窗，我们对 Map 组件进行监听，监听事件的冒泡来实现高效的关闭，当然为了避免一些不必要的冒泡，还需要在一些时间处理中阻止事件冒泡。

![subway-react](https://user-images.githubusercontent.com/12164075/37656324-ace5c2b2-2c82-11e8-8b6a-b3c96e091c73.gif)

InfoCard 是最为复杂的一个组件，因为里面包含了好几个 icon，以及状态信息的切换，同时需要实现切换不同的站点的时候能够更新信息提示窗。需要注意信息提示窗信息初次点击信息的初始化，以及切换不同 icon 时
