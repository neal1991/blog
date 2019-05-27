---
title: "持续发布 Chrome 插件"
author: Neal
tags: [Chrome 插件, CirecleCI]
categories: [开发]
date: "2019-05-27" 
---

Chrome 插件对于 Chrome 浏览器用户来说是必不可少的利器之一。之前我有开发过一款七牛云图床的 Chrome 插件 [image-host](https://github.com/neal1991/image-host)。后来由于我自己没有自己的域名，所以不太好使用这个插件了。后面，有其他的同学来提交 PR 来维护这一个插件。这样就有一个问题，一旦新的代码发布，就需要自己再重新发布一下插件。虽然发布插件不算特别麻烦，打包成压缩包，上传就可以了，但是对于程序员来说，可以自动做的绝对不要手动做。以下就是通过 CircleCI 来持续发布 Chrome 插件，参考了官方的文章，自己也才了一些坑。