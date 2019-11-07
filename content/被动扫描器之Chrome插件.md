---
title: "被动扫描器之插件篇"
author: Neal
tags: [安全, web 安全, chrome 插件]
categories: [安全]
date: "2019-09-28" 
---

最近被动扫描器的话题如火如荼，好多公司都在做自己的被动扫描器。而获取质量高的流量是被动扫描器起作用的关键。笔者主要开发了两个被动扫描器的插件，[r-forwarder](https://github.com/neal1991/r-forwarder) 以及 [r-forwarder-burp](https://github.com/neal1991/r-forwarder-burp)，两个插件的代码都在 Github 上开源。两个插件分别为 Chrom 插件以及 Burp 插件，本文也从笔者开发这两个插件的经验来聊一聊被动扫描器中插件的开发。

## Chrome 插件

Chrome 插件是向 Chrome 浏览器添加或修改功能的浏览器拓展程序。一般通过 JavaScript, HTML 以及 CSS 就可以编写 Chrome 插件了。市面上有很多非常优秀的 Chrome 插件拥有非常多的用户。Chrome 插件的编写也比较简单，基本上你熟悉一点前端知识，然后熟悉一下 Chrome 插件的 API，你就可以编写 Chrome 插件。Chrome 插件的安装，如果你没有发布在 Chrome 商店的话（因为网络原因，可能没办法直接从商店下载），可以通过开发者模式安装 Chrome 插件。或者你也可以注册 Chrome 插件的开发者账号（只需要 5 美元，就可以发布 20 个插件）。

简单地介绍了一下 Chrome 插件的开发，咱们主要还是聊一下关于 Chrome 插件关于被动扫描器的方面的内容。对于 Chrome 插件，主要是通过插件的能力去获取经过浏览器的流量，并将流量转发给后端来进行处理。Chrome 插件关于网络流量的处理地 API 主要有两个：[chrome.devtools.network](https://developer.chrome.com/extensions/devtools_network) 以及 [chrome.webRequest](https://developer.chrome.com/extensions/webRequest)。但是前者使用的时候需要打开 Chrome 开发者工具，这个有一点不太方面，所以选择了后者，这也是对于被动流量获取一种常见的方式。

Chrome 插件中的 webrequest API 是以相应的事件驱动的，其中请求的生命周期图如下，主要有7个事件。只需要监听关键事件进行处理就可以满足被动扫描器获取流量的需求了。

![Mi0arD.png](https://s2.ax1x.com/2019/11/06/Mi0arD.png)

其实这些事件不难理解，基本通过事件的名称就可以知道事件的含义了，主要就是请求发送前，发送请求头之前，发送请求头等等事件。对于不同的事件，可以获取的流量数据也是不尽相同的。首先，考虑一下，对于被动扫描器来说，哪些流量数据是比较关心的。被动扫描器主要是通过收集业务的正常流量来进行测试，提高测试的效率，并能取得比主动扫描器更好的效果。那么一般来说，被动扫描器最关心的就是请求的 URL 以及请求头了，如果是 POST 请求，还需要请求体。对于扫描器来说，响应头和响应体则没那么重要，其实可以通过响应状态过滤一下，一般只需要能够正常响应的请求头以及请求体即可。

对于被动扫描器上述的需求，chrome.webrequest 中的 onBeforeRequest 以及 onSendHeaders 这两个事件可以满足需求。通过前者，可以获取请求体。通过后者则可以获取请求头。不过在使用 onSendHeaders 的时候，有好几点需要注意：

### 兼容问题

从 Chrome 79 开始，必须要在 opt_extraInfoSpec 中指定 extraHeaders 才可以获取 Origin 请求头。从 Chrome 72 开始，必须要在 opt_extraInfoSpec 中指定 extraHeaders 才可以获取 以下请求头：

* Accept-Language
* Accept-Encoding
* Referer
* Cookie

毫无疑问，这些请求头都是有价值的。为了获取这些请求头，你必须在 opt_extraInfoSpec 中指定 extraHeaders 才可以获取相应的请求头。同时，注意做兼容性检查，因为之前的版本的是不需要指定的，如果你在之前版本的浏览器也指定了属性，就会产生报错。

```javascript
const headers = version >= 72 ? ["requestHeaders", "extraHeaders"] : ["requestHeaders"];
chrome.webRequest.onSendHeaders.addListener(
beforeSendHeaderHandler, requestFilters, headers
)
```

### requestBody 的格式问题

可以通过 onBeforeRequest 事件来获取 POST 请求中的请求体。但有一点注意，chrome.webrequest 中把请求体进行了解析，所以你获取的不是原生的请求体。请求体位于 requestBody 中的 fromData，而 formData 其实是有两种形式，一种是键值对形式的字典，这种一般对于请求体类型为 `multipart/form-data` 或者 `application/x-www-form-urlencoded` 而言，一般即为 `a=xxx&b=xxx&c=xxx` 这种形式；另外一种则是原生的字节，这个官方的 API 文档没有直接提到，你需要自己手工解析数据。

```javascript
const postbody = decodeURIComponent(String.fromCharCode.apply(null,
                                      new Uint8Array(details.requestBody.raw[0].bytes)));
```

### 使用 RequestFilter 去过滤请求

如果你希望在事件中可以过滤特定的请求地址或者请求的资源类型，那么就可能需要使用到 RequestFilter 了。RequestFilter 里面有4个属性，比较重要的属性就是 urls 以及 types，通过这两个属性就可以过滤特定的请求 URL 以及资源类型。

但是注意一点是，RequestFilter 是在注册事件的时候配置的参数的，不可以后续直接修改。不过有一种方法是先移除监听事件，再添加新的事件。

```javascript
if (!chrome.webRequest.onSendHeaders.hasListener(beforeSendHeaderHandler)) {
  chrome.webRequest.onSendHeaders.addListener(
    beforeSendHeaderHandler, requestFilters, headers
  )
}
```

## Burp 插件篇

Burp 是渗透测试中不可缺少的工具之一，而 Burp 插件也让测试者如虎添翼，达到事半功倍的效果。同时，开发 Burp 插件也是为了弥补一些系统无法在 Chrome 中使用的场景来进一步地补充。

Burp 插件开发的资料网上不是特别的丰富，之前也写过一篇文章“[如何写一个 Burp 插件](https://mp.weixin.qq.com/s/nKBYIHGofaBDwemKX3cQqA)”。其实开发 Burp 插件比较简单，只要遵守基本的规范，然后学习一下 API 的使用，基本就可以完成 Burp 插件的开发了。反倒是如果希望在 Burp 插件中开发 GUI 有点困难，因为使用 JAVA 来写 GUI 比较麻烦，毕竟不能像 C# 那样，妥妥拽拽就搞定了，不过这也不是本文的重点。

其实在 Burp 中的 Extender 标签页中的 APIs 就可以看到提供的 API 接口。基本上每个函数都有参数说明的注释，不过其实学习 Burp 插件的最好的方法就是拿一个现成的插件代码看一下，就可以很好地理解这些 API 的作用了。

![MAhOQU.png](https://s2.ax1x.com/2019/11/07/MAhOQU.png)

在这，以我开发的 Burp 插件 [r-forwarder-burp](https://github.com) 为例，使用 JAVA 开发。在开发 Burp 插件需要注意几点。必须定义一个 BurpExtender 类，并且必须实现 IBurpExtender，如果还需要其他 API 可以实现多个其它接口，JAVA 中的类是可以实现多个接口的。另外还需要重写父类中的 registerExtenderCallbacks 方法。同样，针对被动扫描器的需求，在 Burp 插件中我们最主要涉及的接口是 IHttpListener 接口。这个主要涉及到 HTTP 

```java
public interface IHttpListener
{
    /**
     * This method is invoked when an HTTP request is about to be issued, and
     * when an HTTP response has been received.
     *
     * @param toolFlag A flag indicating the Burp tool that issued the request.
     * Burp tool flags are defined in the
     * <code>IBurpExtenderCallbacks</code> interface.
     * @param messageIsRequest Flags whether the method is being invoked for a
     * request or response.
     * @param messageInfo Details of the request / response to be processed.
     * Extensions can call the setter methods on this object to update the
     * current message and so modify Burp's behavior.
     */
    void processHttpMessage(int toolFlag,
            boolean messageIsRequest,
            IHttpRequestResponse messageInfo);
}
```

在 processHttpMessage 方法中，主要涉及到以上3个参数。toolFlag 主要指的是和请求相关的 Burp 工具，比如 Proxy 以及 Repeater。可以在 IBurpExtenderCallbacks 接口中看到相应的定义。

![MATiAH.png](https://s2.ax1x.com/2019/11/07/MATiAH.png)

messageIsRequest 则表示是请求还是响应，而我们只关心请求部分。通过解析 messageInfo 则可以获取请求头以及请求体数据。

```java
public Map<String, String> getHeaders(IHttpRequestResponse messageInfo) {
    Map<String, String> headers = new HashMap<>();
    IRequestInfo analyzeRequest = helpers.analyzeRequest(messageInfo);
    List<String> h = analyzeRequest.getHeaders();
    for (String h1: h) {
        if (h1.startsWith("GET") || h1.startsWith("POST")) {
            continue;
        } else {
            String[] header = h1.split(":", 2);
            headers.put(header[0], header[1].trim());
        }
    }
    return headers;
}

private String getBody(IHttpRequestResponse messageInfo) {
    IRequestInfo requestInfo = helpers.analyzeRequest(messageInfo);
    int bodyOffset = requestInfo.getBodyOffset();
    byte[] byteRequest = messageInfo.getRequest();
    byte[] byteBody = Arrays.copyOfRange(byteRequest, bodyOffset, byteRequest.length);
    return new String(byteBody);
}
```

上面是简单开发的内容方面的介绍，其它方面可以直接看[源代码](https://github.com/neal/r-forwarder-burp)了解更多，尤其是 GUI 开发的部分。另外想说明的一点就是如何打 jar 包。通过 maven-assembly-plugin 插件可以很方便地打包，只需要配置如下，然后通过 `mvn package` 即可进行打包。

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
        </descriptorRefs>
    </configuration>
</plugin>
```

另外注意如果使用了外部依赖的时候，需要配置 `jar-with-dependencies`，这样在打包的时候就可以把依赖的 jar 包一并打进去。最后，成品的 jar 包安装之后就可以使用了。

![MAqcJH.gif](https://s2.ax1x.com/2019/11/07/MAqcJH.gif)

## 总结

以上就是在开发被动扫描器 Chrome 插件以及 Burp 插件遇到的一些坑，在这里和大家分享一下。其实被动扫描器开发，最重要的还是一些细节方面的考虑，可以将插件的功能做到更完美。




