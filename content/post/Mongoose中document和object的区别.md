---
title: "Mongoose中document和object的区别"
tags: ["nodejs", "js", "mongoose"]
categories: ["前端"]
date: 2017-09-17
---

这个问题其实是mongoose非常常见的问题，经常有很多以前没遇到这个问题的人都会被这个问题弄得怀疑人生。我们先介绍一些问题的背景。先看下面一段代码：

```javascript
router.get('/', function(req, res, next) {
  // res.render('index', { title: 'Express' });
  const model = mongoose.model('realestate');
  const queryCretia = {};
  model.find(queryCretia, (err, docs) => {
    res.render('index', {
      title: 'express',
      docs: docs
    })
  })
});
```

```ejs
<!DOCTYPE html>
<html>
  <head>
    <title><%= title %></title>
    <link rel='stylesheet' href='/stylesheets/style.css' />
  </head>
  <body>
    <h1><%= title %></h1>
    <p>Welcome to <%= title %></p>
    <!-- <%= docs %> -->
    <ul>
      <% docs.forEach(function(doc){ %>
      <li><%= doc.type %></li>
      <% }) %>
    </ul>
  </body>
</html>
```

在第一段代码中，通过`model.find`我们应该能够获取到根据`queryCriteria`获取的结果，结果应该是一个对象数组，类似于这样：

```
[{
    "_id" : ObjectId("59bdeadb2a5c612514ee7970"),
    "title" : "好楼层，中等装修，满5年，上门实拍",
    "type" : "2室1厅",
    "square" : "75.42平",
    "direction" : "朝南",
    "floor" : "中区/6层",
    "unitPrice" : 47732,
    "totalPrice" : 360,
    "location" : null,
    "specialExplain" : "满五",
    "url" : "http://sh.lianjia.com//ershoufang/sh4528035.html",
    "station" : "江杨北路",
    "line" : "3号线",
    "updateTime" : "2017-09-17 11:24:11"
}
{
    "_id" : ObjectId("59bdeadb2a5c612514ee7971"),
    "title" : "南北户型，厨卫全明，高区采光好，装修精美",
    "type" : "2室2厅",
    "square" : "90.92平",
    "direction" : "朝南北",
    "floor" : "高区/6层",
    "unitPrice" : 46194,
    "totalPrice" : 420,
    "location" : null,
    "specialExplain" : "满五",
    "url" : "http://sh.lianjia.com//ershoufang/sh4546221.html",
    "station" : "江杨北路",
    "line" : "3号线",
    "updateTime" : "2017-09-17 11:24:11"
}]
```

预期`index.ejs`应该渲染的页面是一个ul渲染的结果，类似于

* 2室1厅
* 2室2厅

当然，理想很丰满，现实很骨感。我就是死活渲染不出来`doc.type`。照理说应该是不可能的，在`index.ejs`中`doc`就是一个对象，我为什么不能获取`doc`的`type`属性呢？这不合理，太不合理了！

老实说，这个问题我之间也是遇到过，当初我是想修改这个`doc`的属性，但是死活没有办法修改，当初也是花了很久找到原因。这次我就把这个问题好好地研究一下。

先说结果，以及解决方法把。我比较喜欢剧透。愿意是因为再次返回的`doc`是属于Document的实例，而不是一个普通的对象。也就是说它和普通的对象是不一样的，它没有普通对象的一些方法，普通对象也没有它身上的一些方法。解决方案有几种，不过究其根本都是将这种document转化为普通的对象：

