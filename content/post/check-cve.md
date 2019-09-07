---
title: "cve check"
author: Neal
tags: [python]
categories: [安全开发]
date: "2019-07-04" 
---

今天想检查一下 Gitlab 11.9.0 产品受哪些 cve 的影响。其实网上已经有很多网站可以查询产品的相关 cve，但就是粒度比较粗。我想在 cve 列表中筛选出特定的版本，已经特定的版本，比如是社区版还是旗舰版。找了一下，没有发现完全符合这个要求的。后来在网上我就看到了一个网站是可以提供 cve 的 API 查询的。可以通过网站 API 可以获取特定的数据。

可以通过 https://cve.circl.lu/api/ 可以看到 API 文档。可以通过 cve id 以及 product 以及其他更多信息来查询。最有用的 API 就是这一个，

![ZUIwgH.png](https://s2.ax1x.com/2019/07/04/ZUIwgH.png)

可以通过 vendor 以及 product 获取指定 vendor 和 product 的 cve 列表。这个 API 返回的结果是一个 JSON 数组，我们需要在这里面过滤出相应的版本号以及 edition 版本。另外由于请求的结果一般是一个很长的 json 数据，我的做法是第一次请求，可以吧结果保存成 JSON 文件，第二次请求的时候首先检查这个 JSON 文件的最近修改时间，如果最近修改时间小于指定的天数，比如 3 天，如果 3 天内修改过的话，直接从 JSON 文件加载数据，否则重新发送请求，加载数据。

```
# check if file modified in the last several days
def check_file_modified(filename, days):
    file_modify_time = getmtime(filename)
    return time() - file_modify_time < (days * 3600 * 1000)


def write_json(filename, result):
    with open(filename, 'w') as f:
        dump(result, f, indent=2)


def write_csv(filename, result, header):
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f, delimiter=',')
        writer.writerow(header)
        for ele in result:
            writer.writerow([ele["id"], ele["last-modified"], ele["cvss"], ele["summary"]])


def search(params, options):
    url = "https://cve.circl.lu/api/search/" + params
    print(url)
    filename = f"{params.replace('/', '-')}.json"
    try:
        if isfile(filename) and check_file_modified(filename, 3):
            with open(filename, 'r') as f:
                result = loads(f.read())
        else:
            res = get(url)
            if res.status_code == 200:
                with open(filename, 'w') as f:
                    f.write(res.text)
                result = loads(res.text)
            else:
                print("Request failed: %d".format(res.status_code))
        cve_result = []
        for ele in result:
            if has_cve(ele, options.vendor, options.product, options.version, options.edition):
                obj = {
                    "id": ele["id"],
                    "last-modified": ele["last-modified"],
                    "cvss": ele["cvss"],
                    "summary": ele["summary"]
                }
                cve_result.append(obj)
            else:
                continue
        print(f"{options.vendor}:{options.product}:{options.version}:{options.edition} "
              f"has impacted by {len(cve_result)} cve")
        if options.output is None or options.output == "csv":
            write_csv("result.csv", cve_result, ["id", "last-modified", "cvss", "summary"])
        else:
            write_json("result.json", cve_result)
    except Exception as e:
        print(e)
```

完整的项目地址可以参考 https://github.com/neal1991/check-cve/blob/master/check-cve.py


