  ---
title: "GShark-监测你的 Github 敏感信息泄露"
author: Neal
description: ""
tags: [go, 安全]
categories: [安全]
date: "2018-10-31"
---

近几年由于 Github 信息泄露导致的信息安全事件屡见不鲜，且规模越来越大。就前段时间华住集团旗下酒店开房记录疑似泄露，涉及近5亿个人信息。后面调查发现疑似是华住的程序员在 Github 上上传的 CMS 项目中包含了华住敏感的服务器及数据库信息，被黑客利用导致信息泄露（这次背锅的还是程序猿）。

## 起源

对于大型 IT 公司或者其他行业，这种事件发生的概率实在是太常见了，只不过看影响的范围。现在大家看到的，也仅仅只是传播出来的而已。企业没办法保证所有人都能够遵守规定不要将敏感信息上传到 Github，尤其是对于那种特别依赖于外包的甲方企业，而甲方的开发人员也是一无所知，这种事件发生也就是司空见惯了。

废话说了一大通（可能是最近看安全大佬的文章看多了），终于要介绍一下我的这个项目，[GShark](https://github.com/neal1991/gshark)。这个工具主要是基于 golang 实现，这也是第一次学习 golang 的项目，结合 go-macron Web 框架实现的一个系统。其实最初我是看到小米安全开源的 [x-patrol](https://github.com/MiSecurity/x-patrol) 项目。网上这种扫描 Github 敏感信息的工具多如皮毛，我看过那种 star 数上千的项目，感觉实现方式也没有很好。因为说到底，大家都是通过 Github 提供的 API 结合相应的关键字来进行搜索的。但是，x-patrol 的这种实现方式我觉得是比较合理的，通过爬虫爬取信息，并对结果进行审核。所以，最初我是一个 x-patrol 的使用者。使用过程中，也遇到过一些问题，因为这个库似乎就是小米的某个固定的人维护的，文档写的不是特别清晰。中间我有提过 PR，但都被直接拒绝掉了。后来，我就想基于 x-patrol 来实现一套自己的系统，这也就是 GShark 的来由了。目前，这个项目与 x-patrol 已经有着很大的变化，比如移除了本地代码的检测，因为这个场景没有需求，其实我本身自己也实现了一个基于 lucene 的敏感信息检索工具。另外，将前端代码进行了梳理，并使用模板引擎来做模板的嵌套使用。基于 [casbin](https://github.com/casbin/casbin)实现基于角色的权限控制等等。

## 原理

讲完了起源，接着讲一讲这个系统的原理。基本上，这类工具都是首先会在 Github 申请相应的 token 来实现，接着通过相应的 API 来进行爬取。本项目主要是基于 Google 的 [go-github](https://github.com/google/go-github)。这个 API 使用起来还是比较方便的。通过这个 API 我们可实现在 Github 来进行搜索，其实这基本上等同于 [Advanced Search](https://github.com/search/advanced?)。因为 API 提供的搜索能力肯定就是 Github 本身所具有的搜索能力。最基本的包括关键及，以及一些 owner 信息以及 star 数等等。

[![iWe0kn.md.png](https://s1.ax1x.com/2018/10/31/iWe0kn.md.png)](https://imgchr.com/i/iWe0kn)

另外一点就是 Github 的搜索是基于 elasticsearch 的，因此也是支持 lucene 语法的。GShark 的黑名单过滤其实就是通过这个规则来实现的。

通过爬虫将代码结果爬取到数据库中，那么我们就可以在 Web 界面进行代码的审核。因为其实很多包含关键字的代码并不一定就是你想要的，有很多种可能，爬虫项目，一些文件的随机乱码，博客等等。但是一般来说对于人工审核来说，一般这种代码仓库很容易就可以区分出，审核就是还快的。对于那种比较疑似的，可能需要进一步调查，可能就需要进一步获取信息，比如阅读代码信息，查看上传者信息等等。对于一条记录，一共有三种操作，确认为敏感信息，忽略这条记录，忽略包含这条记录的代码仓库的所有记录。

## 遇到过的问题

在做这个项目的时候，大大小小遇到过很多问题。这也是我第一次学习 golang，以前总是觉得 golang 的语法比较奇怪，但是学习一下感觉还是可以的。Golang 中的依赖是比较
头疼的一个问题，golang 中的依赖包一般都会安装在 GOPATH 中。另外对于一些 golang 依赖包的安装，通过 `go get` 来安装的话是无法安装的，比如 `net/http`，由于某种特殊的原因，我们只能从 Github 上获取源代码，总将其放入 GOPATH 中。还有一个比较纠结的问题是，你应该如何在你的项目中引入自己的 package，一共有三种方式，以 `models` 模块为例，假如我希望在别的 package 中引入 `models`：

* 项目名引用：`gshark/models`
* 相对路径引用：`../models`
* 全名引用：`github.com/neal1991/models`

这三种引用方式我都有使用过，也在这3个里面切换了好几次，最终选择最后一个，这也是最标准的实现方式。第一种方式其实没啥大问题我觉得，只是我在使用 Travis 的时候，它无法识别。第二种方式可能没有第一种那样的问题，但是用起来比较麻烦，而且容易出错。第三种也是大多数 golang 项目使用的方式，这样别人也可以很方便地引入你的项目。

Gshark 实现了一套比较粗糙的权限管理，主要是基于 [casbin](https://github.com/casbin/casbin) 来实现的。GShark 使用的 go-macaron 可以支持使用中间件 [authz](https://github.com/go-macaron/authz) 来实现权限管理，其实它的实现方式也是比较粗糙的，核心代码其实就是下面的一个函数：

```go
func Authorizer(e *casbin.Enforcer) macaron.Handler {
	return func(res http.ResponseWriter, req *http.Request, c *macaron.Context) {
		user, _, _ := req.BasicAuth()
		method := req.Method
		path := req.URL.Path
		if !e.Enforce(user, path, method) {
			accessDenied(res)
			return
		}
	}
}
```

可以看到必须要通过 BasicAuth 来进行认证的，从而获取用户的角色，来实现权限的控制。因为 GShark 没有使用 BasicAuth 来进行认证，所以角色的传递也是一个比较头疼的问题，其实还是使用标准的认证方式比较好，目前因为没有做到，只能通过 cookie 来进行传递，这种方式因此是不太可靠的。

## 项目部署

目前这个项目我部署在我腾讯云的小水管上面，运行没啥问题，因为本来这个应用就不会占用特别多的资源。只不过最近 Github 好像越来越严格，我有一段时间 VPS 访问 Github 一直不成功，而且要注意限制爬取的频率，防止触发 Github 滥用告警。项目部署之前就是项目的安装，其实主要就是依赖包的安装。得益于 golang 的跨平台性，因此这个应用是可以运行在各个平台的。`main.go` 是启动文件：

```
go build main.go
```

Build 之后就会生成平台对应的可执行文件。项目的运行可以通过 CLI 来实现：

```
NAME:
   GShark - Scan for sensitive information in Github easily and effectively.

USAGE:
   main [global options] command [command options] [arguments...]

AUTHOR:
   neal <bing.ecnu@gmail.com>

COMMANDS:
     web      Startup a web Service
     scan     Start to scan github leak info
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --debug, -d             Debug Mode
   --host value, -H value  web listen address (default: "0.0.0.0")
   --port value, -p value  web listen port (default: 8000)
   --time value, -t value  scan interval(second) (default: 900)
   --help, -h              show help
   --version, -v           print the version
```

项目的运行的时候会初始化一些应用和规则配置，你需要将项目中的 app-template.ini 重命名成 app.ini:

```
HTTP_HOST = 127.0.0.1
HTTP_PORT = 8000
MAX_INDEXERS = 2
DEBUG_MODE = true
REPO_PATH = repos
MAX_Concurrency_REPOS = 5

[database]
;support sqlite3, mysql, postgres
DB_TYPE = sqlite
HOST = 127.0.0.1
PORT = 3306
NAME = misec
USER = root
PASSWD = 
SSL_MODE = disable
;the path to store the database file of sqlite3
PATH = 
```

其实里面主要就是服务以及数据库方面信息的配置。值得注意的一点是，如果你希望你的服务能够被外部访问，那么你应该将 HTTP_HOST 设置为 0.0.0.0。我使用的是 sqlite3 数据库，感觉使用起来已经比较方便了，而且对于小型 VPS 来说也是比较合适的。对于 scan 运行的时间间隔我建议可以设置大一点，可以让这个服务一直运行，也可以让它一直跑着。但老实说，一般短时间内，获取的结果也是比较有限的。下面主要是管理界面的使用，使用起来也是比较简单。核心界面就是搜索结果的审核，以及一些其他信息的设置，最主要的是应该为程序提供 token，可以在 Github 中申请。

![](https://user-images.githubusercontent.com/12164075/47776907-72db2a00-dd2e-11e8-9862-db4aa5c458ff.gif)

## 总结和展望

其实这个项目从开始到现在也有大半年的时间，但因为一直都是我一个人维护和使用，所以也都是一直修修补补，在细节方面做更多的改善。虽然，目前这个项目还是不算特别成熟，但还是想把这个项目开源出来正式的维护，并且介绍给更多的开发者，并吸收更多的建议和意见。所以任何建议都是欢迎的，欢迎 issue 以及 PR。

当然了，对于这个项目也有一些更多的期许，以后可能有更多的坑需要填补：

* 完善权限管理
* 实现标准的用户认证，比如 OAuth2
* 更准确地识别结果，或许可以结合机器学习，但目前还是没有思路

以上就是 GShark 的开发过程中的一点小小心得，如果觉得对你有帮助的话，可以 star 一下，https://github.com/neal1991/gshark