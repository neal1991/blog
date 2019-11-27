https://www.welivesecurity.com/2019/11/26/stantinko-botnet-adds-cryptomining-criminal-activities/

# Stantinko botnet adds cryptomining to its pool of criminal activities
# 僵尸网络 Stantinko 犯罪活动新增加密货币挖矿

ESET researchers have discovered that the criminals behind the Stantinko botnet are distributing a cryptomining module to the computers they control.

The operators of the [Stantinko botnet](https://www.welivesecurity.com/2017/07/20/stantinko-massive-adware-campaign-operating-covertly-since-2012/) have expanded their toolset with a new means of profiting from the computers under their control. The roughly half-million-strong botnet – known to have been active since at least 2012 and mainly targeting users in Russia, Ukraine, Belarus and Kazakhstan – now distributes a cryptomining module. Mining Monero, a cryptocurrency whose exchange rate oscillates in 2019 between US$50 and US$110, has been the botnet’s monetizing functionality since at least August 2018. Before that, the botnet performed click fraud, ad injection, social network fraud and password stealing attacks.

In this article, we describe Stantinko’s cryptomining module and provide an analysis of its functionality.

This module’s most notable feature is the way it is obfuscated to thwart analysis and avoid detection. Due to the use of source level obfuscations with a grain of randomness and the fact that Stantinko’s operators compile this module for each new victim, each sample of the module is unique.

We will describe the module’s obfuscation techniques and offer, in a separate article for fellow malware analysts, a possible approach to deal with some of them.

Since Stantinko is constantly developing new and improving its existing custom obfuscators and modules, which are heavily obfuscated, it would be backbreaking to track each minor improvement and change that it introduces. Therefore, we decided to mention and describe only what we believe are significant adjustments in comparison with earlier samples relative to the state in which the module is to be described. After all, we intend just to describe the module as it currently is in this article.

ESET 研究人员发现，Stantinko 僵尸网络背后的犯罪分子正在向他们控制的肉鸡分发加密货币挖矿模块。

[Stantinko 僵尸网络](https://www.welivesecurity.com/2017/07/20/stantinko-massive-adware-campaign-operating-covertly-since-2012/) 的操纵者已经通过一种新方法扩展了其工具集从受其控制的肉鸡中获利。多达 50 万的僵尸网络自 2012 年以来一直保持活跃，主要针对俄罗斯，乌克兰，白俄罗斯和哈萨克斯坦的用户-现在分发了一个加密矿模块。门罗币是一种加密货币，其汇率在 2019 年在 50 美元至 110 美元之间波动，自从至少 2018 年 8 月以来，它一直是僵尸网络的获利手段。在此之前，僵尸网络进行了点击欺诈，广告注入，社交网络欺诈和密码窃取攻击。

在本文中，我们将介绍 Stantinko 的加密货币挖矿模块并对其功能进行分析。

该模块最显着的功能是它的混淆方式阻碍了分析并避免了检测。由于源代码级混淆以及随机性使用，而且 Stantinko 的操纵者会为每个新的受害者编译此模块，因此该模块的每个样本都是唯一的。

我们将在另一篇文章中为恶意软件分析人员介绍该模块的混淆技术，并提供一种处理其中某些问题的可行方法。

由于 Stantinko 一直在不断开发新的产品并改进其现有的自定义混淆器和模块，这些混淆器和模块被严重混淆，因此跟踪每个小的改进和修改非常困难。因此，我们决定仅提及和描述与早期样本相比比较重要的调整。最终，在本文中我们仅打算描述模块当前的状态。

## Modified open-source cryptominer

## 修改后的开源加密货币挖矿

Stantinko’s cryptomining module, which exhausts most of the resources of the compromised machine by mining a cryptocurrency, is a highly modified version of the 【】[xmr-stak](https://github.com/fireice-uk/xmr-stak) open-source cryptominer. All unnecessary strings and even whole functionalities were removed in attempts to evade detection. The remaining strings and functions are heavily obfuscated. ESET security products detect this malware as Win{32,64}/CoinMiner.Stantinko.

Stantinko 的加密货币挖矿模块通过挖掘加密货币来耗尽受感染机器的大部分资源，它是[xmr-stak](https://github.com/fireice-uk/xmr-stak) 的大幅修改后的开源加密货币挖矿版本。为了逃避检测，删除了所有不必要的字符串甚至整个函数。其余的字符串和函数被严重混淆。ESET安全产品将此恶意软件检测为 Win{32,64}/CoinMiner.Stantinko.。

## Use of mining proxies
## 挖矿代理的使用

CoinMiner.Stantinko doesn’t communicate with its [mining pool](https://en.wikipedia.org/wiki/Mining_pool) directly, but via proxies whose IP addresses are acquired from the description text of YouTube videos. A similar technique to hide data in descriptions of YouTube videos is used by the banking malware [Casbaneiro](https://www.welivesecurity.com/2019/10/03/casbaneiro-trojan-dangerous-cooking/). Casbaneiro uses much more legitimate-looking channels and descriptions, but for much the same purpose: storing encrypted C&Cs.

The description of such a video consists of a string comprised of mining proxy IP addresses in hexadecimal format. For example, the YouTube video seen in Figure 1 has the description “03101f1712dec626“, which corresponds to two IP addresses in hexadecimal format – 03101f17 corresponds to 3.16.31[.]23 in decimal dotted-quad format, and 12dec626 is 18.222.198[.]38. As of the time of writing, the format has been slightly adjusted. The IP addresses are currently enclosed in “!!!!”, which simplifies the very process of parsing and prevents possible changes of the YouTube video HTML structure turning the parser dysfunctional.

![QS2kVI.png](https://s2.ax1x.com/2019/11/26/QS2kVI.png)
Figure 1. Example YouTube video whose description provides an IP address for the module’s communication with the mining pool

In earlier versions, the YouTube URL was hardcoded in CoinMiner.Stantinko binary. Currently the module receives a video identifier as a command line parameter instead. This parameter is then used to construct the YouTube URL, in the form https://www.youtube.com/watch?v=%PARAM%. The cryptomining module is executed by either Stantinko’s [BEDS](https://www.welivesecurity.com/wp-content/uploads/2017/07/Stantinko.pdf) component, or by rundll32.exe via a batch file that we have not captured, with the module loaded from a local file system location of the form %TEMP%\%RANDOM%\%RANDOM_GUID%.dll.

We informed YouTube of this abuse; all the channels containing these videos were taken down.

CoinMiner.Stantinko 不会直接与其[矿池](https://en.wikipedia.org/wiki/Mining_pool)进行通信，而是通过 IP 地址为从 YouTube 视频的描述中获取的代理进行通信。使用了与银行恶意软件[Casbaneiro](https://www.welivesecurity.com/2019/10/03/casbaneiro-trojan-dangerous-cooking/) 类似的技术在 YouTube 视频描述中隐藏数据。Casbaneiro 使用看起来更为合法的频道和描述，但目的大致相同：存储加密的 C&C。

此类视频的描述由以十六进制格式的挖矿的代理 IP 地址字符串组成。例如，图1中显示的 YouTube 视频的描述为 "03101f1712dec626"，它对应于两个十六进制格式的 IP 地址- 03101f17 对应于十进制点分四进制格式的 3.16.31[.]23，而 12dec626 对应 18.222.198[.]38。截至本文，格式已稍作调整。 IP地址当前用 “!!!!” 括起来，简化了解析过程，并防止了 YouTube 视频 HTML 结构的更改导致解析器无法正常工作。

![QS2kVI.png](https://s2.ax1x.com/2019/11/26/QS2kVI.png)
图1.示例 YouTube 视频，其描述为模块提供了与矿池通信的 IP 地址

在早期版本中，YouTube URL 在 CoinMiner.Stantinko 二进制文件中是硬编码编写的。当前，模块改为接收视频标识符作为命令行参数。然后，该参数用于以 https://www.youtube.com/watch?v=%PARAM% 的形式构造 YouTube URL。加密货币挖矿模块由 Stantinko的[BEDS](https://www.welivesecurity.com/wp-content/uploads/2017/07/Stantinko.pdf) 组件执行，或者由 rundll32.exe 通过我们未捕获到的的批处理文件执行，模块是从格式为 ％TEMP％\％RANDOM％\％RANDOM_GUID％.dll 本地文件系统位置加载。

我们已将这种滥用告知 YouTube；包含这些视频的所有频道均已关闭。

## Cryptomining capabilities
## 加密货币挖矿能力

We have divided the cryptomining module into four logical parts, which represent distinct sets of capabilities. The main part performs the actual cryptomining; the other parts of the module are responsible for additional functions:

* suspending other (i.e. competing) cryptomining applications
* detecting security software
* suspending the cryptomining function if the PC is on battery power or when a task manager is detected, to prevent being revealed by the user

我们将密码挖掘模块分为四个逻辑部分，分别代表不同的功能集。主要部分执行实际的加密货币挖矿；模块的其他部分负责附加功能：

* 暂停其他（即竞争性）加挖矿应用
* 检测安全软件
* 如果 PC 依靠电池供电或检测到任务管理器，则暂停加密采矿功能，以防止被用户发现

### Cryptomining

### 加密货币挖矿

At the very core of the cryptomining function lies the process of hashing, and communication with the proxy. The method of obtaining the list of mining proxies is described above; CoinMiner.Stantinko sets the communication with the first mining proxy it finds alive.

Its communication takes place over TCP and is encrypted by RC4 with a key consisting of the first 26 characters of the number pi (including the decimal separator, hardcoded in the string “3,141592653589793238462643“) and then base64 encoded; the same key is used in all samples we have seen.

The code of the hashing algorithm is downloaded from the mining proxy at the beginning of the communication and loaded into memory – either directly or, in earlier versions, from the library libcr64.dll that is first dropped onto the disk.

Downloading the hashing code with each execution enables the Stantinko group to change this code on the fly. This change makes it possible, for example, to adapt to adjustments of algorithms in existing currencies and to switch to mining other cryptocurrencies in order, perhaps, to mine the most profitable cryptocurrency at the moment of execution. The main benefit of downloading the core part of the module from a remote server and loading it directly into memory is that this part of the code is never stored on disk. This additional adjustment, which is not present in earlier version, is aimed at complicating detection because patterns in these algorithms are trivial for security products to detect.

All instances of Stantinko’s cryptomining module we’ve analyzed mine Monero. We deduced this from the jobs provided by the mining proxy and the hashing algorithm. For example, Figure 2 is a job sent by one of the proxies.

加密货币挖矿的核心取决于哈希处理以及代理通信。上面描述了获取代理列表的方法；CoinMiner.Stantinko 与它发现的第一个存活的挖矿代理建立通信。

它的通信通过 TCP 进行，并由密钥为数字 pi 的前 26 个字符（包括小数点分隔符，硬编码为字符串"3,141592653589793238462643"）组成的 RC4 算法加密，然后由 base64 编码；我们看到的所有样本都使用相同的密钥。

在通信开始时，从挖矿代理下载哈希算法的代码，并将其加载到内存中或在较早版本中先从库 libcr64.dll 拖到磁盘中。

每次执行时下载哈希代码，可使 Stantinko 组在运行中更改代码。例如，此更改使得有可能适应现有货币中算法的调整，并切换到挖掘其他加密货币，以便在执行时挖掘利润最丰厚的加密货币。从远程服务器下载模块的核心部分并将其直接加载到内存中的主要好处是，这部分代码永远不会存储在磁盘上。此附加调整（较早版本中没有提供）让检测复杂化，因为这些算法中的模式对于检测安全产品而言是太微小。

我们已经分析了 Stantinko 加密货币挖矿模块的所有实例。我们从挖掘代理和哈希算法提供的作业中得出以上结论。例如，图2是由代理之一发送的作业。

```
{“error”:null,”result”:{“status”:”OK”}}
{“method”:”job”,”params”:”blob”:”0b0bbfdee1e50567042dcfdfe96018227f25672544521f8ee2564cf8b4c3139a6a88c5f0b32664000000a1c8ee5c185ed2661daab9d0c454fd40e9f53f0267fe391bdb4eb4690395deb36018″,”job_id”:”281980000000000a10″,”target”:”67d81500″,”height”:1815711}}
```
Figure 2. Example mining job received from a mining pool proxy

We analyzed the hashing algorithm used and found that it was [CryptoNight R](https://github.com/SChernykh/CryptonightR). Since there are multiple cryptocurrencies that use this algorithm, its recognition alone isn’t sufficient; it just shortens the list. One can see in the provided job that the [height of the blockchain](https://coinguides.org/block-height/) was 1815711 at the time, so we had to find currencies using CryptoNight R with this height on dedicated [block explorers](https://marketbusinessnews.com/financial-glossary/block-explorer/) which lead us to Monero. Dissecting the string 0b0bbfdee1e50567042dcfdfe96018227f25672544521f8ee2564cf8b4c3139a6a88c5f0b32664000000a1c8ee5c185ed2661daab9d0c454fd40e9f53f0267fe391bdb4eb4690395deb36018 reveals that the hash of the previous block (67042dcfdfe96018227f25672544521f8ee2564cf8b4c3139a6a88c5f0b32664) and timestamp (1555590859) indeed [fits into Monero’s blockchain](https://xmrchain.net/search?value=1815711) at the height of 1815711. One can find the structure of the blob by examining its [generator function](https://github.com/monero-project/monero/blob/a48ef0a65afd2d89b9a81479f587b5b516a31c9c/src/cryptonote_basic/cryptonote_format_utils.cpp#L1207) in the source code of Monero . The generator function exposes another structure called a [block header](https://github.com/monero-project/monero/blob/a48ef0a65afd2d89b9a81479f587b5b516a31c9c/src/cryptonote_basic/cryptonote_basic.h#L446) which contains both the hash of the previous block and timestamp.

Unlike the rest of CoinMiner.Stantinko, the hashing algorithm isn’t obfuscated, since obfuscation would significantly impair the speed of hash calculation and hence overall performance and profitability. However, the authors still made sure not to leave any meaningful strings or artifacts behind.

图2.从矿池代理接​​收的挖矿作业示例

我们分析了使用的哈希算法，发现它是[CryptoNight R](https://github.com/SChernykh/CryptonightR)。由于有多种使用该算法的加密货币，仅凭这个算法还不足以识别；它只会缩短列表。在提供的作业中，可以看到当时 [blockchain 的高度](https://coinguides.org/block-height/) 为1815711，因此我们不得不使用 CryptoNight R 在专用[区块浏览器](https://marketbusinessnews.com/financial-glossary/block-explorer/)中查找汇率，我们推导为门罗币。解剖字符串0b0bbfdee1e50567042dcfdfe96018227f25672544521f8ee2564cf8b4c3139a6a88c5f0b32664000000a1c8ee5c185ed2661daab9d0c454fd40e9f53f0267fe391bdb4eb4690395deb36018 显示之前区块的哈希（67042dcfdfe96018227f25672544521f8ee2564cf8b4c3139a6a88c5f0b32664）和时间戳（1555590859）确实在 区块高度为 1815711 时和[门罗币区块链匹配](https://xmrchain.net/search?value=1815711)。通过在门罗币的源代码中检查[生成器函数](https://github.com/monero-project/monero/blob/a48ef0a65afd2d89b9a81479f587b5b516a31c9c/src/cryptonote_basic/cryptonote_format_utils.cpp#L1207)查找 blob 的结构。生成器函数公开了另一个称为 [block header](https://github.com/monero-project/monero/blob/a48ef0a65afd2d89b9a81479f587b5b516a31c9c/src/cryptonote_basic/cryptonote_basic.h#L446) 的结构，该结构同时包含前一个块的哈希和时间戳。

与 CoinMiner.Stantinko 的其余部分不同，哈希算法不会被混淆，因为混淆会显着影响哈希计算的速度，从而影响整体性能和盈利能力。但是，作者仍要确保不要留下任何有意义的字符串或组件。

### 抑制其他加密货币挖矿软件

### Suspension of other cryptominers

The malware enumerates running processes searching for other cryptominers. If any competitors are found, Stantinko suspends all their threads.

CoinMiner.Stantinko considers a process to be a cryptominer if its command line contains a particular string, or a combination, which vary from sample to sample; for example:

该恶意软件枚举运行进程来搜索其他加密货币挖矿软件。如果发现任何竞争对手，Stantinko 将中止其所有线程。

如果 CoinMiner.Stantinko 在进程命令行中发现包含一个特定的字符串或组合（因样本而异），则认为该过程为加密货币挖矿软件。 例如：

* minerd
* minergate
* xmr
* cpservice
* vidservice and stratum+tcp://
* stratum://
* -u and pool
* “-u and pool
* “-u and xmr
* -u and xmr
* -u and mining
* “-u and mining
* -encodedcommand and exe
* –donate-level
* windows and -c and cfgi
* regsvr32 and /n and /s and /q
* application data and exe
* appdata and exe

These strings refer to the following legitimate cryptominers: https://github.com/pooler/cpuminer, https://minergate.com/, https://github.com/xmrig, and even https://github.com/fireice-uk/xmr-stak – which, interestingly, is the very miner this Stantinko module is based on. The strings also lead to various uninteresting malware samples containing cryptomining functionality.

Of interest is that the Stantinko operators [are known](https://www.welivesecurity.com/2017/07/20/stantinko-massive-adware-campaign-operating-covertly-since-2012/) to have tried to get rid of competing code in the past. However, they relied on the legitimate AVZ Antiviral Toolkit fed with a script written in its built-in scripting language for this task.

这些字符串引用以下合法的加密货币挖矿软件：https://github.com/pooler/cpuminer, https://minergate.com/, https://github.com/xmrig 甚至 https://github.com/fireice-uk/xmr-stak。有趣的是，这些正是 Stantinko 模块正是基于这些软件的。这些字符串还导致包含加密采矿功能的各种恶意软件样本。

有趣的是，Stantinko 操纵者[已经被人知道](https://www.welivesecurity.com/2017/07/20/stantinko-massive-adware-campaign-operating-covertly-since-2012/)试图消灭竞争代码。但是，他们依靠合法的反病毒工具套件提供的内置脚本语言编写的脚本来完成此任务。

### Detection prevention
### 检测预防

CoinMiner.Stantinko temporarily suspends mining if it detects there’s no power supply connected to the machine. This measure, evidently aimed at portable computers, prevents fast battery draining … which might raise the user’s suspicion.

Also, it temporarily suspends mining if a task manager application (a process named procexp64.exe, procexp.exe or taskmgr.exe) is detected running.

The malware also scans running processes to find security software and again task managers. It calculates the CRC-32 of the process’s name and then checks it against a hardcoded list of CRC-32 checksums, which is included in the Appendix. In general this technique can help evade detection, since the process names of those security products are not included in the binary – adding a bit more stealth by not containing the process names directly. It also makes it harder for analysts to find out what the malware authors are after because one has to crack these hashes, which is technically the same problem as [password cracking](https://en.wikipedia.org/wiki/Password_cracking). However, using a list of known process names is usually sufficient to determine the exact names.

Should a CRC-32 match be found, the CRC is written to a log file (api-ms-win-crt-io-l1-1-0.dll). The log file is presumably exfiltrated later by some Stantinko component that we have not seen, since there’s no other functionality related to it in this module.

CoinMiner.Stantinko 如果检测到机器未连接任何电源，则将暂时中止挖矿。这项措施显然是针对笔记本电脑的，它可以防止电池快速耗尽……这可能会引起用户的怀疑。

此外，如果检测到任务管理器应用程序（procexp64.exe，procexp.exe 或 taskmgr.exe 的进程）正在运行，它会暂时中止挖矿。

该恶意软件还会扫描运行进程以查找安全软件，然后再次查找任务管理器。它计算出进程名称的 CRC-32，然后根据附录中硬编码的 CRC-32 检验和列表进行检查。通常，此技术可帮助逃避检测，因为这些安全产品的进程名称未包含在二进制文件中–通过不直接包含进程名称，增加了隐秘性。这也使分析者更难发现恶意软件作者目的所在，因为必须破解这些散列，从技术上讲，这与[密码破解](https://en.wikipedia.org/wiki/Password_cracking)是相同的问题。但是，使用已知进程名称的列表通常足以确定确切的名称。

如果找到 CRC-32 匹配项，则将 CRC 写入日志文件（api-ms-win-crt-io-l1-1-0.dll）。该日志文件可能稍后会是我们未发现的 Stantinko 组件释放出的，因为此模块中没有与其相关的其他功能。

## Obfuscation
## 混淆

Besides its cryptomining features, CoinMiner.Stantinko is notable also for its obfuscation techniques aimed at avoiding detection and thwarting analysis. Some of those techniques are unique and we will describe them in detail in a follow-up article.

## Conclusion

Our discovery shows that the criminals behind Stantinko continue to expand the ways they leverage the botnet they control. Their previous innovations were distributed dictionary-based attacks on Joomla and WordPress web sites aimed at harvesting server credentials, probably with the goal of selling them to other criminals.

This remotely configured cryptomining module, distributed since at least August of 2018 and still active at the time of writing, shows this group continues to innovate and extend its money-making capabilities. Besides its standard cryptomining functionality, the module employs some interesting obfuscation techniques that we will disclose, along with some possible countermeasures, in an upcoming article.

除了加密货币挖矿功能外，CoinMiner.Stantinko 还以其避免检测和阻碍分析的混淆技术而著称。其中一些技术是独特的，我们将在后续文章中对其进行详细描述。

## 总结

我们的发现表明，Stantinko 背后的犯罪分子继续扩大利用其控制的僵尸网络的方式。他们之前的创新是在 Joomla 和 WordPress 网站上进行基于字典的分布式攻击来获取服务器凭据，目的可能是将其出售给其他罪犯。

这个远程配置的加密矿模块自 2018 年 8 月开始分发，在撰写本文时仍处于活动状态，表明该团队正在不断创新并扩展其赚钱能力。除了其标准的加密挖掘功能外，该模块还采用了一些有趣的混淆技术，我们将在下一篇文章中介绍该技术以及一些可能的对策。

## 威胁指示器 (IoCs)

### ESET 检测名称

Win32/CoinMiner.Stantinko
Win64/CoinMiner.Stantinko

### SHA-1

A full list of more than 1,500 hashes is available from [our GitHub repository](https://github.com/eset/malware-ioc/tree/master/stantinko).

可以从[我们的 GitHub 仓库](https://github.com/eset/malware-ioc/tree/master/stantinko)获取 1500多 个哈希的完整列表。

00F0AED42011C9DB7807383868AF82EF5454FDD8
01504C2CE8180D3F136DC3C8D6DDDDBD2662A4BF
0177DDD5C60E9A808DB4626AB3161794E08DEF74
01A53BAC150E5727F12E96BE5AAB782CDEF36713
01BFAD430CFA034B039AC9ACC98098EB53A1A703
01FE45376349628ED402D8D74868E463F9047C30

### Filenames

### 文件名

api-ms-win-crt-io-l1-1-0.dll
libcr64.dll
C:\Windows\TEMP\%RANDOM%\%RANDOM_GUID%.dll

### Mutex name and RC4 key
### 互斥体名以及 RC4 密钥

“3,141592653589793238462643”

### YouTube URLs with mining proxy configuration data

### 带有挖矿代理配置数据的 YouTube 链接

* https://www.youtube[.]com/watch?v=kS1jXg99WiM
* https*://www.youtube[.]com/watch?v=70g4kw2iRGo
* https*://www.youtube[.]com/watch?v=cAW1xEpyr7Y
* https*://www.youtube[.]com/watch?v=6SSKQdE5Vjo
* https*://www.youtube[.]com/watch?v=fACKZewW22M
* https*://www.youtube[.]com/watch?v=FDQOa5zCv3s
* https*://www.youtube[.]com/watch?v=TpyOURRvFmE
* https*://www.youtube[.]com/watch?v=2fpiR4NIpsU
* https*://www.youtube[.]com/watch?v=TwnD0Kp_Ohc
* https*://www.youtube[.]com/watch?v=wJsbj8zPPNs

### IP addresses of mining proxies
### 挖矿代理的 IP 地址

* 3.16.150[.]123
* 3.16.152[.]201
* 3.16.152[.]64
* 3.16.167[.]92
* 3.16.30[.]155
* 3.16.31[.]23
* 3.17.167[.]43
* 3.17.23[.]144
* 3.17.25[.]11
* 3.17.59[.]6
* 3.17.61[.]161
* 3.18.108[.]152
* 3.18.223[.]195
* 13.58.182[.]92
* 13.58.22[.]81
* 13.58.77[.]225
* 13.59.31[.]61
* 18.188.122[.]218
* 18.188.126[.]190
* 18.188.249[.]210
* 18.188.47[.]132
* 18.188.93[.]252
* 18.191.104[.]117
* 18.191.173[.]48
* 18.191.216[.]242
* 18.191.230[.]253
* 18.191.241[.]159
* 18.191.47[.]76
* 18.216.127[.]143
* 18.216.37[.]78
* 18.216.55[.]205
* 18.216.71[.]102
* 18.217.146[.]44
* 18.217.177[.]214
* 18.218.20[.]166
* 18.220.29[.]72
* 18.221.25[.]98
* 18.221.46[.]136
* 18.222.10[.]104
* 18.222.187[.]174
* 18.222.198[.]38
* 18.222.213[.]203
* 18.222.253[.]209
* 18.222.56[.]98
* 18.223.111[.]224
* 18.223.112[.]155
* 18.223.131[.]52
* 18.223.136[.]87
* 18.225.31[.]210
* 18.225.32[.]44
* 18.225.7[.]128
* 18.225.8[.]249
* 52.14.103[.]72
* 52.14.221[.]47
* 52.15.184[.]25
* 52.15.222[.]174

### MITRE ATT&CK 技术
<table>
<tr><td>技术</td>	<td>ID</td><td>名称</td><td>描述</td></tr>

<tr><td rowspan="2">执行</td>	<td>T1085</td>	<td>Rundll32</td>	<td>该模块由rundll32.exe 执行。</td>
<tr><td>T1035</td>	<td>服务执行</td>	<td>这个恶意软件可以以服务形式执行。</td></tr>
<tr><td rowspan="3">防御规避</td><td>T1140</td><td>反混淆/解码文件或信息</td>	<td>The module deobfuscates strings in its code during the execution process.</td></tr>
<tr><td>T1027</td>	<td>Obfuscated Files or Information</td>	<td>The module obfuscates its code and strings in an apparent attempt to make analysis and detection difficult.</td></tr>
<tr><td>T1102</td>	<td>Web Service</td>	<td>The malware acquires configuration data from description of YouTube videos.</td></tr>
<tr><td>Discovery</td>	<td>T1063</td>	<td>Security Software Discovery</td>	<td>The malware acquires a list of running security products.</td></tr>
<tr><td rowspan="7">Command and Control</td>	<td>T1090</td>	<td>Connection Proxy</td>	<td>The module uses proxies between itself and the mining pool.</td></tr>
<tr><td>T1008</td>	<td>Fallback Channels</td>	<td>The module connects to another mining proxy if the initial one is inaccessible.</td>
<tr><td>T1095</td>	<td>Standard Non-Application Layer Protocol</td>	<td>The malware uses TCP for its communications.</td></tr>
<tr><td>T1043</td>	<td>Commonly Used Port</td>	<td>The malware communicates over port 443.</td></tr>
<tr><td>T1132</td>	<td>Data Encoding</td>	<td>The module encrypts then base64 encodes some network traffic.</td></tr>
<tr><td>T1032</td>	<td>Standard Cryptographic Protocol</td>	<td>The module encrypts traffic with RC4.</td></tr>
<tr><td>T1071</td>	<td>Standard Application Layer Protocol</td>	<td>Acquires configuration data from description of YouTube videos via HTTPS.</td></tr>
<tr><td>Impact</td>	<td>T1496</td>	<td>Resource Hijacking</td>	<td>The module mines cryptocurrency.</td></tr>
</table>

<table>
<tr><td>技术</td>	<td>ID</td><td>名称</td><td>描述</td></tr>

<tr><td rowspan="2">执行</td>	<td>T1085</td>	<td>Rundll32</td>	<td>该模块由rundll32.exe 执行。</td>
<tr><td>T1035</td>	<td>服务执行</td>	<td>这个恶意软件可以以服务形式执行。</td></tr>
<tr><td rowspan="3">防御规避</td><td>T1140</td><td>反混淆/解码文件或信息</td>	<td>在执行过程中，模块将对其代码中的字符串进行反混淆处理。</td></tr>
<tr><td>T1027</td>	<td>混淆的文件或信息</td>	<td>该模块混淆了其代码和字符串，这显然使分析和检测变得困难。</td></tr>
<tr><td>T1102</td>	<td>Web 服务</td>	<td>该恶意软件从 YouTube 视频的描述中获取配置数据。</td></tr>
<tr><td>发现</td>	<td>T1063</td>	<td>安全软件发现</td>	<td>该恶意软件获取正在运行的安全产品列表。</td></tr>
<tr><td rowspan="7">命令与控制</td>	<td>T1090</td>	<td>连接代理</td>	<td>该模块在其自身与矿池之间使用代理。</td></tr>
<tr><td>T1008</td>	<td>备用频道</td>	<td>如果无法访问初始挖掘代理，则该模块将连接到另一个挖掘代理。</td>
<tr><td>T1095</td>	<td>标准非应用层协议</td>	<td>该恶意软件使用 TCP 进行通信。</td></tr>
<tr><td>T1043</td>	<td>常用端口</td>	<td>恶意软件通过端口 443 通信。</td></tr>
<tr><td>T1132</td>	<td>数据编码</td>	<td>模块加密，然后 base64 编码一些网络流量。</td></tr>
<tr><td>T1032</td>	<td>标准加密协议</td>	<td>该模块使用 RC4 加密流量。</td></tr>
<tr><td>T1071</td>	<td>标准应用层协议</td>	<td>通过 HTTPS 从 YouTube 视频的描述中获取配置数据。</td></tr>
<tr><td>影响</td>	<td>T1496</td>	<td>资源劫持</td>	<td>该模块挖掘加密货币。</td></tr>
</table>

## 附录

CRC-32 checksums checked by CoinMiner.Stantinko and the filenames they equate to are listed below.

下面列出了 CoinMiner.Stantinko 检查的 CRC-32 校验和以及它们对应的文件名。


0xB18362C7	afwserv.exe
***
0x05838A63	ashdisp.exe
***
0x36C5019C	ashwebsv.exe
***
0xB3C17664	aswidsagent.exe
***
0x648E8307	avastsvc.exe
***
0x281AC78F	avastui.exe
***
0xAA0D8BF4	avgcsrva.exe
***
0x71B621D6	avgcsrvx.exe
***
0x7D6D668A	avgfws.exe
***
0x1EF12475	avgidsagent.exe
***
0x010B6C80	avgmfapx.exe
***
0x6E691216	avgnsa.exe
***
0xB5D2B834	avgnsx.exe
***
0x36602D00	avgnt.exe
***
0x222EBF57	avgrsa.exe
***
0xF9951575	avgrsx.exe
***
0x2377F90C	avgsvc.exe
***
0x37FAB74F	avgsvca.exe
***
0xEC411D6D	avgsvcx.exe
***
0x0BED9FA2	avgtray.exe
***
0x168022D0	avguard.exe
***
0x99BA6EAA	avgui.exe
***
0x7A77BA28	avguix.exe
***
0x022F74A	avgwdsvc.exe
***
0x98313E09	avira.servicehost.exe
***
0x507E7C15	avira.systray.exe
***
0xFF934F08	avp.exe
***
0x9AC5F806	avpui.exe
***
0xBD07F203	avshadow.exe
***
0x64FDC22A	avwebg7.exe
***
0x0BC69161	avwebgrd.exe
***
0xBACF2EAC	cureit.exe
***
0x8FDEA9A9	drwagntd.exe
***
0xE1856E76	drwagnui.exe
***
0xF9BF908E	drwcsd.exe
***
0xC84AB1DA	drwebcom.exe
***
0x183AA5AC	drwebupw.exe
***
0xAC255C5E	drwupsrv.exe
***
0x23B9BE14	dwantispam.exe
***
0xDAC9F2B7	dwarkdaemon.exe
***
0x7400E3CB	dwengine.exe
***
0x73982213	dwnetfilter.exe
***
0x1C6830BC	dwscanner.exe
***
0x86D81873	dwservice.exe
***
0xB1D6E120	dwwatcher.exe
***
0xD56C1E6F	egui.exe
***
0x69DD7DB4	ekrn.exe
***
0xFB1C0526	guardgui.exe
***
0x5BC1D859	ipmgui.exe
***
0x07711AAE	ksde.exe
***
0x479CB9C4	ksdeui.exe
***
0x6B026A91	nod32cc.exe 
***
0xCFFC2DBB	nod32krn.exe
***
0x59B8DF4D	nod32kui.exe
***
0x998B5896	procexp.exe
***
0xF3EEEFA8	procexp64.exe
***
0x81C16803	sched.exe
***
0x31F6B864	spideragent.exe
***
0x822C2BA2	taskmgr.exe
***
0x092E6ADA	updrgui.exe
***
0x09375DFF	wsctool.exe
***


