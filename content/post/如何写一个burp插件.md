---
title: "如何写一个 burp 插件"
author: Neal
tags: [安全, web 安全，安全开发, burp, burp 插件]
categories: [安全]
date: "2019-08-31" 
---

Burp 是 Web 安全测试中不可或缺的神器。每一个师傅的电脑里面应该都有一个 Burp。同时 Burp 和很多其他神器一样，它也支持插件。但是目前总体来说网上 Burp 插件开发的资料不是特别特别的丰富。今天我也来讲讲自己如何从一个完全不会 Burp 插件开发的小白如何学习 Burp 插件的开发。

## 如何调试

其实开发一样东西，调试真的特别重要。如果没有调试，那就和瞎子摸象差不多，非常的难顶。尤其是在 Burp 插件的开发过程中，如果你不可以调试，那你就必须把 jar 包打包出来，再安装，然后通过 output 来打印调试，这样的确非常地痛苦。后来在网上找了一些资料，一开始没太明白，后来研究发现原来调试配置这么简单。这么我们以宇宙 JAVA 开发神器 IDEA 为例。

1. 配置 DEBUG

首先是在 IDEA 里面配置调试。点击右上角里面的配置，点击 "Edit Configurations" 就可以进入对 DEBUG 的配置页面。新增一个 Remote 配置，命名可以随自己的喜好。

![mxiIde.png](https://s2.ax1x.com/2019/08/31/mxiIde.png)

2. 命令行启动 Burp

为了配合调试，需要在命令行中使用刚才新建 DEBUG 配置的参数来启动 Burp。

```
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar burpsuite_community_v2.1.02.jar
```

3. 部署 jar 包，打断点

可以现在程序中打一下断点。接着就是编译 jar 包，并且启动 IDE 的 DEBUG。将 jar 包部署到 Burp 中，下面就可以快乐地调试了。

![nSZGi8.png](https://s2.ax1x.com/2019/09/01/nSZGi8.png)

## Burp 开发

老是说其实 Burp 插件开发其实还是比较简单的，只要你掌握常规的套路，熟悉了基本的 API 之后，基本就可以进行插件的开发。插件开发最困难的部分其实是 GUI 的开发，不过这也属于 JAVA GUI 开发的范畴，这个暂不讨论。Burp 开发注意以下几点：

* 所有 Burp 插件都必须实现 IBurpExtender 接口
* 实现的类必须叫做 BurpExtender
* 必须要重写 registerExtenderCallbacks 方法

后续如果需要调用启用其它接口的方法，那么也需要在 BurpExtender 中实现相应的接口。讲一个例子，比如要对 Proxy 进行相关的操作。

首先，需要在 BurpExtender 中实现 IProxyListener 接口，接下来就需要实现 processProxyMessage 方法。在 processProxyMessage 方法中，就可以对发送的请求以及相应进行处理。

```java
public void processProxyMessage(boolean messageIsRequest, final IInterceptedProxyMessage iInterceptedProxyMessage)
```

下面再讲一个例子，获取请求中的请求头：

```java
    public List<Map<String, String>> getHeaders(IHttpRequestResponse messageInfo) {
        List<Map<String, String>> headers = new ArrayList<>();
        IRequestInfo analyzeRequest = helpers.analyzeRequest(messageInfo);
        List<String> h = analyzeRequest.getHeaders();
        for (String h1: h) {
            Map<String, String> hMap = new HashMap<>();
            if (h1.startsWith("GET") || h1.startsWith("POST")) {
                continue;
            } else {
                String[] header = h1.split(":", -1);
                hMap.put(header[0], header[1]);
            }
            headers.add(hMap);
        }
        return headers;
    }
```
## 总结

其实总的来说 Burp 插件开发并不特别困难，只要当一个合格的 API 调用者就可以了。网上目前也有很多开源的 Burp 插件代码，其实你可以找一个感兴趣的 Burp 插件代码看一下，你就可以快速地了解这些 API 的作用。其实 Burp 的 Extender 中的 APIs 就已经列出了所有可用的 API 接口。

![m1jSLd.jpg](https://s2.ax1x.com/2019/08/19/m1jSLd.jpg)

