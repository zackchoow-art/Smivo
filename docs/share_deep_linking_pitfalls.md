# Share & Deep Linking Pitfalls

> 本文档记录了 Smivo 分享链接、OG 预览卡、深度链接实现中遇到的所有坑。
> 最后更新：2026-05-07

---

## 1. Supabase 项目迁移后的隐形断裂

### 现象
分享链接打开后显示默认标题 "Check out this item on Smivo"，没有商品数据。

### 根因
`website/` 目录中的 API 文件硬编码了**旧 Supabase 项目**的凭证和表结构，而 `app/` 和 `admin/` 早已迁移到新项目。

### 涉及的不匹配项

| 项目 | 旧值 | 新值 |
|------|------|------|
| Supabase URL | `cpavunhkwsrmomhktklb.supabase.co` | `sztrbkfdcldwaifjkkol.supabase.co` |
| Anon Key | 旧项目 JWT | `sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj` |
| 图片排序列名 | `display_order` | `sort_order` |
| 交易类型列名 | `rental_type` | `transaction_type` |
| 交易类型枚举值 | `rent` | `rental` |

### 教训
- **迁移 Supabase 项目时，必须全仓搜索旧 URL 和旧列名**
- `website/` 因为是静态项目，容易被遗忘
- 使用 `grep -r "旧URL" .` 确认没有遗漏

---

## 2. Vercel 静态项目不支持 `.jsx` 文件作为 Serverless Function

### 现象
`/api/og` 返回 404，但 `/api/listing` 正常。

### 根因
Vercel 在**没有 framework**（如 Next.js）的静态项目中，只识别 `.js` 和 `.ts` 文件作为 Serverless / Edge Function。`.jsx` 和 `.tsx` 需要框架来转译。

### 后续问题
即使重命名为 `og.js`，`import { ImageResponse } from '@vercel/og'` 也失败了 — `@vercel/og` 依赖在静态项目的 Edge Function 环境中不可用。

### 更多的坑
当 `og.js` 和 `og.jsx` 同时存在时，Vercel 构建报错：
```
Error: Two or more files have conflicting paths or names.
The path "api/og.js" has conflicts with "api/og.jsx".
```

### 教训
- **在 Vercel 静态项目中，只使用 `.js` 或 `.ts` 扩展名**
- **不要依赖 `@vercel/og`** — 它在非 Next.js 项目中不可用
- 如果需要动态图片，用图片代理（`/api/img.js`）转发 CDN 图片
- 删除旧文件后一定确认没有同名冲突

---

## 3. 微信分享不显示图片预览（最大的坑）

### 现象
iMessage 分享正常显示图片，微信分享始终无图。

### 尝试过的无效方案

1. **通过 Edge Function 代理图片**（`/api/img?url=...`）→ 无效
   - 微信不喜欢带查询参数的图片 URL
2. **用静态路径伪装**（`/listing/:id/image.jpg`）→ 无效
   - Vercel rewrite 增加了延迟（DB 查询 + 图片代理），微信爬虫超时
3. **添加 `itemprop="image"` 标签**→ 无效
   - 这不是标签缺失的问题
4. **`@vercel/og` 动态生成小卡片**→ 无效
   - 包在 Vercel 静态项目中不可用

### 真正的根因（两层）

**第一层：Flutter 分享文本包含额外文字**

```dart
// 之前（无效）
text: 'Check out Food for $15 on Smivo!\n\nhttps://smivo.io/listing/xxx'

// 之后（有效）
text: 'https://smivo.io/listing/xxx'
```

当消息中包含 **URL + 额外文字** 时，微信将整段内容作为**纯文本**发送，**不会抓取 URL 生成富链接预览**。只有消息内容**仅为一个 URL** 时，微信才会生成带图片的卡片。

**第二层：隐藏预览图兜底**

在 HTML body 顶部添加一个隐藏的 `<img>` 标签，作为微信爬虫的额外抓取源：
```html
<div style="display:none;"><img src="产品图URL" alt="preview"></div>
```

### 教训
- **分享时只发纯 URL**，不要附加任何文字
- 微信的 OG 抓取行为和 iMessage/Twitter 完全不同
- 微信对同一域名有缓存，测试时必须用**没分享过的新链接**
- 添加隐藏 `<img>` 标签是微信的通用兜底方案

---

## 4. iPad 分享崩溃

### 现象
iPad 上点击分享按钮后 App 崩溃。

