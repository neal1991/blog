---
title: "第一个chrome extension"
author: Neal
description: "如今，chrome浏览器的使用如越来越流行，chrome extension往往能提供更多很丰富的功能。以前一直想了解这方面的东西，可是又担心很复杂。前段时间，在斗鱼看一个直播，想刷弹幕，但是每次自己输入有很麻烦，所以写个小脚本就可以了，后来想以下也可以使用chrome extension来实现。关于chrome extension,google就给出了相关的文档，另外国内360也翻译了这篇文档。当"
tags: [chrome,扩展]
categories: [web前端]
date: "2017-03-04 13:47:34"
---
如今，chrome浏览器的使用如越来越流行，chrome extension往往能提供更多很丰富的功能。以前一直想了解这方面的东西，可是又担心很复杂。前段时间，在斗鱼看一个直播，想刷弹幕，但是每次自己输入有很麻烦，所以写个小脚本就可以了，后来想以下也可以使用chrome extension来实现。关于chrome extension,[google](https://developer.chrome.com/extensions)就给出了相关的文档，另外国内[360](http://open.chrome.360.cn/extension_dev/overview.html)也翻译了这篇文档。当然我所做的东西还是很基础的，在此，也是就是说一下自己第一次尝试的经验。
其实，chrome extension似乎和现在很火的pwa有一点类似，对于chrome extension来说，有个文件是必不可少的，即`manifest.json`，这对于extension是非常重要的。这个文件主要是项目的某些描述，以及一些文件的引入。以我的文件为例：
```
{
  "manifest_version": 2,

  "name": "弹幕增强",
  "description": "This extension provides you a good experience of sending danmu at douyu",
  "version": "1.0",
  "browser_action": {
    "default_icon": "icon.png",
    "default_popup": "popup.html"
  },
  "content_scripts" : [{
      "matches": [
          "http://*/*",
          "https://*/*"
      ],
      "js" : ["app.js"],
      "run_at": "document_end"
  }]
}
```
`manifes_version`好像是必须定义为2，这个好像是强制要求。提及一点的就是你可以使用开发者模式从而调试你的extension。你可以在tab右键打开更多工具，然后找到拓展程序打开，然后你可以通过加载已解压的拓展程序，只要选择你extension的文件夹就可以了，并且在右上角勾选上开发者模式。
接着主要讲一下“brower_action"里面定义的是extension的相关内容，"default_icon"即是插件的图标，"default_popup"就是弹出的页面，chrome extension规定html文件和js文件必须是分开来的。extension和当前打开的页面之间的环境是相互隔离的，是不可以直接通信的。"content_script"是定义插入到当前打开页面的相关js文件，“matches”可以让脚本再匹配到规定的正则才会执行，“js"则是插入到页面的js文件，你还可以插入css文件。需要注意的是，"content_script"虽然能够操纵当前页面的dom，但是他和当前页面的js环境是相互隔离的，不能够互相交互，当然也有相应的其他方法。
我的extension只是用到了”content_script":
```
var times = 1000;
for (var i = 0; i < times; i ++) {
  (function(i) {
    setTimeout(function() {
      console.log(i);
      document.getElementById('js-send-msg').childNodes[1].value = '凸凸凸凸凸凸凸凸凸凸凸道歉' + i;
      document.getElementById('js-send-msg').childNodes[5].click();
    }, i * 10000);
  })(i);
}
```
这个可以用来直接操控当前dom，用了个小闭包。当然代码还是比较丑陋，比较基础，这也是我自己对chrome extension的第一次小尝试，源代码地址 https://github.com/neal1991/danmu-sender

求star!!!!