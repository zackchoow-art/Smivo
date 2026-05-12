# Phase 7: 投票与提案 UI — Gemini Pro 执行指令

## 身份

你是 Gemini Pro，负责 Smivo 拼车模块的 **投票与提案 UI** 实现。

## 边界（严格遵守）

### ✅ 你可以做

- 在 `app/lib/features/carpool/providers/` 下新建文件
- 在 `app/lib/features/carpool/screens/` 下新建文件
- 在 `app/lib/features/carpool/widgets/` 下新建文件

### 🚫 你不可以做

- 修改 `app/lib/core/router/router.dart`
- 修改 `app/lib/data/repositories/` 下的任何文件
- 修改 `app/lib/data/models/` 下的任何文件
- 修改任何 `pubspec.yaml`
- 修改 `supabase/` 下的任何文件
- 修改非 carpool feature 目录下的任何文件
- 安装新的依赖包

---

## 背景

### 已完成的基础设施

1. **数据模型**：`CarpoolProposal` 和 `CarpoolVote`（freezed，已 build_runner 生成）
2. **Repository 方法**（在 `carpool_repository.dart` 中）：
   - `createProposal(...)` → 创建提案并返回 `CarpoolProposal`
   - `fetchProposals(tripId)` → 获取行程的所有提案列表
   - `castVote(proposalId, voterId, vote)` → 调用 `cast_carpool_vote` RPC 投票
3. **RPC `cast_carpool_vote`**：原子操作 — 检查重复投票 → 插入 vote → 递增 current_votes → 达标时自动 resolve proposal
4. **CarpoolProposal 字段**：
   - `proposalType`: `'kick_member'` | `'change_time'` | `'change_departure'` | `'change_destination'`
   - `oldValue` / `newValue`: 变更前后的值（ISO-8601 时间 或 地址字符串）
   - `targetUserId`: 仅 kick_member 使用
   - `status`: `'pending'` | `'approved'` | `'rejected'` | `'expired'`
   - `requiredVotes` / `currentVotes`: 投票进度
   - `expiresAt`: 过期时间

### 你可以引用的已有 Provider

- `carpoolRepositoryProvider` — Repository 实例
- `supabaseClientProvider` — 获取 `currentUser?.id`
- `carpoolTripDetailProvider(tripId)` — 获取行程详情（含 members 列表）
- `profileProvider` — 获取当前用户 Profile

### 你可以引用的已有 Widget

- `SmivoUserAvatar` — `import 'package:smivo/shared/widgets/smivo_user_avatar.dart'`
  - 构造函数：`SmivoUserAvatar({required UserProfile user, double radius, bool enableTap})`
  - **不要**使用 `AvatarWidget`，它不存在

---

## 需要创建的文件

### 1. Provider: `carpool_proposals_provider.dart`

```
文件路径: app/lib/features/carpool/providers/carpool_proposals_provider.dart
```

包含两个 @riverpod Provider：

#### `TripProposals`（AsyncNotifierProvider）
- `build(String tripId)`: 调用 `carpoolRepositoryProvider.fetchProposals(tripId)` 返回 `List<CarpoolProposal>`
- `createProposal(...)` 方法: 
  - 入参：tripId, proposalType, requiredVotes, oldValue?, newValue?, targetUserId?, expiresAt?
  - 调用 `carpoolRepositoryProvider.createProposal(...)`
  - 成功后 `ref.invalidateSelf()` 刷新列表
  - 使用 try/catch 包裹，catch 中 debugPrint 错误并 rethrow

#### `CastVote`（AsyncNotifierProvider）
- `build()`: 返回 `void`（空初始状态）
- `castVote({required String proposalId, required String vote})` 方法:
  - 获取 `currentUser.id` 作为 voterId
  - 调用 `carpoolRepositoryProvider.castVote(proposalId, voterId, vote)`
  - 成功后 invalidate `tripProposalsProvider` 让列表刷新
  - vote 值: `'approve'` 或 `'reject'`

### 2. Widget: `proposal_card.dart`

```
文件路径: app/lib/features/carpool/widgets/proposal_card.dart
```

一个 `ConsumerWidget`，展示单个提案卡片。

**Props:**
- `CarpoolProposal proposal` — 提案数据
- `String currentUserId` — 当前用户 ID
- `List<CarpoolMember> members` — 行程成员列表（用于获取踢人目标的名字）

