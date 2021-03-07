---
title: "SameSite 的七八事"
author: Neal
tags: [开发,安全,应用安全,security,development,web security,chrome,cross-site,csrf]
categories: [安全]
date: "2021-02-17" 
---

## 起源

本篇文章是讨论关于 SameSite 这一属性的相关内容。这次讨论的缘由是内网的一个需求。内网有一个 SSO 应用，但是在 Chrome 80 版本之后，将会强制实行 SameSite 的属性。即 SameSite 的属性默认为 Lax。而这一变化则会影响到这一应用，因为这个 SSO 使用了 iframe，所以会涉及到 cookie 的跨域。