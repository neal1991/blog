---
title: "持续发布 Chrome 插件"
author: Neal
tags: [Chrome 插件, CirecleCI]
categories: [开发]
date: "2019-05-27" 
---

Chrome 插件对于 Chrome 浏览器用户来说是必不可少的利器之一。之前我有开发过一款七牛云图床的 Chrome 插件 [image-host](https://github.com/neal1991/image-host)。后来由于我自己没有自己的域名，所以不太好使用这个插件了。后面，有其他的同学来提交 PR 来维护这一个插件。这样就有一个问题，一旦新的代码发布，就需要自己再重新发布一下插件。虽然发布插件不算特别麻烦，打包成压缩包，上传就可以了，但是对于程序员来说，可以自动做的绝对不要手动做。以下就是通过 CircleCI 来持续发布 Chrome 插件，参考了官方的文章，自己也才了一些坑。

## 介绍

CircleCI 是一款持续集成产品，和 Travis 非常类似，都属于 Github 上非常流行的持续集成产品。产品有商业和普通版本，开源项目是可以免费使用的。关于持续集成产品的不同，可以参考[这篇文章](https://hackernoon.com/continuous-integration-circleci-vs-travis-ci-vs-jenkins-41a1c2bd95f5)。使用这个工具持续发布 Chrome 插件的原理就是：通过 CircleCI 来使用 Chrome 插件的 API 来持续发布插件，通过 CirecleCI 和 github 的集成可以在特定的时机就可以发布插件。那么下面具体介绍如何使用 CircleCI 来进行 Chrome 插件的发布，主要包括 Google API 的配置以及 CirecleCI 的配置。

## Google API

首先，创建一个 Google API 项目，可以直接点击这个链接创建。

