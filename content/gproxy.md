---
title: "升级 Goproxy 真香"
author: Neal
tags: [golang, web 开发, 安全开发]
categories: [golang]
date: "2019-02-22" 
---

Golang 以前的依赖管理一直饱受诟病，社区的方案也层出不强，比如 vendor, glide, godep 等。之前的依赖管理一直是依靠 GOPATH 或者将依赖代码下载到本地，这种方式都有劣势。另外由于特殊的网络环境，导致谷歌的大部分包都没有办法下载。才 Golang 1.11 开始，官方已内置了更为强大的 Go modules 来一统多年来 Go 包依赖管理混乱的局面，从 1.13 开始将成为默认配置。配合 Goproxy 来使用来说，真香。这次配合我之前的 golang 开源项目 [gshark](https://github.com/neal1991/gshark) 做了一升级，升级花费的时间不超过 5 分钟，真香。

## 升级 Golang 版本

其实升级 Golang 版本是非常简单的，只要移除之前的 Golang，然后复制新版本的 Golang 就可以了。以我之前的 VPS 为例，之前安装的 Golang 版本是 1.9。

1. 移除旧版本 Golang

```
rm -rf /usr/local/go
```
2. 安装新版本 Golang

```
wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
```
3. 配置 Golang 环境

如果你之前配置过 Golang 的环境，那么你可以找直接无缝升级。主要只是需要配置 GOROOT 以及 GOPATH 即可，对于 1.13 其实这两个变量已经不是必要的了。但有一个配置很重要，就是将 gproxy 的代理设置为国内的代理，这样你就能体验飞一般的畅快。

```
export GOPROXY=https://goproxy.cn,direct
```

