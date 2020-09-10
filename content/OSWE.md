---
title: "一键 Shell，我的 OSWE 之旅"
author: Neal
tags: [全栈,开发,安全,网络安全,security,development,web security,code review,OSWE,AWAE,Offsec, Offensive Security]
categories: [安全]
date: "2020-09-06" 
---

终于收到了 Offsensive Security 的官方邮件通知最终结果，我的 OSWE 之旅也算是尘埃落定。打算以本文回顾一下自己的 OSWE 的准备过程，包括 AWAE 课程的学习和准备以及我在考试过程中踩得一些坑，希望后面对 OSWE 有兴趣的人能有所帮助。

## 初识 AWAE

Offsensive Security，作为安全圈的人应该都熟悉这家公司，Kali 就是他们家的。他们家最广为人知的课程也是 Pentration Testing with Kali Linux(PWK)，其对应的考试为 Offsensive Security Certified Professional(OSCP)。我最初结识 Offsec 也是通过 OSCP，认识了一些考 OSCP 的小伙伴，结果一直因为没(bao)有(ming)准(fei)备(tai)好(gui)，迟迟没有报名。结果大佬们一个个都通过了，报名费也从799美元涨到了999美元。

所以，当 AWAE 去年年末打折的时候，我毫不犹豫的就报名了。

## AWAE 课程

AWAE(Advanced Web Attacks and Exploitation) 是一门关于应用安全的审计课程。AWAE 经常被拿来和 OSCP 的 PWK 来进行比较，官方也有暗示 OSWE 是 OSCP 的进阶版本，OSCP 注重于漏洞的利用，而 OSWE 则更进一步，侧重于市从白盒角度去审计代码，发现安全漏洞。

关于 AWAE 的课程内容，官方有给出[大纲](https://www.offensive-security.com/documentation/awae-syllabus.pdf)。而且今年有课程的内容可以更新，当时如果你的 lab 还有效的话，可以免费更新，不过我当时的 lab 已经失效了，就没有更新了。新加入的内容包括了新的漏洞类型，包括 XXE 漏洞、弱随机口令生成漏洞、DOM 型 XSS、SSTI 以及 websocket 命令注入等。

AWAE 的课程内容其实在网上很多都已经有了相关的介绍。AWAE 的课程其实主要就是一个 PDF 以及 视频。我建议可以吧 PDF 看完再去看视频，因为视频没有字幕，而字幕其实就是 PDF 文档。AWAE 的课程主要涵盖的是比较常见的漏洞类型，不过课程里面介绍的一些技巧还是非常重要的，因为很多技巧可能在考试中都会涉及。所以对于课程的内容一定要熟悉。建议 PDF 和视频可以多看几遍，exercise 以及 extra mile 都可以认真地做一下，如果实在卡住了，可以去论坛看看，如果你一页页翻得话，肯定可以找到对你有所启发的评论。我当时是买了一个月的 lab，加上当时是疫情期间，所以可以学习的时间也比较多一点，而且当时的 lab 还没有更新，所以机器少一点，一个月差不多刚好可以学完。不过现在的课程内容丰富了不少，一个月时间可能就比较紧张了。

得益于我国的网络环境，lab 可能无法直连，当初我也被折磨了很久。后来，我琢磨出最佳的方案就是，VPS 直接拨 openvpn，然后直接在服务器上操作。如果需要访问 web 应用的话，可以通过服务器的 socks 端口进行转发。实在是需要界面操作的话，我更推荐使用 x2goclent 而不是 VNC，相对来说使用体验优秀很多，不过还是会比较卡的，要有心理准备。学习过程中也应该做好笔记，包括踩到过什么坑，以及如何解决的，建议都做好记录，后面可能会有用。

## OSWE 考试

考试应该是重头戏，应该是大家最为关注的部分，毕竟证书还是比较有意义的。其实 OSWE 的考试过程可能和 OSCP 比较类似，OSWE 的考试形式也就是给你 2 台靶机和 2 台对应的调试机器。需要完成代码审计，并且完成 auth bypass 以及 get shell，才能拿到所有的分。另外重要的一点就是，你需要将整个利用过程通过脚本实现，即通过脚本既可以完成 auth bypass 以及 get shell。所以，OSWE 考试需要一定的开发能力，并且要很好地调试自己的代码，因此需要一定的开发能力。