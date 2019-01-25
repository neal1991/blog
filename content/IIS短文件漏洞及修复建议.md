---
title: "IIS短文件漏洞及修复建议"
author: Neal
tags: [安全]
categories: [安全]
date: "2019-01-14" 
---

最近公司有几个系统有发现 IIS 短文件名的漏洞，这个漏洞也是比较久的漏洞了，网上也是有不少的修复方案。但是有的修复方案还是没有彻底修复。以下也是自己做一个全面的总结以及彻底以及完美的修复方案。

## 什么是 IIS 短文件漏洞

为了兼容 16 位的 MS-DOS 程序，Windows 为文件名较长的文件（文件夹）生成了对应的 windows 8.3 短文件名。在 Windows 下，对应的短文件名可以使用 `dir /x` 命令来查看。如下图，`.gitconfig` 对应的短文件名就是 `GITCON~1`.

![FxOYFA.png](https://s2.ax1x.com/2019/01/14/FxOYFA.png)

基于此特性，并结合 IIS 对于请求路径中包含通配符不同的响应的特性，IIS 对于存在的短文件名的响应码为 404，对不存在的短文件名的响应码是 400.根据这个特点，可以暴力破解出 IIS 中存在的短文件名。关于短文件漏洞， Soroush Dalili 在 2012 年就有[论文](https://soroush.secproject.com/downloadable/microsoft_iis_tilde_character_vulnerability_feature.pdf)是关于这方面的研究。里面详细阐述了 IIS 短文件名的漏洞利用原理。


## 漏洞修复

关于该漏洞的修复，一般的修复就是停止创建短文件名，可以通过修改注册表来实现：





## Reference

http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/pic/37473/cn_zh/1510647047395/short%20name.png

https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/ff621566(v=ws.11)

https://support.microsoft.com/en-us/help/121007/how-to-disable-8-3-file-name-creation-on-ntfs-partitions

https://www.tecklyfe.com/windows-server-tip-disable-8-3-naming-strip-existing-short-names/


https://serverfault.com/questions/670658/fixing-the-iis-tilde-vulnerability