---
title: "pwa, 上海地铁线路图全新重构"
tags: [pwa, react]
keywords: [pwa,react,subway,shanghai,shanghai subway,上海地铁,上海]
date: "2018-03-21"
---

之前一直有在维护一个上海地铁线路图的 pwa，最主要的特性就是 "offline first"。但是由于代码都是通过原生的 js 去实现，之前我都不是很喜欢去用框架，不想具有任何框架的偏好。但是到后期随着代码量的增加，代码的确变得混乱不堪，拓展新功能也变得尤为困难。因此，花了将近两个礼拜的时候对于应用进行了一次完整的重构。网站访问地址：https://neal1991.github.io/subway-shanghai

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

本地开发的最大的难点应该就是这一块的内容了。本来由于组件的层级并不算特别复杂，所以我并不打算上 Redux 这种类型的全局状态管理库。主要组件之间的通信就是父子通信和兄弟组件通信。父子组件通信比较简单，父组件的 state 即为子组件的 props，可以通过这个实现父子组件通信。兄弟组件略为复杂，兄弟组件通过共享父组件的状态来进行通信。假如这样的情景，我点击站点，希望能够弹出信息提示窗，这就是 Station 组件和 InfoCard 组件之间的通信，通过 Map 组件来进行共享。点击 Station 组件触发事件，通过回调更新 Map 组件状态的更新，同时也实现了 InfoCard 组件的更新。同时为了实现，点击其它区域就可以关闭信息提示窗，我们对 Map 组件进行监听，监听事件的冒泡来实现高效的关闭，当然为了避免一些不必要的冒泡，还需要在一些事件处理中阻止事件冒泡。

