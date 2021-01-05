---
title: "从一个开放重定向绕过到apache/dubbo的bug"
author: Neal
tags: [架构,apache dubbo,开源,开放重定向,open redirect, SSRF, 开发,安全,代码审计,security,development,web security,]
keywords: [架构,apache dubbo,开源,开放重定向,open redirect, SSRF, 开发,安全,代码审计,security,development,web security,]
categories: [代码审计]
date: "2021-01-03" 
---

近期在内网发现了有个应用之前的开放重定向漏洞的绕过，通过这个漏洞绕过，我又发现了 [apache/dubbo](https://github.com/apache/dubbo) 的一个有意思的问题。

之前，有给内网应用提交过一个开放重定向漏洞，后面又发现这个开放重定向漏洞存在一个绕过方法。假设一个恶意 URL 为 `https://evailhost#@whitehost`，那么这个恶意链接依然可以实现跳转。开发说他们已经做过了白名单限制，理论上应该不存在被绕过的可能了。那么我就去看了下代码，业务代码类似如下。

```java
public static String checkUrlSafety(String url, List<String> domainWhitelistSuffix, String domainWhitelist) {
	Url url2 = null;
	try {
		url2 = UrlUtils.parseURL(url, null);
	} catch (Exception e) {
	}
	String host = url2.getHost();
	if (verifyDomain(host, domainWhitelistSuffix, domainWhitelist)) {
		return url;
	} else {
		...
	}
}


private static boolean verifyDomain(String host, List<String> domainWhitelistSuffix, String domainWhitelist) {
	return domainWhitelist.contains(host) || verifyDomainSuffix(host, domainWhitelistSuffix):
}
```

核心代码其实主要就是上面两个函数，主要是通过 `verifyDomain` 方法来进行白名单的过滤，那么问题就很有可能出现在这里。这里，值得注意的是，`host` 是通过 `UrlUtils.parseURL` 解析出来的 `URL` 获取的。这个方法是开源仓库 apache/dubbo 的，看了下版本是 2.7.8，是最新的版本。可以简单的通过一个 demo 代码来验证我的猜想。

```java
import org.apache.dubbo.common.URL;
import org.apache.dubbo.common.utils.UrlUtils;

public class Main {

    public static void main(String[] args) throws Exception {
        String[] whiteHosts = new String[]{"whitehost"};
        String evilUrl = "https://evilhost#@whitehost";
        URL url = UrlUtils.parseURL(evilUrl, null);
        System.out.println(url.getHost());
        System.out.println(whitehostCheck(whiteHosts, url.getHost()));
        java.net.URL url1 = new java.net.URL(evilUrl);
        System.out.println(url1.getHost());
        System.out.println(whitehostCheck(whiteHosts, url1.getHost()));
    }

    private static boolean whitehostCheck(String[] whiteHosts, String hostToCheck) {
        for(String host: whiteHosts) {
            if (host.equals(hostToCheck)) {
                return true;
            }
        }
        return false;
    }
}
```

上面的执行结果是：

```
evilhost
false
whitehost
true
```

很明显可以看出来，应该问题出现在 `parseURL` 这个方法上，它错误地解析了一个链接的 host，如果这个链接中包含 `@` 符号。那么下面就应该看看这个 `parseURL` 方法，这个函数位于 [`org.dubbo.common.utils.UrlUtils.java`](https://github.com/apache/dubbo/blob/2d9583adf26a2d8bd6fb646243a9fe80a77e65d5/dubbo-common/src/main/java/org/apache/dubbo/common/utils/UrlUtils.java#L67) 中。不如打个断点，进去看看。



