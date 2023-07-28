# 常见管理系统集成示例：
## v2board：
修改目录下/public/theme/v2board/assets/umi.js 文件内容如下：
```
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