![subway-react](https://user-images.githubusercontent.com/12164075/37656324-ace5c2b2-2c82-11e8-8b6a-b3c96e091c73.gif)

InfoCard 是最为复杂的一个组件，因为里面包含了好几个 icon，以及状态信息的切换，同时需要实现切换不同的站点的时候能够更新信息提示窗。需要注意信息提示窗信息初次点击信息的初始化，以及切换不同 icon 时分别显示不同的信息，比如卫生间信息或者出入口信息，以及对于时刻表，切换不同的线路的时候更新对应的时刻表。这些状态的转化，需要值得注意。另外值得一题的点就是，在切换不同站点的时候的状态，假如我正在看某个站点的卫生间信息的时候，我点击另外一个站点，这时候弹出的信息提示窗应该是时刻表信息还是卫生间信息呢？我的选择还是卫生间信息，我对于这一状态进行了保持，这样的用户体验从逻辑上来讲似乎更佳。具体实现的代码细节就不一一说明了，里面肯能包含更多的细节，欢迎使用体验。

## 性能优化

以上这些的开发得益于之前的维护，所以重构过程还是比较快的，稍微熟悉了下 react 的用法就完成了重构。但是，在上线之后使用 lighthouse 做分析，performan 的得分是 0 分。首屏渲染以及可交互得分都是 0 分，首先来分析一下。因为整个应用都是通过 js 来渲染，而最为核心的就是那个 svg。整个看下来，有几点值得注意：

* 代码直接将 json 导入，导致 js 体积过大
* 所有组件都在渲染的时候进行加载

找到问题点，就可以想到一些解决方案了。第一个比较简单，压缩 json 数据，去除一些不需要的信息。第二个，好的解决办法就是通过异步加载来实现组件加载，效果明显，尤其是对于 InfoCard 组件：

### 同步

```javascript
class InfoCard extends React.Component {
  constructor(props) {
    super(props) ｛
    ...
    ｝
  ｝
  ...
}
```

### 异步

```javascript
export default function asyncInfoCard (importComp) {
  class InfoCard extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        component: null
      };
    }
    
    asyncComponentDidMount() {
      const { default: component } = await importComp();
      this.setState({
        component: component
      })
    ｝
  }
}
```

这样我们就实现了将同步组件改造成一个异步加载的组件，这样就无需一下子加载所有的组件。这样我们就可以在 Map 中使用异步的方式来进行组件的加载：

```javascript
import asyncInfoCard from './InfoCard'
const InfoCard = asyncInfoCard(() => import('./InfoCard')
```

通过上线之后的性能分析，lighthouse 性能评分一下子就上升到了 80 多分，证明这样的改进还是比较有效的。另外一个值得提的点就是首屏，因为历史原因，整张图 svg 中元素的位置都是定死的，及横坐标和纵坐标都已经是定义好的，而 svg 被定为在中间。在移动端加载时，呈现的就是左边的空白区域，所以给用户一种程序未加载完毕的错觉。之前的版本的做法就是通过 scroll 来实现滚动条的滚动，将视图的焦点移动到中间位置。这次的想法是通过 `transform` 来实现：

```css
.svg {
transform: translate(-100px, -300px)
}
```

这样实现了整个 svg 图位置的偏移，使用 lighthouse 进行分析，性能分降到了 70 多分。继续想想有没有其他的方法，后来我想在最左上上角定义一个箭头动画。

```html
<img src="right_arrow.png" alt="right arrow" title="right arrow" class="right-arrow"/>
```

```css 
.right-arrow {
  animation: moveright 3s linear infinite;
}
@keyframs moveright {
  0% {
    transform: translateX(2rem);
  }
  50% {
    transform: translateX(3rem);
  }
  100% {
    transform: translateX(5rem);
  }
} 
```

![right_arrow.gif](http://ozfo4jjxb.bkt.clouddn.com/right_arrow.gif)

这样我们就可以创建一个循环向右移动的动画，提示用户向右滑动。部署之后发现性能分立马降到 0，索性也就放弃了这个做法。最后来时决定采用 `transform: translateX(-200px) translateY(-300px);` ，因为这样通过 css3 的属性可以在一些移动设备上还可以利用 GPU 加速，并且 translateX 不会引起页面的重绘或者重排，只会导致图层重组，最小避免对性能的影响。

## 部署

目前的部署方案是采取 create-react-app 的官方建议，通过 gh-pages 实现将 build 的打包文件上传到 gh-pages 分支上从而实现部署。

### 兼容性

目前该应用在 Chrome 浏览器的支持性是最好的，安卓浏览器建议安装 Chrome 浏览器使用，我一般也都比较喜欢在手机上使用谷歌浏览器。对于 Safari 浏览器，其它的浏览功能似乎没有什么大问题，目前应该还没支持添加到主屏幕。不过在之后的 ios 版本好像对于 pwa 有着更进一步的支持。

## 结语

![commits.png](http://ozfo4jjxb.bkt.clouddn.com/commits.png)

花了两个礼拜的时间完成了项目的完整的重构，从这一年来的 commit 记录可以看到三月份疯狂 commit 了一波，主要是第一个周末花费了两天的时间修改了好多代码，被那个 InfoCard 的状态切换搞了很久，后面就是针对性能做了一些优化。过程很痛苦，一度怀疑自己的 coding 能力。不过最后还是有以下感悟：

* 世界上没有最好的语言，最好的框架，只有最合适的
* 最优雅的实现都不是一蹴而就的，都是一个个试出来的

最后一个冷笑话：

青年问禅师：“请问大师，我写的程序为什么没有得到预期的输出？”
禅师答到：“年轻人，那是因为你的程序只会按你怎么写的执行，不会按你怎么想的执行啊……”

[源代码地址](https://github.com/neal1991)，欢迎 star 或者 pr。

以上

欢迎搜索微信号 mad_coder 或者扫描二维码关注公众号：

![93cfyj.jpg](https://user-gold-cdn.xitu.io/2018/2/10/1617eae1b59c001c?w=258&h=258&f=jpeg&s=27683)

