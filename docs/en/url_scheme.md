# ClashCross Network Alliance - Your website has the opportunity to be showcased on the ClassCross Help page.
## Demo
## 示例
![image](docs/screenshot/help_demo_photo_2023-07-31_18-39-18.jpg)
## url_scheme format:

```
clashcross://?url=...&name=...&siteurl=...&sitename=...
```

## Deep Link format:

```
https://www.clashcross.xyz/site/share?url=...&name=...&siteurl=...&sitename=...
```

## Parameter Explanation

- url: Subscription link, mandatory parameter.
- name: Subscription name, optional parameter.
- siteurl: Website domain, optional parameter.
- sitename: Website name (limited to 10 characters, will be automatically truncated if exceeded),
  optional parameter.

- Note: To have your website showcased on the ClashCross Help page, both siteurl and sitename must
  not
  be empty.

# Common examples of management system integration:

## v2board:

Modify the content of the file /public/theme/v2board/assets/umi.js as follows:

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
}), t.push({
    title: "ClashX",
    href: "clash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
})), Object(u["n"])() && (t.push({
    title: "ClashCross",
    href: "clashcross://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}), t.push({
    title: "Clash For Windows",
    href: "clash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
})), Object(u["g"])() && (t.push({
    title: "ClashCross",
    href: "clashcross://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}), t.push({
    title: "Clash For Android",
    href: "clash://install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}), t.push({
    title: "Surfboard",
    href: "surge:///install-config?url=" + encodeURIComponent(e) + "&name=" + window.settings.title
}))
...
```

Then, upload the ClashCross.png icon file to /public/theme/v2board/assets/images/icon.

Alternatively, you can directly download the modified umi.js file to overwrite the existing
one. [Download link](/docs/v2board)