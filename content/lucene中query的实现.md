---
title: "lucene 中 query 的实现"
author: Neal
tags: [java, lucene]
categories: [java]
date: "2018-10-09"
---

Lucene 中的 query 支持多种形式，包括多种 query:

* TermQuery
* BooleanQuery
* WildcardQuery
* PhraseQuery
* PrefixQuery
* MultiPhraseQuery
* FuzzyQuery
* RegexpQuery
* TermRangeQuery
* PointRangeQuery
* ConstantScoreQuery
* DisjunctionMaxQuery
* MatchAllDocsQuery

通过不同的 query 实现需要的 query 来进行搜索，也可以将不同的 query 进行组合使用。这些 query 都是 Query 类的继承类。Query 类是一个抽象类，包含了一些基本方法的，而具体实现取决于具体的类。今天主要是想通过源码阅读来了解 RegexpQuery 的具体实现。

RegexpQuery 的继承关系是 Query => MultiTermQuery => AutomatonQuery => RegexpQuery，可见 RegexpQuery 的实现还依赖于 MultiTermQuery 以及 AutomatonQuery。MultiTermQuery 也是一个继承 Query 的抽象类。MultiTermQuery 也是需要通过继承来进行实现，可以通过 MultiTermQuery 来组合多个 term 的 query，另外一方面，