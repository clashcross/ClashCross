# 集成ClashCross后，您的网站将有机会展示在我们的应用里，获得更高的推广度

## 示例
![image](/docs/screenshot/help_demo_photo_2023-07-31_18-39-18.jpg)

## url_scheme 形式：

```
clashcross://?url=...&name=...&siteurl=...&sitename=...
```

## Deep Link 形式:

```
https://www.clashcross.xyz/site/share?url=...&name=...&siteurl=...&sitename=...
```

## 参数说明

- url为订阅链接,必填参数;
- name为订阅名称,可选参数;
- siteurl为网站域名,可选参数;
- sitename为网站名称(长度限制为10，超过将自动截取),可选参数.
- 注意：要将您的网站展示于ClashCross帮助页面,siteurl和sitename均不能为空

# 常见管理系统集成示例：

## v2board：

修改目录下/public/theme/v2board/assets/umi.js 文件内容如下：

```javascript
...
return (Object(u["i"])() || Object(u["j"])()) && (t.push({
title: "Shadowrocket",
href: "shadowrocket://add/sub://" + window.btoa(e + "&flag=shadowrocket")
.replace(/\+/g, "-")
.replace(/\//g, "_")
.replace(/=+$/, "") + "?remark=" + window.settings.title
}), t.push({
title: "QuantumultX",
href: "quantumult-x:///update-configuration?remote-resource=" + encodeURI(JSON.stringify({
server_remote: [e + ", tag=" + window.settings.title]
}))
}), t.push({
title: "Surge",
href: "surge:///install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}), t.push({
title: "Stash",
href: "stash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
})), Object(u["k"])() && (t.push({
title: "ClashCross",
href: "clashcross://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}),t.push({
title: "ClashX",
href: "clash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
})), Object(u["n"])() && (t.push({
title: "ClashCross",
href: "clashcross://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}),t.push({
title: "Clash For Windows",
href: "clash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
})), Object(u["g"])() && (t.push({
title: "ClashCross",
href: "clashcross://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}),t.push({
title: "Clash For Android",
href: "clash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}), t.push({
title: "Surfboard",
href: "surge:///install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}))
...
```

然后将ClashCross.png图标文件上传到public/theme/v2board/assets/images/icon 。
您也可以直接下载我们修改好的umi.js文件进行覆盖。[下载地址](/docs/v2board)