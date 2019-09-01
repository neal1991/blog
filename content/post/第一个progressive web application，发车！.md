---
title: "第一个progressive web application，发车！"
author: Neal
description: "progressive web application是谷歌推出的一种渐进式web应用，通过利用service-worker等来达到类似于原生应用，而且在chrome浏览器还可以添加到主页，完全就和一个app无异。老实说我觉得pwa是一个很好的发展方向，虽然小程序搞了一段时间不温不火，但是pwa的限制更少，再说还有谷歌支持，只不过现在部分浏览器可能支持的不是很好。 
国内饿了么前段时间做了一个pwa"
tags: [chrome,web应用]
categories: [web前端]
date: "2017-03-19 14:50:10"
---
progressive web application是谷歌推出的一种渐进式web应用，通过利用service-worker等来达到类似于原生应用，而且在chrome浏览器还可以添加到主页，完全就和一个app无异。老实说我觉得pwa是一个很好的发展方向，虽然小程序搞了一段时间不温不火，但是pwa的限制更少，再说还有谷歌支持，只不过现在部分浏览器可能支持的不是很好。
国内饿了么前段时间做了一个pwa，我觉得就挺好的 https://h5.ele.me/msite/ 。
我觉得和native app使用已经比较接近了，而且还无需安装。
扯得有点多，今天主要是讲下自己怎么做一个pwa。当然了，我也是新手，我的pwa也是基于谷歌的pwa的[sample](https://developers.google.com/web/fundamentals/getting-started/codelabs/your-first-pwapp/?hl=zh-cn)做了一些改进。谷歌现在很多开发者文档都做了翻译，sample主要是一个天气应用，里面具体的实现逻辑我就不讲了，我讲以下如何部署这个pwa。
在谷歌的sample里面是推荐使用firebase来部署你的pwa，但是由于国内的高墙，在firebase init的时候总是authentication error，stackoverflow上面说是代理的原因，但是不上代理又没办法使用firebase，所以这是一个死循环。但是！！我们有github page，github page是一个很好的展示静态页面的方面，以前只能支持渲染gh分支里面的内容，现在github对于github page功能做了完善，详细可以看下这篇文章http://blog.csdn.net/neal1991/article/details/53535914 。
下面跟我来：
1.进入https://github.com/neal1991/pwa 可以fork或者clone这个项目，我已经将里面的一些东西，改掉了，可以直接运行。
2.进入settings里面设置
![](https://cloud.githubusercontent.com/assets/12164075/24078742/fdd61a98-0cb0-11e7-9b6b-1d809f889550.png)
现在你进入https://yourusername.github.io/your-reporistry-name/就可以发车了，是不是很快。
接着我还想讲一讲我这个项目做的一些改进的地方，因为这个weather pwa使用的是yahoo的一个api，通过利用woeid可以去查询各个城市的天气以及相关信息。但是网上却没有中国各个城市的数字代码，注意是WEPID代码，我后来发觉http://www.imeihua.net/tool/weathercode.aspx  这个网站是可以查询wepid的，本来想写一个爬虫爬取的，但是这个网站似乎做了什么限制，我使用curl模拟下请求，限制访问了，这个网站使用.NET实现的，.NET的web请求里面总是包含了一些奇怪的属性。后来我又发现一个国外的网站，很方便，直接get请求就能获取http://woeid.rosselliot.co.nz/lookup ，于是我就写了一个爬虫去爬取，源代码在https://github.com/neal1991/woeid-parser
核心代码
```javascript
var request = require('superagent');
var fs = require('fs');
var cityConfig = ['wuhu', 'shanghai', 'beijing', 'hangzhou', 'nanjing', 'wuxi', 'xiamen', 'longyan'];
var cheerio = require('cheerio');
var url = 'http://woeid.rosselliot.co.nz/lookup/';
var attrNames = ['city', 'province', 'country', 'woeid'];
var result = [];

cityConfig.forEach(function(city) {
	request.get(url + city)
	.end(function(err, res) {
		$ = cheerio.load(res.text);
		$('#woeid_results_table tr').each(function(i, ele) {
				var obj = {};
				$ = cheerio.load(ele);
				$('td').each(function(index, td) {
					obj[attrNames[index]] = $(this).text();
				})
				result.push(obj);
		});
		var isEmpty = function(object) {
			for (var key in object) {
				return false;
			}
			return true;
		}
		result = result.filter(function(obj) {
			return obj.country === 'China' && !isEmpty(obj);
		})
		fs.writeFile('result.json', JSON.stringify(result, null, "\t"));
	})
});
```
主要是使用了superagent和cheerio这两个包，一个是用来发请求的，另外一个是用于解析html的，城市名需要英文城市名，我这里就是config来配置的，然后对结果做了过滤保存成json格式的文件。
这样就提供了我们中国城市wepid的数据源，当然我还没有做去读取json来获取这些数据，还是把这些wepid写死了放在weather pwa里面的。
对于weather pwa我还增加了删除城市的功能，因为本来只能添加城市，没有办法删除城市，可能里面还有一些小BUG。访问地址：
https://neal1991.github.io/pwa/
以上，就是我的第一次progressive web application，各位看官，如果觉得我的内容写的还可以的话，一定要给我的github repository star鼓励!!!
![](https://cloud.githubusercontent.com/assets/12164075/24078815/21ab2790-0cb3-11e7-9f37-1813892890e1.png)