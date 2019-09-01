---
title: "持续发布 Chrome 插件"
author: Neal
tags: [Chrome 插件, CirecleCI]
categories: [开发]
date: "2019-05-27" 
---

Chrome 插件对于 Chrome 浏览器用户来说是必不可少的利器之一。之前我有开发过一款七牛云图床的 Chrome 插件 [image-host](https://github.com/neal1991/image-host)。后来由于我自己没有自己的域名，所以不太好使用这个插件了。后面，有其他的同学来提交 PR 来维护这一个插件。这样就有一个问题，一旦新的代码发布，就需要自己再重新发布一下插件。虽然发布插件不算特别麻烦，打包成压缩包，上传就可以了，但是对于程序员来说，可以自动做的绝对不要手动做。以下就是通过 CircleCI 来持续发布 Chrome 插件，参考了官方的文章，自己也才了一些坑。

## 介绍

CircleCI 是一款持续集成产品，和 Travis 非常类似，都属于 Github 上非常流行的持续集成产品。产品有商业和普通版本，开源项目是可以免费使用的。关于持续集成产品的不同，可以参考[这篇文章](https://hackernoon.com/continuous-integration-circleci-vs-travis-ci-vs-jenkins-41a1c2bd95f5)。使用这个工具持续发布 Chrome 插件的原理就是：通过 CircleCI 来使用 Chrome 插件的 API 来持续发布插件，通过 CirecleCI 和 github 的集成可以在特定的时机就可以发布插件。那么下面具体介绍如何使用 CircleCI 来进行 Chrome 插件的发布，主要包括 Google API 的配置以及 CirecleCI 的配置。

## Google API

首先，创建一个 Google API 项目，可以直接点击[这个链接](https://console.developers.google.com/projectcreate?organizationId=0)创建。

![VG6DzV.png](https://s2.ax1x.com/2019/06/02/VG6DzV.png)

在创建项目之后，我们需要开启 "Chrome Web Store API"。在 Library 中搜索这个 API， 并且将其 ENABLE。

![VGW99s.png](https://s2.ax1x.com/2019/06/02/VGW99s.png)

在 ENABLE 这个 API 之后，就可以点击 "CREATE CREDENTIALS" 创建口令了。确保你已经选择了对应创建的 project。值得注意的一点是，你创建的应该是 OAuth client ID 类型的，确保你选择了正确的类型。

![VGWwvt.png](https://s2.ax1x.com/2019/06/02/VGWwvt.png)

![VwGYRK.png](https://s2.ax1x.com/2019/06/07/VwGYRK.png)

在创建 OAuth client ID 之前，你需要填写一些信息，你需要在 OAuth consent screen 填写一些东西，可以就填写一下 Application name，其它的可以暂时先不填。接着你就可以创建 OAuth client ID 了，选择 Other 类型来进行创建。这样你的 client ID 以及 client secret 就创建好了。

![VwG5on.png](https://s2.ax1x.com/2019/06/07/VwG5on.png)

![VwG7WV.png](https://s2.ax1x.com/2019/06/07/VwG7WV.png)

[![VwGjeJ.png](https://s2.ax1x.com/2019/06/07/VwGjeJ.png)](https://imgchr.com/i/VwGjeJ)

通过访问下面的链接来生成一个 code。记得使用你自己的 client ID 来替换下面链接中的 `$CLIENT_ID`。访问链接后，会弹出授权链接，允许之后就会出现 code 了，保存好这个信息。

```
https://accounts.google.com/o/oauth2/auth?response_type=code&scope=https://www.googleapis.com/auth/chromewebstore&client_id=$CLIENT_ID&redirect_uri=urn:ietf:wg:oauth:2.0:oob
```

[![VwJ4XD.png](https://s2.ax1x.com/2019/06/07/VwJ4XD.png)](https://imgchr.com/i/VwJ4XD)

[![VwJjc8.png](https://s2.ax1x.com/2019/06/07/VwJjc8.png)](https://imgchr.com/i/VwJjc8)

现在我们应该有 3 个字段信息， client ID, client secret 以及我们刚刚获取的 code。下面我们要做的就是获取一个叫做 refresh token 的东西。你可以按照以下命令来获取 refresh token，你需要使用 curl 以及 jq 这两个工具。和上面一样，记得替换下面命令中相对应的变量。因为需要访问谷歌，你需要确保你的终端可以访问谷歌。在成功执行这个命令之后，就可以获取 refresh token 了，保存好这个信息。

```
curl "https://accounts.google.com/o/oauth2/token" -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&code=$CODE&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob" | jq '.refresh_token'
```

最后一步就是获取 Chrome 插件的 Application ID。这一步是最简单的了，你只要访问你的 Chrome 插件，就可以在插件的 URL 中可以看到这个插件的 Application ID 了。现在我们已经拿到了我们所有需要的信息，下面就是如何使用 CirecleCI 来进行配置来完成发布任务了。

[![Vwt6Rx.png](https://s2.ax1x.com/2019/06/07/Vwt6Rx.png)](https://imgchr.com/i/Vwt6Rx)

```
curl "https://accounts.google.com/o/oauth2/token" -d "client_id=235111551101-bv1v37f62thpa48jv58rojbjpkjjis7e.apps.googleusercontent.com&client_secret=cxCM40gME_odlELuVr4B9eSD&code=4/YgFSGSQuhSec7WDVF-4x4YOEOp9moHZ8Bm0pgUIxSY9x9EzvE7_sjIo&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob" | jq '.refresh_token'
```

## CircleCI 配置

为了使用 CircleCI，你需要在仓库中创建文件夹 `.circleci`，在这个文件夹中创建文件 `config.yaml`。确保你创建正确的文件夹和文件名，否则 CircleCI 会一直没办法工作并且不好排查到原因。我就是因为文件夹名字弄错了，看了好久。。。一般的配置文件的环境配置如下所示。注意我们使用的是 [CircleCI 2.0](https://circleci.com/features/)版本。你还可以选择 docker 中操作系统的版本。你也可以通过 `environment` 来设置环境变量。

```
version: 2
jobs:
  build:
    docker:
      - image: ubuntu:16.04
    environment:
      - APP_ID: <INSERT-APP-ID>
```

你可以通过 `steps` 来配置步骤，其实这和 Travis 基本类似，通过配置步骤来进行配置，比如安装依赖，进行测试，发布等。在这里，我们主要会安装上面我们使用过的工具：`curl` 以及 `jq`。

```
 steps:
      - checkout
      - run:
          name: "Install Dependencies"
          command: |
            apt-get update
            apt-get -y install curl jq
            # You can also install Yarn, NPM, or anything else you need to use to build and test your extension.
```

Chrome 插件的打包其实比较简单。只要将文件夹打包成 zip 压缩文件即可。这里，选择使用 `git archive` 命令来打包压缩文件，这样做的好处是不会把 `.git` 文件夹打包进去。所以，以下配置可用于打包 Chrome 插件的压缩文件。

```
- run:
    name: "Package Extension"
    command: git archive -o pointless.zip HEAD
```

接下来就是利用 Chrome Store API 来进行 Chrome 插件的发布了。 Chrome Store API 使用 access token 来进行认证操作。但是 access token 有效期只有 40 分钟。幸好我们可以利用 refresh token 来获取新的 access token。通过这个 access token 我们可以上传压缩文件并且发布插件。

```
  - run:
        name: "Upload & Publish Extension to the Google Chrome Store"
          command: |
        if [ "${CIRCLE_BRANCH}" == "master" ]; then
            ACCESS_TOKEN=$(curl "https://accounts.google.com/o/oauth2/token" -d "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&refresh_token=${REFRESH_TOKEN}&grant_type=refresh_token&redirect_uri=urn:ietf:wg:oauth:2.0:oob" | jq -r .access_token)
            curl -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-goog-api-version: 2" -X PUT -T pointless.zip -v "https://www.googleapis.com/upload/chromewebstore/v1.1/items/${APP_ID}"
            curl -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-goog-api-version: 2" -H "Content-Length: 0" -X POST -v "https://www.googleapis.com/chromewebstore/v1.1/items/${APP_ID}/publish"
        fi
```

不过这里有一点值得注意的是，这里面有一些敏感信息，包括 `CLIENT_ID`，`CLIENT_SECRET`以及 `REFRESH_TOKEN` 这些信息。我们不希望在脚本里面直接配这些信息。那么我们就需要在环境变量中配置这些变量的信息了。可以在 CircleCI 里面来进行环境变脸的配置，找到对应的 project 来进行环境变量的配置。

![V09fTs.png](https://s2.ax1x.com/2019/06/07/V09fTs.png)

你也可以通过配置工作流将不同的步骤分开独立，并且支持步骤之间的依赖，比如 build 工作流依赖于 test 工作流，如果 test 工作流没有完成，就没有办法进行 build 工作流。同时，还可以进行条件的过滤，比如只针对特定的分支，或者特定的标签。下面是我的 Chrome 插件 [image-host](https://github.com/neal1991/image-host) 的完整的配置文件。

```yaml
version: 2
workflows:
  version: 2
  main:
    jobs:
      - build
      - publish:
          requires:
            - build
          filters:
            tags:
              only: /^v\d+\.\d+\.\d+$/
jobs:
  build:
    docker:
      - image: cibuilds/chrome-extension:latest
    steps:
      - checkout
      - run:
          name: "Package Extension"
          command: git archive -o image-host.zip HEAD
      - persist_to_workspace:
          root: /root/project
          paths:
            - image-host.zip    
  publish:
    docker:
      - image: cibuilds/chrome-extension:latest
    steps:
      - attach_workspace:
          at: /root/project
      - run:
          name: "Upload & Publish Extension to the Google Chrome Store"
          command: |
            if [ "${CIRCLE_BRANCH}" == "master" ]; then
              ACCESS_TOKEN=$(curl "https://accounts.google.com/o/oauth2/token" -d "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&refresh_token=${REFRESH_TOKEN}&grant_type=refresh_token&redirect_uri=urn:ietf:wg:oauth:2.0:oob" | jq -r .access_token)
              curl -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-goog-api-version: 2" -X PUT -T image-host.zip -v "https://www.googleapis.com/upload/chromewebstore/v1.1/items/${APP_ID}"
              curl -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-goog-api-version: 2" -H "Content-Length: 0" -X POST -v "https://www.googleapis.com/chromewebstore/v1.1/items/${APP_ID}/publish"
            fi
```

## 总结

CircleCi 是一款还不错的持续发布工具，结合 Github 其实还有还多更高级的用法，后续可以在更多的项目中尝试这个工具。

## Reference

* https://circleci.com/blog/continuously-deploy-a-chrome-extension/

