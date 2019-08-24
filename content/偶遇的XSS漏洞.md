---
title: "偶遇 XSS 漏洞"
author: Neal
tags: [安全, web 安全]
categories: [安全]
date: "2019-08-22" 
---
最近在公司内网发现了好几个 XSS 漏洞，后来看了一下系统，都是使用的开源项目。后来发现是开源项目自身的漏洞。后面我就去看了一下源代码，下面我们就聊一下这些 XSS 漏洞。

最近公司的被动扫描器发现了一个 XSS 漏洞，后来发现是登录的时候发现是登录请求传入的 `ReturnURL` 参数导致的 DOM 型 XSS 漏洞。后来，又看了一下系统，发现这是一个开源的系统，[RAP](https://github.com/thx/RAP)。 RAP 是一个开源的 Web 接口管理工具，由阿里妈妈前端团队开发，不过目前这个代码仓库已经不维护了，已经迁移到了 [rap2-delos](https://github.com/thx/rap2-delos)。但是 RAP 的 star 数更多，高达 10000+。可以得知，该项目目前应该还有不少人在使用。

其实这个漏洞的原理非常简单。其实就是 `doLogin` 请求会传入一个 `ReturnURL`，而重定向的页面会直接使用 `window.location.href` 来直接重定向 URL。使用 `window.location.href` 其实本来就是一种比较危险的行为，尤其是链接的参数取决于外部输入，更有可能导致 dom 型的 XSS 漏洞。同时，这个漏洞也是一个开放重定向漏洞。不过本文就稍微聊一下这个 XSS 漏洞。开源仓库就是有一个好处，可以直接看代码。下面我们就通过代码来简单解释一下原理。

简单粗暴地在代码仓库中搜索了一下 `window.location.href`，发现代码仓库中有多处使用了 `window.location.href`。不过我们很快就发现了一个有趣的代码，正是重定向页面的代码。

![m0w7lR.png](https://s2.ax1x.com/2019/08/22/m0w7lR.png)

关键代码就是：`window.location.href = decodeURIComponent("$returnUrl");`。这段代码没有对 `returnUrl` 做任何的处理，而且这段代码就是直接放在 `script` 标签中。毫无疑问，这种一定会导致 XSS 漏洞，可以通过构造 `returnUrl` 来闭合双引号从而导致 XSS 漏洞。比如，`"alert(/xss/);//`，这段代码就可以导致 XSS 漏洞。

再看看调用这个页面的地方：

```java
    public String doLogin() {
        // 增加验证码
        Map<String,Object> session = ContextManager.currentSession();
        String kaptchaExpected = (String)session.get(com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY);
        if(getKaptcha() == null || !getKaptcha().equals(kaptchaExpected)) {
            setErrMsg("验证码错误");
            return ERROR;
        }

        if (super.getAccountMgr().validate(getAccount(), getPassword())) {
            User user = getAccountMgr().getUser(getAccount());
            if (user != null && user.getId() > 0) {
                session.put(ContextManager.KEY_ACCOUNT, user.getAccount());
                session.put(ContextManager.KEY_USER_ID, user.getId());
                session.put(ContextManager.KEY_NAME, user.getName());
                Set<Role> roleList = new HashSet<Role>();
                for (Role role : user.getRoleList()) {
                    Role copied = new Role();
                    copied.setId(role.getId());
                    copied.setName(role.getName());
                    roleList.add(copied);
                }
                session.put(ContextManager.KEY_ROLE_LIST, roleList);
            } else {
                setErrMsg("用户不存在或密码错误");
                return ERROR;
            }
            if (getReturnUrl() != null && !getReturnUrl().trim().equals("")) {
                return "redirect";
            }
            return SUCCESS;
        } else {
            setErrMsg("用户不存在或密码错误");
            return ERROR;
        }
    }
```

里面的关键代码就是：

```java
if (getReturnUrl() != null && !getReturnUrl().trim().equals("")) {
    return "redirect";
}
```

可以理解，`doLogin` 请求时如果传入 `returnUrl` 参数，那么就会跳转到 `redirect.vm`。并且将 `returnUrl` 传入到页面中，从而导致 XSS 漏洞。之前在内网也发现过将参数传入到 javascript 代码中。只要可以通过可以将参数传入到 js 代码中，那就一定会形成 XSS 漏洞。

## 总结

其实这个漏洞的解决也很简单，需要对 `returnUrl` 进行编码以及处理，而不是不作任何处理直接传入到前端页面中，更不多要说是直接传入到 `script` 标签中，并且使用了比较危险的方法 `window.location.hred`。

之前有很多网站，是将外部输入的参数直接放入到响应中返回，甚至是页面的 js 中，毫无以为这不是一种安全的方法。总结全文，可以得出以下几点：

* 对于重定向地址，应该需要做控制和过滤
* 对于外部的参数应该需要做编码处理，不应将外部参数未做任何处理直接响应到页面中
* 尽量不要使用危险的方法，比如 `window.location.href`, `documen.innerHTML`, `document.write` 等方法
