---
title: "JavaScript 能否修改 Referer 请求头"
author: Neal
tags: [开发,安全,web-security,web,request,JavaScript]
categories: [安全]
date: 2021-03-09
---
正如题目，本文的也很直白，主要就是围绕这个问题展开。JavaScript 能否修改 Referer 请求头？现在 JavaScript 的能力越来越强大，JavaScript 似乎无所不能，修改一个小小的 Referer 请求头似乎看来不在话下（本文讨论的 JavaScript 仅限于在浏览器中执行，不包括 Nodejs）。

其实不然，在 web 浏览器中，绝大多数浏览器都禁止了 JavaScript 直接去操作 Referfer 请求头，当然这一方面也是出于安全方面的考虑。当然除了 Referer 请求头之外，还有其它请求头也被禁止通过 JavaScript 操作。

Referer 请求头属于 Forbidden header，这种请求头无法通过程序来修改，浏览器客户端一般会禁止这种行为。以 `Proxy-` 和 `Sec-` 开头的请求头都属于 Fobidden header name，还包括以下这些请求头：

```
Accept-Charset
Accept-Encoding
Access-Control-Request-Headers
Access-Control-Request-Method
Connection
Content-Length
Cookie
Cookie2
Date
DNT
Expect
Feature-Policy
Host
Keep-Alive
Origin
Proxy-
Sec-
Referer
TE
Trailer
Transfer-Encoding
Upgrade
Via
```

可以通过一段简单的 demo 来进行验证。可以通过 Chrome 的开发者工具来进行验证，创建一个 xhr 请求，并且尝试来设置请求头。

![image.png](https://i.loli.net/2021/03/09/mwgJZQ2MPtlT14o.png)

可以看出，如果设置 `content-type`，浏览器没有阻止，但是如果设置 `Referer` 的话，浏览器则不允许，提示 `Refused to set unsafe header "Referer"`。

得益于这一特性，其实 Referer 请求头也被用于作为 CSRF 防护的补充手段之一，如果用户是通过恶意网站来访问应用的，可以通过 Referer 请求头来进行验证。但是，因为一些浏览器兼容性的特性以及可以通过某些手段可以强制不带 Referer 请求头，所以这个方法只能作为一个补充方法来进行验证。

## Reference
* https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_header_name