### 方法1：
利用[`toObject`方法](http://mongoosejs.com/docs/api.html#document_Document-toObject)

```javascript
docs.forEach(doc => {
    return doc.toObject();
})
```

### 方法2：
利用JSON方法，这是我想到的一个方法，具体深层原因在这就不展开了：

```javascript
docs = JSON.stringify(docs);
docs = JSON.parse(docs);
```

### 方法3:
利用`lean`方法：
```javascript
model.find().lean().exec((err, docs) => {
....
})
```

上述的三种方法应该都能成功将find获取的结果转化为普通的对象。

但是我还想知道到底document和一个普通的对象到底有什么区别，区别在哪里呢？

我们假设`find`获取的结果是`docs`，转化为普通对象的结果是`docs1`。现在我们就看一看这二者的区别。理论上`docs`和`docs1`都应该是数组，而它们中元素都应该是一个对象，我们先来看看是不是这样呢？

```javascript
console.log(Object.prototype.toString.call(docs));
consoele.log(Object.prototype.toString.call(docs[0]));

console.log(Object.prototype.toString.call(docs1));
console.log(Object.prototype.toString.call(docs1[0]))
```
我们通过上述方法可以获取`docs`以及`docs1`的类型以及其中元素的类型，结果是：

```
[object Array]
[object Object]

[object Array]
[object Object]
```

和我们预想中的一模一样，那问题不在这，那我们就探究探究`docs[0]`以及`docs1[0]`的原型把，看看它的原型到底是什么呢？知道JS的人，应该都知道JS中的原型链。在此，我们就通过`__proto__`来粗暴地获取对象的原型：

```
console.dir(doc[0].__proto__);

console.dir(docs[0].__proto__);
```

结果是：
```json
model {
  db:
   NativeConnection {
     base:
      Mongoose {
        connections: [Array],
        models: [Object],
        modelSchemas: [Object],
        options: [Object],
        plugins: [Array] },
     collections: { realestates: [Object] },
     models: { realestate: [Object] },
     config: { autoIndex: true },
     replica: false,
     hosts: null,
     host: '127.0.0.1',
     port: 27017,
     user: undefined,
     pass: undefined,
     name: 'real_estate_info',
     options:
      { db: [Object],
        auth: {},
        server: [Object],
        replset: [Object],
        mongos: undefined },
     otherDbs: [],
     _readyState: 1,
     _closeCalled: false,
     _hasOpened: true,
     _listening: false,
     db:
      Db {
        domain: null,
        _events: [Object],
        _eventsCount: 6,
        _maxListeners: undefined,
        s: [Object],
        serverConfig: [Getter],
        bufferMaxEntries: [Getter],
        databaseName: [Getter],
        _listening: true },
     _events:
      { connected: [Function],
        error: [Function: bound bound consoleCall],
        disconnected: [Function: bound bound consoleCall],
        reconnected: [Function: bound bound consoleCall] },
     _eventsCount: 4 },
  discriminators: undefined,
  id: [Getter/Setter],
  __v: [Getter/Setter],
  _id: [Getter/Setter],
  schema:
   Schema {
     obj: undefined,
     paths: { _id: [Object], __v: [Object] },
     aliases: {},
     subpaths: {},
     virtuals: { id: [Object] },
     singleNestedPaths: {},
     nested: {},
     inherits: {},
     callQueue: [ [Array], [Array], [Array], [Array], [Array], [Array] ],
     _indexes: [],
     methods: {},
     statics: {},
     tree: { _id: [Object], __v: [Function: Number], id: [Object] },
     query: {},
     childSchemas: [],
     plugins: [ [Object], [Object], [Object], [Object] ],
     s: { hooks: [Object], kareemHooks: [Object] },
     options:
      { retainKeyOrder: false,
        typeKey: 'type',
        id: true,
        noVirtualId: false,
        _id: true,
        noId: false,
        validateBeforeSave: true,
        read: null,
        shardKey: null,
        autoIndex: null,
        minimize: true,
        discriminatorKey: '__t',
        versionKey: '__v',
        capped: false,
        bufferCommands: true,
        strict: true,
        pluralization: true },
     '$globalPluginsApplied': true,
     _requiredpaths: [] },
  collection:
   NativeCollection {
     collection: Collection { s: [Object] },
     opts: { bufferCommands: true, capped: false },
     name: 'realestates',
     collectionName: 'realestates',
     conn:
      NativeConnection {
        base: [Object],
        collections: [Object],
        models: [Object],
        config: [Object],
        replica: false,
        hosts: null,
        host: '127.0.0.1',
        port: 27017,
        user: undefined,
        pass: undefined,
        name: 'real_estate_info',
        options: [Object],
        otherDbs: [],
        _readyState: 1,
        _closeCalled: false,
        _hasOpened: true,
        _listening: false,
        db: [Object],
        _events: [Object],
        _eventsCount: 4 },
     queue: [],
     buffer: false,
     emitter:
      EventEmitter {
        domain: null,
        _events: {},
        _eventsCount: 0,
        _maxListeners: undefined } },
  '$__original_save': { [Function] numAsyncPres: 0 },
  save: { [Function: wrappedPointCut] '$originalFunction': '$__original_save', '$isWrapped': true },
  _pres:
   { '$__original_save': [ [Object], [Object], [Object] ],
     '$__original_remove': [ [Object] ] },
  _posts: { '$__original_save': [], '$__original_remove': [] },
  '$__original_remove': { [Function] numAsyncPres: 1 },
  remove:
   { [Function: wrappedPointCut]
     '$originalFunction': '$__original_remove',
     '$isWrapped': true },
  '$__original_validate': [Function],
  validate:
   { [Function: wrappedPointCut]
     '$originalFunction': '$__original_validate',
     '$isWrapped': true } }
 ```
以及
```
{}
```

**很显然**，问题就是在这里，`docs[0]`和`docs[0]`的原型并不是一个东西。而js中对象通过`.`或者是`[]`访问属性都是调用了`Object`中的某个方法，但具体什么方法我不太记得。然而`docs`中的原型或者其原型的原型也是没有这个方法的，因此他就没办法去访问这个属性。

其实`docs[0].__proto__.__proto__`是Model,`docs[0].__proto__.__proto__.__proto__`是Document,`docs[0].__proto__.__proto__.__proto__.__proto__`才是`{}`。

至此，这个问题引起的一系列的探究也是告一段落了。其实Mongoose还有另外一些奇怪的地方，被人所诟病，在此也不一一细数了。从问题的发现，到写这篇文章大概花了大半天的时间，以前遇到问题就找到解决办法就停止了，但是这一次通过这样深入地去发现，可能就会发掘到更多的东西。
