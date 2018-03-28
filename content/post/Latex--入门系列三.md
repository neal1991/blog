---
title: "Latex--入门系列三"
author: Neal
description: "Latex 专业的参考tex对于论文写作或者其他的一些需要排版的写作来说，还是非常有意义的。我在网上看到这个对于Latex的入门介绍还是比较全面的，Arbitrary  reference .所以将会翻译出来，供初学者学习。TeX语法TeX语法，编辑你可能已经注意到，(La)TeX文档是蠢笨的基本上不包含什么具有特殊意义的符号，经常是依赖环境的并且很容易就可以看得出来。下面有一段LaTeX的代码，你"
tags: [latex]
categories: [论文写作]
date: "2016-12-12 15:48:08"
---
# Latex 专业的参考

tex对于论文写作或者其他的一些需要排版的写作来说，还是非常有意义的。我在网上看到这个对于Latex的入门介绍还是比较全面的，[Arbitrary  reference](http://latex.knobs-dials.com) .所以将会翻译出来，供初学者学习。
## TeX语法

### TeX语法，编辑

你可能已经注意到，(La)TeX文档是蠢笨的基本上不包含什么具有特殊意义的符号，经常是依赖环境的并且很容易就可以看得出来。下面有一段LaTeX的代码，你也不用担心你还读不懂它，因为它可能包含不少的特别的符号：

```latex
I am text. Yes.

%comment: a semi-complex table with math in it:
\begin{tabular}{|l|r|}
 \hline
 $a_1~~~b$ & $\sqrt[3]{a_1^2}$ \\
\end{tabular}
```

最终产生的表格的排版是这个样子的![tab](http://latex.knobs-dials.com/images/7d5f9100c96107ce945caf17f5f4092cc2285b92.110.png)

### 特殊符号的总结

* **{**和**}**是作为一些命令参数来定义一些小块，比如临时的粗黑体在`{\bf bold}`

* **$**是用来开始和结束数学模式的，比如一些公式啊，数字之类的。你可以在你文本的任何地方插入`$a+b=c$`，输入`$$a+b=c$$`，那么你的公式就会在段与段之间以块的形式展现。

* **%**是用来注释的，这个是单行注释。如果你要注释大段的代码的时候，为了避免插入过多的百分号，你可以把这些字符放在`\iffalse`和`\fi`里面。

* **_**和**^**分别作为下标和上标。你也可以同时使用上标和下标，比如：![formula1](http://latex.knobs-dials.com/images/16ac076820e1df6038500ee08ee65d76ed316e47.120.png)

* **~**是一个硬空格，它对于排版是有影响的，它是具有大小的，并且不可分连的空格，就像&nbsp一样的。它很有用比如：`A.~Smith`以及在引用的图表的时候`Figure~\ref{dataflow}`,这确保了作者姓名或者图片和数字之间不会在行与行之间分隔。（也可以使用其他的办法来解决这个问题，比如mbox，不会强制使用特殊的空格大小）

* 实际上，`\ `经常和`~`拿起来一起来使用。尽管这两者之间还是有区别的：`\ `是字间的空格，经常用来告诉LaTeX这不是句子的末尾，一般用于缩写或者标题。(`Dr.\ Jones`)

* **&**适用于在数组以及表格中定义列的。

* **\**用于开始一个命令。有一些可能是比较特殊的(`\\`用于换行，`\>`用于tab缩进)，一般化的话应该是这样的`\commandname`。当然这可能会有看起来不太相同的使用方法：

  * 一次效果函数，比如使用`\ss`来获得一个德国字母![\ss](http://latex.knobs-dials.com/images/9ffef8f0b5c7c54c24e674529f21ea9d238ee17a.90.png)。

  * 状态改变，比如粗体，强调，比如`text-{\em a-tron}`会产生![text-{\em a-tron}](http://latex.knobs-dials.com/images/acef73a11eb4d5db7c58a2e90c9fbf3275036f59.90.png)。（花括号是来限制作用的范围的）

  * 使用命令取得相应的值，一般是使用`{}`或者`[]`。比如：

    * `\textsc{SmallCaps}`产生![\textsc{SmallCaps}](http://latex.knobs-dials.com/images/b6ee9181b90a3df999713ea8d56ccd18b12e5a0d.90.png)
    * `\caption{Description`用于标题说明，一般用于图表。
    * 口音和发声符号，比如`\'{e} \v{o}`来产生![\'{e} \v{o}](http://latex.knobs-dials.com/images/adbf6cdf913ff33772131646daeace9f54f16083.90.png)

  * 使用`\begin`和`end`是定义环境，从而和其他内容区分处理，比如：

    ```latex
    \begin{verbatim}
    In the verbatim environment, 
     text appears with almost no treatment.
    There's also no need for manual TeX newlines (\\)
    \end{verbatim}
    ```

    会产生![ \begin{verbatim}In the verbatim environment,  text appears with almost no treatment.There's also no need for manual TeX newlines (\\)\end{verbatim}](http://latex.knobs-dials.com/images/3d054b70734c3a9a9e04195236946b4b7cfa29a8.90.png)

  这些命令有选择项和参数项，对于每一个命令都有着相应的设置。有一些命令定义后，你可以用几种方式使用，但是一般的使用时选择项在参数项之前，比如对于`\command[option1,option2]{argument}`你可以用`\comman{argument}`作为基本使用。

* **#**是在内部使用的，比如`\newcommand`


为了在文本里面使用上述的一些字符，你需要添加反斜杠使用`\$ \{ \% \} \_ \#`从而产生![\$ \{ \% \} \#](http://latex.knobs-dials.com/images/7a2cf6db5f01b41a35128ca1498d4f967c51dbf2.100.png)

这里也有几个意外情况，`\\`是一个字面上的换行，`\~`是一个插入符号。

对于反斜杠如何表示，可以使用`$\backslash$`

对于其他的一些插入符号，你可以将参数不加设置，`\~{}, \^{}`，这样也能获得你想要的比如![foo \^{} bar \~{} quu #](http://latex.knobs-dials.com/images/a63f4e5a026678d6b477830afe06134302a26aee.100.png)

对于等宽字体你也可以使用inline verbatim，比如`\verb|^|, \verb|~|, \verb|\|`

### 关于波浪字符和插入字符更多信息

为了在URLs里面使用波浪符号，你可以使用url包，这个可以为你处理任何事情：波浪符号会被当做一个波浪符号而不是TeX里面的空格，它复制一个波浪符号而不是空格，这个URLs也是可以点击的。

为了在非URL文本里面获得波浪符号，当然还有其他的办法，比如[swung dash](https://en.wikipedia.org/wiki/Dash#Swung_dash)

* 你可以获得一个不一样的波浪符号（在空格之上）通过使用`\~{}, \textasciitilde, \char \~`。这个波浪符号位置比较高，大多数人并不喜欢用。
* 如果你希望在等宽字体里面使用波浪符号，一个简单的方法是使用verbatim环境，可能没有内联的使用起来那么方便`\verb|foo/~var`![\verb|foo/~bar|](http://latex.knobs-dials.com/images/7dc8b48bcff8d1d865a6bcb1e9e5c5c9dac04171.90.png)
* `texttidlebelow`（依赖包textcomp）的位置更低，但是不能够以波浪符号粘贴复制。它在某些字体面，位置可能特别低，这个可能和字体相关。
* `$\sim$`对于大多数情况来说就不太常用了，一般在数学环境里面用的比较多。

如果你不想使用宏命令，你也可以自己创建一个波浪符号，自己来调整位置和样式。比如：

你可以提高`\sim`波浪符号的位置通过`{\raise.17ex\hbox{$\scriptstyle\sim$}}`

你也可以降低波浪符号的位置，在`\mathtt`里面看起来更精细，你可能比较偏向于在普通文本中使用。在`texttt`看起来更粗，对于等宽字体显示效果比较好。比如，你可以定义：

`\newcommand\thintilde{{\lower.92ex\hbox{\mathtt{\char`\~}}}}`

`\newcommand\thicktilde{{\lower.74ex\hbox{\texttt{\char`\~}}}}`

你可以产生`a\thintilde b\thicktilde c`看起来就是这样![a\thintilde b\thicktilde c](http://latex.knobs-dials.com/images/ddfaf8eb96829130e1b80448ad6e642a4b7ff77e.130.png)

作为对比：

![\begin{tabular}{lll} & & result \\\hline\verb#url# package                                         & & \url{foo/~bar~} \\\verb|\~{}| ~and~ \verb|\textasciitilde|                  & & foo/\~{}bar\~{} \\\verb|{\tt \~{}}| ~and~ \verb|\textt{\~{}}|           & & foo/{\tt \~{}}bar{\tt \~{}} \\simple {\hspace{-.25ex}\lower.72ex\hbox{\texttt{\~{}}}} in verbatim environment                            & & \verb|foo/~bar| \\\verb#\texttildelow#                                      & & foo/\texttildelow bar\texttildelow \\basic \verb#$\sim$#                                          & & foo/{$\sim$}bar{$\sim$} \\~\\~~~~~~~~~~~~~~~~~~~~~~~mucking about: \\tweaked \verb|\sim|                                        & & foo/{\raise.17ex\hbox{$\scriptstyle\sim$}}bar{\raise.17ex\hbox{$\scriptstyle\sim$}} \\tweaked \verb|\sim| {\small (looks in monospace context)}  & & {\tt foo/{\raise.17ex\hbox{$\scriptstyle\sim$}}bar{\raise.17ex\hbox{$\scriptstyle\sim$}} } \\lowered diacritic tilde, mathtt                             & & {foo/{\lower.92ex\hbox{\mathtt{\char`\~}}}bar{\lower.92ex\hbox{\mathtt{\char`\~}}} } \\lowered diacritic tilde, texttt                             & & {\tt foo/{\lower.74ex\hbox{\texttt{\char`\~}}}bar{\lower.74ex\hbox{\texttt{\char`\~}}} } \\\hline\end{tabular}](http://latex.knobs-dials.com/images/b65770c89060158a3aa055b4bb7b449089290ca2.130.png)

当你希望使用一个字面上的插入符号，`\^{}`是一个高的发音符号，你也可以在verbatim样式里面使用，比如：

![\verb|x=x^2|](http://latex.knobs-dials.com/images/6464cb2daeb065351c0f35657bff30fa9a38f0f9.120.png)