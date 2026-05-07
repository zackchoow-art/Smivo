# Smivo 深度链接与认证系统调查报告及修复指南

## 1. 问题概述
目前 Smivo 项目在分享与认证环节存在以下四个核心问题：
1. **深度链接失效**：点击商品分享链接（smivo.io）直接打开网页，未能唤起 App。
2. **分享预览异常**：链接在社交软件中显示的预览图是默认背景，而非商品实拍图。
3. **Web App 404**：点击“Open Web App”按钮跳转到 `smivo.app/listing/...` 提示页面不存在。
4. **验证链接需修复**：新用户注册后，点击验证邮件可以验证注册。验证完成后，点击页面上的open smivo app按钮，无法唤醒app，浏览器提示地址无效。

---

## 2. 调查结果分析

### 问题 A：Bundle ID 不匹配（导致深度链接失效）
*   **发现**：您的真实 Bundle ID 是 `com.smivo.app`，但服务器配置（AASA 文件）和 App 内部常量中使用的都是 `com.smivo`。
*   **后果**：iOS 系统认为 `smivo.io` 域名关联的是另一个不存在的 App，因此拒绝自动打开您的 App。

### 问题 B：缺少 URL Scheme（导致验证页面无法唤回 App）
*   **发现**：`Info.plist` 中没有定义 `CFBundleURLTypes`。
*   **后果**：验证成功后的网页尝试执行 `window.location.href = "smivo://auth/callback"`，但系统不认识 `smivo://` 协议，导致报错或无反应。

### 问题 C：Web 端路由冲突（导致 404）
*   **发现**：`smivo.app` 部署在 GitHub Pages 上，使用的是 Flutter Web 的默认路由，不支持直接访问 `/listing/123` 这种物理路径。
*   **后果**：GitHub 服务器找不到该路径下的文件，返回 404 错误。

### 问题 D：认证重定向配置
*   **发现**：App 注册时请求的重定向地址为 `https://smivo.io/auth/callback`。
*   **后果**：如果 Supabase 后台的白名单没有包含该地址，或者 AASA 校验失败导致重定向被中断，用户会看到“无效地址”。（经查证，Supabase的Authentication的Redirect URLs中已经添加了https://smivo.io/auth/callback这个地址）

---

## 3. 修复建议与详细步骤

> [!IMPORTANT]
> 以下步骤需按顺序执行，部分修改涉及服务器，部分涉及 App 代码。

### 第一步：修正服务器 AASA 配置
修改 `website/.well-known/apple-app-site-association`：
*   将 `appID` 中的 `com.smivo` 更改为 **`com.smivo.app`**。
*   **修改后内容**：`"appID": "DKWKX97U49.com.smivo.app"`

### 第二步：修正 App 内部常量
修改 `app/lib/core/constants/app_constants.dart`：
*   将 `appBundleId` 从 `com.smivo` 更改为 **`com.smivo.app`**。

### 第三步：配置 iOS 自定义协议 (URL Scheme)
在 `app/ios/Runner/Info.plist` 中，在 `<dict>` 标签内添加以下内容：
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.smivo.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>smivo</string>
        </array>
    </dict>
</array>
```

### 第四步：修复 Web App 跳转路径 (兼容 Hash 路由)
修改 `website/api/listing.js` 中的跳转链接：
*   将 `https://smivo.app/listing/${esc(id)}` 
*   修改为：`https://smivo.app/#/listing/${esc(id)}` （在路径前添加 **`/#/`**）

### 第五步：同步 Supabase 后台设置
1. 登录 Supabase Dashboard。
2. 进入 **Authentication -> URL Configuration**。
3. 确保 `Redirect URLs` 中包含以下地址：
   * `https://smivo.io/auth/callback`
   * `smivo://auth/callback`

---

## 4. 验证方式
1. **重新构建 App**：修改 `Info.plist` 后，必须执行一次完全重新安装（`flutter run`），iOS 才会重新注册协议。
2. **部署 Web 端**：将 `website` 目录的修改推送到 Vercel。
3. **测试**：
   * 使用系统自带的 **Notes（备忘录）** 粘贴 `https://smivo.io/listing/xxx`，长按链接看是否有“在 Smivo 中打开”的选项。
   * 注册一个新账号，观察点击邮件链接后是否能顺利通过网页中转回到 App。
