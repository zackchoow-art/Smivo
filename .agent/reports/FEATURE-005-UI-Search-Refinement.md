# 任务执行报告：UI 与搜索逻辑优化

**日期**: 2026-04-26
**分支**: `feature/theme-switching`

## 1. 任务背景与指令
用户提出了以下四项优化需求：
1. **ChatRoom 商品信息栏**：在聊天窗口靠上的位置增加一个当前商品信息栏，与 `chat-popup` 组件中的商品信息栏样式一致。
2. **Home页 头部用户信息优化**：将“未登录”改为英文 `"Not logged in"`；用户名、邮箱和 Verified 文本之间取消圆点分隔，改为更流行美观的层级排版；删除用户信息下方的一行说明文本。
3. **导航栏文本规范**：将底部导航栏的文字全大写字母改为首字母大写（Title Case）。
4. **扩展模糊搜索范围**：修改搜索框的搜索筛选内容，支持按产品名称、产品描述、卖家名称、单价、租金单价（日/周/月）进行模糊查询。

## 2. 执行过程

### 2.1 增加 ChatRoom 商品信息栏
* **文件修改**: `lib/features/chat/screens/chat_room_screen.dart`
* **执行细节**:
  * 引入了 `listing_detail_provider.dart`，利用现有的提供器，通过 `chatRoom` 关联的 `listingId` 获取包含价格等完整信息的商品数据。
  * 将 `chat-popup` 中的卡片 UI 结构（包含商品主图、标题截断和高亮价格）抽取并插入到 `messagesAsync` 列表上方的 `body: Column` 中，形成固定的顶部商品预览条。
  * 修复了分析工具报出的 `radius` 缺少定义的错误，补全了 `final radius = context.smivoRadius;`。

### 2.2 优化 Home 页面头部
* **文件修改**: `lib/features/home/widgets/home_header.dart`
* **执行细节**:
  *移除了提示语 `'The digital pulse of your university. Buy, sell, and connect.'`。
  * 重构了 `profile != null` 时的布局：使用 `Column` 包裹 `Row`，使大号粗体的 `displayName` 位于顶部，并在其右侧添加浅绿色背景、深绿色粗体文字和带对勾的 `Verified` 徽章标签；邮箱地址以小号次级颜色显示在下方。
  * 未登录状态下，将文字修改为 `'Not logged in'`。

### 2.3 底部导航栏标签规范化
* **文件修改**: `lib/shared/widgets/bottom_nav_bar.dart`
* **执行细节**: 
  * 将 `label` 参数的值从 `'HOME'`、`'CHAT'`、`'POST'`、`'ORDERS'` 分别修改为 `'Home'`、`'Chat'`、`'Post'`、`'Orders'`。

### 2.4 扩展全局模糊搜索支持
* **文件修改**: `lib/data/repositories/listing_repository.dart`
* **执行细节**:
  * 鉴于 Postgrest 中 `.or` 对外键表嵌套条件（如卖家姓名）支持受限，且当前应用会在初始化时拉取所有 active 商品进行分页/展示，修改了 `searchListings` 的执行方式。
  * 将数据库查询从依赖后端的有限条件过滤改为：首先向数据库拉取包含完整 `seller` 信息的活跃列表，然后在 Dart 层基于用户输入的查询字符串（小写）进行多字段（标题、描述、卖家名、价格、日/周/月租金）的全匹配（`contains`）。
  * 这种方式完全匹配了“模糊查询”的需求，并成功涵盖了数值型字段和外键表字段。

## 3. 执行结果
* 所有代码已通过 `flutter analyze` 的静态检查，无任何语法或未处理状态的错误。
* 修改已提交至本地仓库（Commit: `"feat: refine chat, home header, search and nav labels"`），并推送至远程 `feature/theme-switching` 分支。
