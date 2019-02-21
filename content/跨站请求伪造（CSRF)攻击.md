---
title: "跨站请求伪造（CSRF）攻击"
author: Neal
tags: [安全, web 安全]
categories: [安全]
date: "2019-02-21" 
---

## 概述

跨站请求伪造（CSRF）攻击强迫终端用户在他们身份被认证的情况下执行不希望的操作。CSRF 攻击专门针对状态更改请求，而不是数据被盗，因为攻击者无法查看对伪造请求的响应。通过社会工程的（例如通过电子邮件或聊天发送链接），攻击者可以欺骗 Web 应用程序的用户执行攻击者选择的操作。如果受害者是普通用户，则成功的 CSRF 攻击可以强制用户执行状态更改请求，例如转移资金，更改其电子邮件地址等。如果受害者是管理帐户，CSRF 可能会危及整个 Web 应用程序。

值得注意的一点是 CSRF 攻击经常与 XSS 攻击（特别是反射性 XSS）混淆。XSS 攻击通常是在合法的网络应用中注入恶意的内容为受害者提供服务。注入的内容会被浏览器执行，因此进本会执行。CSRF 的攻击通常是让目标在不知情的情况下执行一个操作（比如转账，表单提交），如果当前目标用户的还是已授权状态，那么这些操作就有可能会执行成功。

## CSRF 的工作原理

CSRF 攻击是通过让一个已授权的用户的浏览器向应用发起一个恶意请求（用户尚不知情的情况）。只要用户的身份已被验证过且实际的请求已经通过用户的浏览器发送到目标应用，应用无法知道情况的来源是否是一个有效的交易或者这个用户是在知情的情况下点击这个链接。通过 CSRF 攻击，攻击者可以让受害者执行一些他们不知情的操作，比如，登出，买东西，改变账户信息或者其它目标攻击应用提供的服务。

下面就是一个例子在机票供应商那里购买飞机票：

```
POST http://TicketMeister.com/Buy_ticket.htm HTTP/1.1
Host: ticketmeister
User-Agent: Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O;) Firefox/1.4.1
Cookie: JSPSESSIONID=34JHURHD894LOP04957HR49I3JE383940123K
ticketId=ATHX1138&to=PO BOX 1198 DUBLIN 2&amount=10&date=11042008
```

响应代表购买飞机票的 POST 请求已经成功执行：

```
HTTP/1.0 200 OK
Date: Fri, 02 May 2008 10:01:20 GMT
Server: IBM_HTTP_Server
Content-Type: text/xml;charset=ISO-8859-1
Content-Language: en-US
X-Cache: MISS from app-proxy-2.proxy.ie
Connection: close

<?xml version="1.0" encoding="ISO-8859-1"?>
<pge_data> Ticket Purchased, Thank you for your custom.
</pge_data>
```

## 如何定位存在潜在漏洞的代码

这个问题比较容易检测到，可能的补救措施就是警告用户这可能是一个 CSRF 攻击。次要应用接受一个精心构造的 HTTP 请求冰球这个请求符合应用的业务逻辑，那么这个 CSRF 攻击就可以成功（我们设定用户已经登陆到攻击的目标应用）。

我们要确保页面的链接都是带有唯一标识的，加入任意一个 HTTP 请求没有和唯一的标识相关联，那么这个应用就可能会遭受攻击。Session ID 并不足够，因为当用户已经被授权的情况下，当用户点击恶意链接的时候，session ID 也会产生。

### 以眼还眼，以请求还请求

当应用接收到一个 HTTP 请求时，应该检查业务逻辑来评估请求的合法性，而不是简单地立马执行，而是应该响应另外一个请求，要求用户输入密码。这也是大多数网上交易的时候，比如支付宝或者手机银行转账等操作，都是需要用户再次输入密码，从而避免遭受攻击。

总的来说，如果应用对于来自授权用户的请求无法验证这个请求在用户 session 有效的时间段内的唯一性，那么就有可能会有 CSRF 的攻击的风险。


## 防范 CSRF 攻击

检查请求是否带有合法的 session cookie是不足够的，我们需要检查每一个发送给应用的请求是否带有独特的标识。CSRF 攻击请求不会带有这种唯一并且有效的标识。CSRF 攻击请求不会带有这种唯一标识的原因是：这种独特的 ID 渲染在页面的隐藏区域，只有在链接或者按钮被点击的时候，HTTP 请求才会带上这一独特 ID，因为它是随机的，并且针对每一个链接或者请求来说它都是动态以及随机的。

当页面交付给用户时，有一个清单是需要遵守的。这个清单里面包含对于制定页面每个链接的有效的独特 ID。这些独特的 IS 是通过安全的随机生成器成产，比如 J2EE 中的 SecureRandom。来自于页面的请求都应该添加上这一独特 ID，这些 ID 并不用展示给用户。维护用户 session 有效期内独特 ID 的清单，应用应该检查对于制定请求携带的独特 ID 是否有效。如果不存在独特的 ID，终止用户的 session 以及将错误展示给用户。


### 用户交互

提交事务的时候通过进一步的用户交互可以防范 CSRF 攻击，比如转账，要求用户做另外一个操作，比如要求用户输入密码来验证身份。因为 CSRF 的攻击者并不会知道用户的密码因此这个交易无法在用户不知情的情况下发起 CSRF 攻击。


### 哪一些措施不能阻止 CSRF

* 使用加密 cookie
* 只接受 POST 请求
* 多步骤交易
* URL 重写
* HTTPS 


## Reference

* https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)
* https://www.owasp.org/index.php/Category:OWASP_Code_Review_Project
