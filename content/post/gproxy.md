---
title: "真香系列之 Golang 升级"
author: Neal
tags: [golang, web 开发, 安全开发]
categories: [golang]
date: "2019-09-23" 
---

Golang 以前的依赖管理一直饱受诟病，社区的方案也层出不强，比如 vendor, glide, godep 等。之前的依赖管理一直是依靠 GOPATH 或者将依赖代码下载到本地，这种方式都有劣势。另外由于特殊的网络环境，导致谷歌的大部分包都没有办法下载。才 Golang 1.11 开始，官方已内置了更为强大的 Go modules 来一统多年来 Go 包依赖管理混乱的局面，从 1.13 开始将成为默认配置。配合 Goproxy 来使用来说，真香。这次配合我之前的 golang 开源项目 [gshark](https://github.com/neal1991/gshark) 升级到 1.13，升级花费的时间不超过 5 分钟，真香。

## 升级 Golang 版本

其实升级 Golang 版本是非常简单的，只要移除之前的 Golang，然后复制新版本的 Golang 就可以了。以我之前的 VPS 为例（CentOS,亲测苹果系统可以使用同样的方式升级），之前安装的 Golang 版本是 1.9。

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

如果你之前配置过 Golang 的环境，那么你可以找直接升级。主要只是需要配置 GOROOT 以及 GOPATH 即可，对于 1.13 其实这两个变量已经不是必要的了。不过我发现我在安装的依赖的时候，出现报错信息,通过配置 GOROOT 为 `/usr/loca/go` 即可解决。但有一个配置很重要，就是将 goproxy 设置为国内的代理（这里使用的是七牛云的代理），这样你就能体验飞一般的畅快。

```
export GOPROXY=https://goproxy.cn,direct
```

## 原有代码升级

之前 [gshark](https://github.com/neal1991/gshark) 没有使用任何的依赖管理，完全是通过 GOPATH 存放依赖。这有一个问题，就是项目的依赖做出了不兼容的版本升级，最终导致项目构建失败。通过 Go modules 可以锁定依赖版本，从而避免这个问题。以 gshark(https://github.com/neal1991/gshark) 为例进行 Go modules 的升级。

1. mod 初始化

cd 到项目文件夹中

```
go mod init github.com/neal1991/gshark
```

2. 查找依赖

```
go get ./...
```

只需要两部就可以升级使用 Go modules 就可以了。


## GShark

GShark 是我之前开源的一款 Github 敏感信息监测的系统，之前也有写过[文章](https://mp.weixin.qq.com/s?src=11&timestamp=1569238467&ver=1870&signature=a*PjTnhB8*Dvc1*Xn-4Vom-nY*CUTPmDAKfphYD4pUr7vGsW0KGcZQikkEqUY6nkEgTIAIP5TteLbgECjBskQdJiO8Wc3B4RTNRSc2OAsThOwAGTtITMivnFEYqlYtFv&new=1)介绍这个项目。这个工具应该目前有一些同学在使用，可能使用过程中最大的问题就是项目的构建。因为可能有的同学之前不是特别熟悉 Golang 语言，觉得部署起来很麻烦。但其实 Golang 项目的构建特别方便，之前不方便主要还是由于项目的依赖比较难下。可是如果 Golang 升级到 1.13 之后，项目构建仅仅需要几步。

1. 下载代码

```
git clone https://github.com/neal1991/gshark
```

2. 下载依赖

```
go get ./...
```

3. 编译

```
go build main.go
```

4. 运行

运行之前需要把 conf 文件夹里面的 app-template.ini 重命名为 app.ini，使用自己的配置即可。

```
// 启动 web 服务
./main web

// 启动爬虫
./main scan
```

通过上面几步就可以启动 GShark 服务了。GShark 目前仅仅由我一个人维护，希望可以吸收社区优秀的建议，欢迎 PR。可以扫码加入微信群。

![uiIAiD.png](https://s2.ax1x.com/2019/09/23/uiIAiD.png)

## 总结

虽然说 gorpoxy 以及 modules 都不是 1.13 版本才有的。但是目前这些特性在 1.13 版本已经稳定运行。总的来说，升级到 Go 1.13，真香。

