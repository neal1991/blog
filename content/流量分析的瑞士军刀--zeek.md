---
title: "网络安全分析的瑞士军刀--zeek"
author: Neal
tags: [安全, 网络安全]
keywords: [安全, 网络安全, zeek, bro, kafka, bro-plugin, logstash]
categories: [安全]
date: "2020-04-18" 
---

Zeek (Bro) 是一款大名鼎鼎的开源网络安全分析工具。通过 Zeek 可以监测网络流量中的可疑活动，通过 Zeek 的脚本可以实现灵活的分析功能，可是实现多种协议的开相机用的分析。本文主要是将 Zeek 结合被动扫描器的一些实践的介绍，以及 Zeek 部署的踩过的一些坑。

## 安装

Zeek 的安装还是比较简单的，笔者主要是在 Mac 上以及 Linux 上安装。这两个操作系统的安装方式还是比较类似的。对于 Linux 而言，需要安装一些依赖包：

```
sudo yum install cmake make gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig zlib-devel
```

这里我有遇到一个问题就是可能你的 Redhat 镜像源里面没有包含 `libpcap-devel`，因为这个包在可选的范围内，而内网的服务器又没有互联网连接。可以通过手工下载相应版本的 `libpcap` 以及 `libpcap-devel` 即可。

Mac 上需要的依赖更少一点，首先需要确保安装了 `xcode-select`，如果没有安装，可以通过 `xcode-select --install` 来进行安装。Mac 上只需要安装依赖 `cmake, swig, openssl, bison` 即可，可以通过 Homebrew 来进行安装。

依赖包安装完毕之后就可以安装 Zeek，其实是可以通过包管理工具来进行安装的，不过这里我推荐使用基于源码的安装方式，安装比较简单而且还容易排查问题。