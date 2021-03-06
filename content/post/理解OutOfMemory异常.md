---
title: "理解 OutOfMemoryError 异常"
tags: ["Java"]
categories: ["后端"]
keywords: [OutOfMemory,Error,JAVA,Exception]
date: "2018-05-26"
---

![overflow.jpg](http://ozfo4jjxb.bkt.clouddn.com/overflow.jpg)

OutOfMemoryError 异常应该可以算得上是一个非常棘手的问题。JAVA 的程序员不用像苦逼的 C 语言程序员手动地管理内存，JVM 帮助他们分配内存，释放内存。但是当遇到内存相关的问题，就比如 OutOfMemoryError，如何去排查并且解决就变成一个非常令人头疼的问题。在 JAVA 中，所有的对象都存储在堆中，通常如果 JVM 无法再分配新的内存，内存耗尽，并且垃圾回收器无法及时回收内存，就会抛出 OutOfMemoryError。


我之前在做一个工具，需要读取大量的文件，比如 word 或者 excel，而我给机器分配的最大的内存只有 2G。所以，很多人的机器往往会因为 OutOfMemoryError 异常导致程序中止运行。后来我发现一个现象，OutOfMemoryError 可以通过 Error 或者 Throwable 去捕获，OutOfMemoryError 类继承关系如下：

```
java.lang.Object
    java.lang.Throwable
        java.lang.Error
            java.lang.VirtualMachineError
                java.lang.OutOfMemoryError
```

因此 OutOfMemoryError 是一个 Error 而不是一个 Exception，并且据我观察，OutOfMemoryError 无法被 throw 到上一层函数中。

```java
private void OutOfMemoryErrorTest() {
    try {
        // do something might lead to OutOfMemoryError error
    } catch (Error e) {
        e.printStackTrace();
    }
}
```

## 发生 OutOfMemoryError 的原因

越早找出 OutOfMemoryError 的原因就越利于我们解决问题。到底是因为 JAVA 的堆满了还是因为原生堆就满了呢？为了找到其原因，我们可以通过异常的细节信息来获得提示。

### Exception in thread thread_name: java.lang.OutOfMemoryErrorError: Java heap space

这是一个非常常见的情况，大多数 OutOfMemoryError 的异常都是因为这个原因导致的。这个细节信息表示在 JAVA 堆中无法再分配对象。这个错误并不代表你的程序一定发生了内存泄漏。可能很简单这就是一个配置的问题，可能默认的堆内存（JVM 设置的内存）无法满足应用的需求。

另外，也有可能是在一些长时间运行的程序中，可能是一直保持着对某些对象的引用（实际上这些对象已经不需要了），这会阻止垃圾回收器收集内存从而无法分配新的内存空间。这就等同于是一个内存泄漏。

另外一个潜在的原因可能是对于 finalize 方法的过度使用。如果某个类具有 finalize 方法，那么属于这种类的对象在垃圾回收时就不会回收空间。而是在垃圾回收之后，对象会在一个队列中等待析构，这通常会发生的迟一些。在 Oracle Sum 公司的实现中，finalizer 是通过一个为 finalization 队列提供服务的守护线程来执行。如果 finalizer 线程的速度没有办法跟上 finalization 队列速度的时候，那么 JAVA 堆就会填满接着就会抛出 OutOfMemoryError 异常。

### Exception in thread thread_name: java.lang.OutOfMemoryErrorError: GC Overhead limit exceeded

这是另外一个常见的异常信息，这个信息一般表示 JAVA 程序运行很缓慢并且垃圾回收器一直在运行。在垃圾回收之后，如果 JAVA 进程花费超过 98% 的时间来做垃圾回收，如果在连续的 5次垃圾回收中恢复少于 2% 的堆内存，就会抛出 OutOfMemoryError 异常。一般这种情况下是因为生成大量的数据占用 JAVA 堆内存从而没有办法分配新的内存。通俗的来讲，垃圾回收器回收的速度还没有办法跟上内存分配的速度。这就好比有户人家家里是有点财产，但财产是有限的，虽然能定时收回来一些，但是禁不住家里有个败家子，所以迟早有一天会破产（OutOfMemoryError）。

不过对于 **GC Overhead limit exceeded** 可以通过命令行标志 `-XX:-UseGCOverheadLimit` 来进行关闭，虽然最终还是可能还是会抛出 OutOfMemoryError 异常。

### Exception in thread thread_name: java.lang.OutOfMemoryErrorError: Requested array size exceeds VM limit

这个异常信息表示应用程序尝试给数组分配一个大于堆大小的数组。比如，如果程序尝试分配一个 512 MB 大小的数组，但是堆大小最大只有 256MB，那么 OutOfMemoryError 异常则会被抛出。导致这种异常信息的原因一般要么就是配置的问题（堆内存太小），要么就是程序的 BUG，尝试分配太大的数组。

### Exception in thread thread_name: java.lang.OutOfMemoryErrorError: Metaspace

Java 类 metadata（Java 类虚拟机内部的表示） 使用原生内存（这里指的是 metaspace）来进行分配。如果用于 metadata 的 metaspace 耗尽了，那么具有这个异常信息的 OutOfMemoryError 异常就会被抛出。Metaspace 的总数受限于参数 MaxMetaSpaceSize，这个可以通过命令行来进行设置。当分配给 metadata 原生的内存总数超过了 MaxMetaSpaceSize，那么带有这个异常信息的 OutOfMemoryError 异常就会被抛出。MetaSpace 和 JAVA 堆从同样的地址空间进行分配。减少 JAVA 堆的大小就会增加 MetaSpace 的空间。

### Exception in thread thread_name: java.lang.OutOfMemoryErrorError: request size bytes for reason. Out of swap space?

这个异常信息看起来是一个 OutOfMemoryError 异常。然而，当原生堆无法分配内存或者原生堆可能接近耗尽的时候，Java HotSpot VM 代码就会报这个异常。通常这个异常信息的原因是源代码模块报告分配失败，尽管有时候的确是这个原因。当这个错误消息被抛出时，VM 会调用致命错误处理机制（即它会生成一个致命的错误日志文件，其中包含有关崩溃时线程，进程和系统的有用信息）。 在本地堆耗尽的情况下，日志中的堆内存和内存映射信息可能很有用。如果抛出 OutOfMemoryErrorError 异常，则可能需要在操作系统上使用故障排除实用程序来进一步诊断问题。 

### Exception in thread thread_name: java.lang.OutOfMemoryError: Compressed class space

在 64 位平台上，指向 metadata 类的指针可以用32位偏移量（使用 UseCompressedOops）表示。这由命令行标志 UseCompressedClassPointers（默认为on）控制。如果使用 UseCompressedClassPointers，则metadata 类的可用空间量将固定为 CompressedClassSpaceSize。如果 UseCompressedClassPointers 所需的空间超过 CompressedClassSpaceSize，则会抛出一个包含详细 Compressed 类空间的java.lang.OutOfMemoryError。
增加CompressedClassSpaceSize 可以关闭 UseCompressedClassPointers。CompressedClassSpaceSize 的可接受大小存在界限。例如 `-XX：CompressedClassSpaceSize = 4g`，超过可接受的范围将导致如下消息:

`CompressedClassSpaceSize of 4294967296 is invalid; must be between 1048576 and 3221225472.`

注意：有多种类型的元数据类- klass metadata 和其他 metadata。只有 klass metadata 存储在由 CompressedClassSpaceSize 限定的空间中。其他 metadata 存储在 Metaspace 中。

### Exception in thread thread_name: java.lang.OutOfMemoryError: reason stack_trace_with_native_method

如果异常信息是这个，并且打印了堆栈跟踪，其中第一帧是本机方法，则表明本机方法遇到了分配故障。 这与之前的消息之间的区别在于分配失败是在 Java 本地接口（JNI）或本机方法中检测到的，而不是在JVM代码中检测到的。如果抛出此类 OutOfMemoryError 异常，则可能需要使用操作系统的本机实用程序来进一步诊断问题。 

## 解决办法

以上说到了多种 OutOfMemoryError 异常的情况以及其可能的原因，那么应该如何解决 OutOfMemoryError 异常呢？发生这种异常的原因其实是多种多样的，有的时候可能是程序的 BUG，导致了内存泄漏。有的时候可能就是设置问题，内存设置太小，只要设置大一点就可以了。有的时候也不一定就是内存泄漏，可能就是程序分配的内存无法处理，这时候就需要你想办法来进行优化，避免内存的消耗，或者准确的来说尽量避免一次性分配太多的内存，从而导致内存分配失败。以下，就我自己的一些经验，谈谈一些解决办法。

最简单，最粗暴的方法就是直接调整 JVM 的堆大小。通过 `-Xmx` 参数可以设置 JAVA 堆最大内存，一般来说如果你一开始分配的内存过小，则可以通过这样的设置来避免。参数的设置应该根据程序的运行情况和机器的实际内存决定的，一般来说 JVM 的堆大小不应该超过机器内存的一半。通过调整参数设置或许可以解决一时的问题，但是往往只是推迟了 OutOfMemoryError 发生的时间，但是找到程序的关键问题，查出内存消耗的关键点才是根本之道。

另外一种常见的避免异常的方法就是记得关闭输入流。经常有人打开文件的时候，忘记最后关闭输入流，倘若发生了异常，就会导致输入流没有关闭。常见的做法就是在 `finally` 关闭输入流，因为在 `finally` 中最后都会执行这一步骤。在 JAVA7 就可以通过 `try-with-resources` 实现资源的自动关闭：

```java
try (FileInputStream input = new FileInputStream("file.txt")) {
    // operate the data
}
```

字符串和 List 是 JAVA 中经常使用的数据类型。其实 JAVA 内置已经做了很多针对于 String 的优化，个人可以做的优化其实已经微乎其微了。开发者可以做的是就是检查程序字符串的分配，是否进行了一些没有必要的字符串操作，反正就是能省一点是一点。另外就是对于动态数组类型的数据，尽量可以使用 ArrayList。ArrayList是实现了基于动态数组的数据结构，而LinkedList是基于链表的数据结构。一般来说，对于数据的操作，对于数据的查询 ArrayList 的效率更高，但是如果是删除或者插入，那么 LinkedList 的效率就更胜一筹了。ArrayList 的空间浪费主要体现在在 list 列表的结尾预留一定的容量空间，而 LinkedList 的空间花费则体现在它的每一个元素都需要消耗相当的空间。因为 ArrayList 的实现是基于动态数组，ArrayList 在动态拓展大小的时候都是以 1.5 倍的比率增加的，这样导致当 ArrayList 已经很大的时候，其动态拓展时需要分配更多的空间。另外一小点就是通过 `trimSize` 可以减少 ArrayList 占用的空间，但是确保之后不会再添加新的元素就可以了。

另外一种常见的情况就是读取文件，比如 txt 文件以及 excel 或者 word 文件。我开发的程序就是需要读取大量的文件，而 OutOfMemoryError 往往就是因为文件读取导致的。通过 `Scanner` 读取 txt 文件可以通过分隔符控制一次读取的文本量的大小（useDelimiter），从而避免一次读取大量的文本。对于 word 和 excel 的读取，POI 可以说得上是最优秀的方案，之前我写过一篇文章[POI 读取文件的最佳实践](https://segmentfault.com/a/1190000012165530)，这篇文章总结了使用 POI 读取 word 和 excel 文件遇到的一些坑，我觉得可以算得上是国内网上比较好关于这方面的文章。老版本的 word 或者 excel 是二进制数据，而之后的版本本质上其实就是压缩文件。如果你将 docx 文件使用压缩文件打开，可以观察其内部组成。所以，虽然 word 或者 excel 文件的大小可能不是很夸张，但是在读取器内存的时候，往往需要消耗大量的内存。对于 excel 文件的读取，可以采取流式的方式去读去，将特别大的文件拆分成临时的小文件再进行读取，从而避免内存溢出。网上就有一个优秀的第三方库 [excel-streaming-reader](https://github.com/monitorjbl/excel-streaming-reader)。另外一个做的优化就是，对于可以使用 File 对象的场景下，我是去使用 File 对象去读取文件而不是使用 InputStream 去读取，因为使用 InputStream 需要把它全部加载到内存中，所以这样是非常占用内存的。

还有一点就是开发思维上的一些注意事项，避免长时间的对同一变量进行操作，比如一直操作数组，不断添加新的元素，这样的确很容易造成 OutOfMemoryError 异常。可以分批进行操作，从而避免无限制的扩大内存，最终导致内存耗尽。

总而言之，导致内存溢出的原因可能各种各样，可能不是某单单一个原因导致的，其表现可能也不是稳定的。这也就是 OutOfMemoryError 为什么排查起来比较困难，也比较难解决。有时候可能也需要借助于性能分析工具，比如 dump 内存日志或者使用 jdk 自带的 jvm 性能分析工具 jConsole 分析内存的使用情况排查问题。

以上
   