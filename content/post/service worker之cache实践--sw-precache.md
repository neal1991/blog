---
title: "service worker之cache实践--sw-precache"
tags: ["pwa"]
categories: ["前端"]
date: 2017-04-22
---

Progressive web application是谷歌推出的一种渐进式应用，我觉得其实PWA是一种非常具有发展前景的技术。首先，PWA是由谷歌推出的，而且跨平台,PWA可以给你类似于原生APP的体验，通过service worker，你可以将资源缓存到本地。但是，PWA再国内一直都是不温不火，主要有好几个原因：一是因为国内的浏览器环境比较复杂，而PWA一般只是能够在chrome浏览器得到较好的支持。虽然chrome在桌面端占据了很大比例，但是在移动端还是一般般，普通的用户不一定会去安装Chrome。二是safari浏览器对于PWA的支持不是很完美，service worker目前还是没有得到支持的。

但是我是觉得PWA还是很好的，值得开发者们进一步探索。有一点偏题了，今天要讨论的其实是PWA里面service worker资源的缓存问题。主要问题的背景是这样的，我有一个[上海地铁线路图](https://neal1991.github.io/subway-shanghai/)的PWA，可以支持离线使用，有兴趣的同学可以尝试看看。我遇到一个问题，就是每次我更新之后代码之后，加入我的PWA被添加到主屏之后，这个APP的代码就没有更新，必须删除后重新重浏览器中添加到主屏。一开始我以为是PWA的问题，后来竟别人提醒，桌面上的APP其实也就是网站的链接。我这才恍然大悟，问题是因为我的servicer worker里面的缓存策略有问题。因为我的APP通过service worker来缓存资源，包括js,css以及图片文件，所以始终是从缓存中加载资源，所以我远程代码更新后，这个APP的代码却没有得到更新。OK，拿代码说话，我一开始的代码是：

```javascript
var cacheName = 'subway';
var filesToCache = [
	'/',
	'index.html',
	'image/transfer.png',
	'dist/alloy_finger.js',
	'app.css'
];

self.addEventListener('install', function(e) {
	console.log('service worker install');
	e.waitUntil(caches.open(cacheName).then(function(cache) {
		console.log('serviceworker caching app shell');
		return cache.addAll(filesToCache);
	}));
});
```

可以看出我们在 install 事件后通过在 cache 里面加载文件，所以我们必须选择一种合适的策略能够让我们的APP在代码更新之后去请求新的代码呢？

Google其实在PWA推出的过程中也给出了很多有用的技术。比如[sw-precache](https://github.com/GoogleChrome/sw-precache)以及[sw-toolbox](https://github.com/GoogleChrome/sw-toolbox)，以及最近正在发展过程中的[sw-helper](https://github.com/GoogleChrome/sw-helpers)。这里，我主要使用的是sw-precache来更新我的service worker策略。

sw-precache也是NODE中的一个模块，可以通过`npm install sw-precache`来进行安装。sw-precache可以配合多个工具使用，这里我主要介绍一下如何配合gulp来使用。我们通过利用sw-precache来帮助我们生成sw-precache。饿了么的huangxuan在medium写了一篇[文章](https://medium.com/@Huxpro/how-does-sw-precache-works-2d99c3d3c725)来渗入地介绍sw-precache，这篇文章写的不错，但是却是在墙外，主要是介绍sw-precache的工作方式。我就谈一下我对sw-precache的理解把，以一个gulpfile的一段代码为例：

```javascript
gulp.task('generate-sw', function(callback) {
	var path = require('path');
	var swPrecache = require('sw-precache');

	swPrecache.write(path.join('sw.js'), {
		staticFileGlobs: [
			'app.js',
			'dist/alloy_finger.js',
			'dist/app.css',
			'image/*.{png}',
			'index.html',
			'/'
		]
	}, callback)
})
```

我们通过利用 sw-precache 来生成 [sw.js 文件](https://github.com/neal1991/subway-shanghai/blob/master/sw.js)。主要的方式是检测你在staticFileGlobs里面的文件有没有发生变化，如果发生变化就会重新生成hash码，从而能够使得APP在代码更新之后向远程请求新的代码。

这篇文章可能只是很小的一点，关于 service worker 的使用还有很多东西值得学习，欢迎关注我的 [github](https://neal1991.github.io/neal1991/) 共同探讨。


