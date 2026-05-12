# Phase 7: Consensus & Voting UI — Gemini Pro 执行指令

## ⛔ 边界
- **只能创建/修改**下方列出的文件
- **不得**修改数据库、现有 model/repository、pubspec.yaml、router.dart
- **不得**运行 `build_runner`
- 所有 Widget 使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`

## 📋 任务
实现拼车行程的提议与投票系统 UI：行程变更提议、全员确认、投票踢人。

## 📐 前置依赖
- `CarpoolProposal`, `CarpoolVote` model 可用
- `CarpoolRepository` 中已有：
  - `createProposal({tripId, proposerId, type, oldValue, newValue, targetUserId})`
  - `fetchProposals(tripId)` → `List<CarpoolProposal>`
  - `castVote(proposalId, voterId, vote)` → void（RPC 自动检查共识）

## 📁 需要创建的文件

### 1. `app/lib/features/carpool/providers/carpool_proposal_provider.dart`
```
@riverpod
class CarpoolProposals extends _$CarpoolProposals {
  // build(tripId) → fetchProposals(tripId)
  // createTimeChange(tripId, oldTime, newTime)
  // createLocationChange(tripId, type, oldAddr, newAddr)
  // createKickProposal(tripId, targetUserId)
  // vote(proposalId, vote)  // 'approve' | 'reject'
}
```

### 2. `app/lib/features/carpool/screens/carpool_proposals_screen.dart`
提议列表页面：
- AppBar 标题：「行程变更」
- 列表展示所有 proposals（按 created_at 降序）
- 每个 proposal 用 `ProposalCard` 展示
- FAB 按钮：发起新提议（弹出选择器：改时间/改出发地/改目的地）
- 空状态：「暂无变更提议」

### 3. `app/lib/features/carpool/widgets/proposal_card.dart`
提议卡片 Widget：
- Props: `CarpoolProposal proposal`, callbacks
- 显示内容：
  - 提议类型图标 + 文字（「修改出发时间」「修改目的地」「投票移除成员」）
  - 变更详情：旧值 → 新值（带箭头）
  - 投票进度条：`currentVotes / requiredVotes`
  - 状态标签：pending(蓝) / approved(绿) / rejected(红) / expired(灰)
  - 过期倒计时（如果 pending 且有 expiresAt）
- 底部操作：
  - pending 状态 → 「同意」/「反对」按钮（已投票则显示已投票状态）
  - 非 pending → 不显示按钮

### 4. `app/lib/features/carpool/widgets/create_proposal_sheet.dart`
创建提议底部弹窗 BottomSheet：
- 三个选项卡片：
  1. 「修改出发时间」→ 展开 DateTimePicker
  2. 「修改出发地点」→ 展开文本输入（或 MapLocationPicker）
  3. 「修改目的地」→ 同上
- 确认按钮提交提议
- 提交成功后关闭 sheet + SnackBar

### 5. `app/lib/features/carpool/widgets/kick_member_sheet.dart`
投票踢人底部弹窗：
- 显示成员列表（排除发起人自己）
- 每个成员一个 ListTile，点击选中
- 底部「发起投票移除」按钮
- 确认弹窗：「确定要发起投票移除 [Name] 吗？需要全员同意。」
- 提交成功后关闭 + SnackBar

### 6. `app/lib/features/carpool/widgets/vote_progress_bar.dart`
投票进度条 Widget：
- Props: `int current`, `int required`, `String status`
- 线性进度条 + 文字「2/3 已投票」
- 颜色随状态变化

## ✅ 完成报告
执行完成后，在 `docs/agent_tasks/phase7_report.md` 中写入：
1. 创建的文件列表和行数
2. 遇到的问题或假设
3. 是否偏离指令