**UI 布局:**
- Card 形式，包含:
  1. **提案类型标题** — 根据 `proposalType` 显示中文：
     - `kick_member` → "踢出成员: [targetUser的displayName]"（从 members 列表中通过 targetUserId 查找）
     - `change_time` → "修改出发时间"
     - `change_departure` → "修改出发地点"
     - `change_destination` → "修改目的地点"
  2. **变更内容**（仅非 kick_member）：
     - "原来: [oldValue]"
     - "改为: [newValue]"
  3. **投票进度条** — `LinearProgressIndicator(value: currentVotes / requiredVotes)`
  4. **投票计数文本** — "${proposal.currentVotes}/${proposal.requiredVotes} 票"
  5. **状态 chip**：
     - pending → 蓝色 "投票中"
     - approved → 绿色 "已通过"
     - rejected → 红色 "已拒绝"
     - expired → 灰色 "已过期"
  6. **操作按钮**（仅当 status == 'pending' 且 currentUserId != proposerId 时显示）:
     - "赞成" ElevatedButton → 调用 `ref.read(castVoteProvider.notifier).castVote(proposalId: proposal.id, vote: 'approve')`
     - "反对" OutlinedButton → 同上，vote: 'reject'

**注意事项:**
- 已投票状态的判断：MVP 阶段不需要在 UI 检查，RPC 会在数据库层拒绝重复投票并抛 DatabaseException，UI 捕获后显示 SnackBar "您已投过票"
- `members` 列表中每个 `CarpoolMember` 有 `user` 字段（`UserProfile?` 类型），可用 `member.user?.displayName` 获取名字

### 3. Screen: `trip_proposals_screen.dart`

```
文件路径: app/lib/features/carpool/screens/trip_proposals_screen.dart
```

一个 `ConsumerWidget` 全屏页面。

**Props:**
- `String tripId` — 行程 ID

**UI 布局:**
- AppBar: "提案与投票"
- Body:
  1. 监听 `ref.watch(tripProposalsProvider(tripId))`
  2. 同时监听 `ref.watch(carpoolTripDetailProvider(tripId))` 获取 members 列表
  3. 使用 `AsyncValue.when` 处理 loading/error/data
  4. data 为空时显示空状态：图标 + "暂无提案"
  5. 有数据时使用 `ListView.separated` 渲染 `ProposalCard` 列表
- FAB: FloatingActionButton (icon: add)，点击弹出 `_CreateProposalSheet`

#### `_CreateProposalSheet`（私有 StatefulWidget，在同一文件内）

底部弹窗，用于创建新提案。

**UI:**
1. **提案类型下拉菜单** — DropdownButtonFormField：
   - kick_member → "踢出成员"
   - change_time → "修改出发时间"
   - change_departure → "修改出发地点"
   - change_destination → "修改目的地点"
2. **动态表单**（根据类型切换）：
   - kick_member → 成员选择下拉菜单（从 members 中过滤掉 creator 和自己，显示 displayName）
   - change_time → 两个日期时间选择器（oldValue 自动填充当前出发时间，newValue 由用户选择）
   - change_departure / change_destination → 两个 TextFormField（old 自动填充，new 由用户输入）
3. **"提交提案"按钮** — 点击后:
   - requiredVotes = (成员数 - 1)（全员共识，排除提案人自己）
   - expiresAt = DateTime.now() + 24小时
   - 调用 `ref.read(tripProposalsProvider(tripId).notifier).createProposal(...)`
   - 成功后 Navigator.pop + SnackBar("提案已提交")

---

## 代码风格

1. 所有 Widget 继承 `ConsumerWidget` 或 `ConsumerStatefulWidget`
2. 使用 `ref.watch` 读取 async state，使用 `AsyncValue.when` 渲染 loading/error/data
3. 注释用英文写，UI 文案用中文
4. 使用 `@riverpod` 注解生成 provider（不要手写 Provider）
5. 不使用 `withOpacity()`，改用 `withValues(alpha: 0.x)`
6. 不使用 `AvatarWidget`，使用 `SmivoUserAvatar`
7. import 顺序: dart → package → relative（用空行分隔）

## 生成代码

完成所有文件后，运行:
```bash
cd app && flutter pub run build_runner build
```

## 验证

运行:
```bash
cd app && flutter analyze lib/features/carpool/
```
确保 0 errors，0 warnings。infos 可以接受。

## 完成报告

将报告写入 `docs/agent_tasks/phase7_report.md`，包含:
1. 创建的文件列表和行数
2. 遇到的问题或假设
3. 占位代码说明
4. 是否偏离指令