### 根因
iPad 的 `UIActivityViewController` 必须以 Popover 形式展示，需要提供 `sourceRect`（锚点位置）。`SharePlus.instance.share()` 不支持传递 `sharePositionOrigin`。

### 修复
```dart
// 使用 Share.share() 并提供锚点
final box = context.findRenderObject() as RenderBox?;
Share.share(
  listingUrl,
  sharePositionOrigin: box != null
      ? box.localToGlobal(Offset.zero) & box.size
      : null,
);
```

### 教训
- **iPad 上所有 share sheet 都必须提供 `sharePositionOrigin`**
- `SharePlus.instance.share(ShareParams(...))` 和 `Share.share(...)` 是两个不同的 API
- 测试分享功能时**必须同时测 iPad**

---

## 5. 深度链接（Universal Links）不生效

### 现象
用户点击分享链接后打开浏览器，而非直接唤起 App。

### 涉及的问题

1. **URL Scheme 错误**：`listing.html` 中使用了 `com.smivo://` 而非 `smivo://`
2. **AASA 缓存**：iOS 会缓存 Apple-App-Site-Association 文件，修改后不会立即生效
3. **Bundle ID**：必须确认 AASA 中的 `appID` 与 Xcode 项目的 Bundle ID 一致（`com.smivo.app`）

### 修复
- 修正 URL Scheme 为 `smivo://`
- 确认 `website/.well-known/apple-app-site-association` 中的配置正确

### 刷新 AASA 缓存的步骤
1. 从设备上**删除 App**
2. **重启 iPhone**（iOS 会在开机时重新拉取 AASA）
3. 重新安装 App（`flutter run` 或从 App Store）
4. 等待 5-10 分钟让系统完成 AASA 验证

### 教训
- **iOS 的 AASA 缓存极其顽固**，不删除 App + 重启无法强制刷新
- URL Scheme 的值（`smivo://`）和 Bundle ID（`com.smivo.app`）是两个独立配置
- 测试深度链接时，使用 Apple 的 [AASA 验证工具](https://app-site-association.cdn-apple.com/a/v1/你的域名)

---

## 6. Chat 弹窗键盘遮挡输入框

### 现象
在聊天弹窗中输入消息时，软键盘弹起后遮住了输入框。

### 根因
弹窗布局未正确处理 `MediaQuery.of(context).viewInsets.bottom`（键盘高度）。

### 教训
- 所有包含输入框的弹窗/浮层都必须监听 `viewInsets` 并动态调整布局
- 测试时必须在**真机**上用实体键盘测试，模拟器的虚拟键盘行为可能不同

---

## 7. Vercel 部署的注意事项（website/）

### 项目结构
```
website/
├── api/
│   ├── listing.js    ← Edge Function (商品分享页)
│   └── img.js        ← Edge Function (图片代理)
├── vercel.json       ← URL 重写规则
├── package.json      ← 极简，无 framework
└── .well-known/      ← AASA + assetlinks.json
```

### Vercel Rewrite 规则
```json
{
  "rewrites": [
    { "source": "/listing/:id/image.jpg", "destination": "/api/img?id=:id" },
    { "source": "/listing/:id", "destination": "/api/listing?id=:id" }
  ]
}
```

**注意**：更具体的路由必须放在前面（`/listing/:id/image.jpg` 在 `/listing/:id` 之前），否则通配规则会先匹配。

### 环境变量
Supabase 凭证直接写在 `listing.js` 和 `img.js` 中（public anon key，非敏感）。
如果迁移 Supabase 项目，**必须同时更新 website/ 中的所有文件**。

---

## 快速排查清单

遇到分享问题时按此顺序排查：

- [ ] Supabase URL 和 Anon Key 是否是当前项目的？
- [ ] 数据库列名是否与当前 schema 一致？（用 `select *` 验证）
- [ ] `flutter run` 后 App 中的分享文本是否只有纯 URL？
- [ ] Vercel 部署是否成功？（检查 Vercel Dashboard 构建日志）
- [ ] `curl -sL "https://smivo.io/listing/<id>" | grep og:image` 是否返回正确图片 URL？
- [ ] 图片 URL 是否可直接访问？（`curl -sL -o /dev/null -w "%{http_code}" "<图片URL>"`）
- [ ] 测试微信时是否使用了**之前没分享过的新链接**？
- [ ] iPad 测试时分享是否提供了 `sharePositionOrigin`？
- [ ] 深度链接测试前是否删除了 App 并重启了设备？
