# Task: Convert All Chinese Text to English in Carpool Module

## Objective

Replace **ALL Chinese text** (UI strings, comments, SnackBar messages, labels,
hints, dialog content, doc comments) with natural English equivalents in the
carpool feature module. The app's user base is English-speaking college students.

## Scope — Files to Modify

You must process every `.dart` file listed below. **Skip** any `.g.dart` and
`.freezed.dart` files — those are auto-generated and must NOT be touched.

### Providers (7 files)
1. `app/lib/features/carpool/providers/carpool_detail_provider.dart`
2. `app/lib/features/carpool/providers/carpool_lifecycle_provider.dart`
3. `app/lib/features/carpool/providers/carpool_list_provider.dart`
4. `app/lib/features/carpool/providers/carpool_members_provider.dart`
5. `app/lib/features/carpool/providers/carpool_proposals_provider.dart`
6. `app/lib/features/carpool/providers/carpool_trips_provider.dart`
7. `app/lib/features/carpool/providers/create_carpool_provider.dart`
8. `app/lib/features/carpool/providers/group_chat_provider.dart`

### Screens (6 files)
9. `app/lib/features/carpool/screens/arrival_confirmation_screen.dart`
10. `app/lib/features/carpool/screens/carpool_detail_screen.dart`
11. `app/lib/features/carpool/screens/carpool_list_screen.dart`
12. `app/lib/features/carpool/screens/create_carpool_screen.dart`
13. `app/lib/features/carpool/screens/group_chat_screen.dart`
14. `app/lib/features/carpool/screens/trip_proposals_screen.dart`

### Widgets (9 files)
15. `app/lib/features/carpool/widgets/calendar_sync_button.dart`
16. `app/lib/features/carpool/widgets/carpool_trip_card.dart`
17. `app/lib/features/carpool/widgets/group_member_sheet.dart`
18. `app/lib/features/carpool/widgets/group_message_bubble.dart`
19. `app/lib/features/carpool/widgets/legal_disclaimer_dialog.dart`
20. `app/lib/features/carpool/widgets/member_avatar_row.dart`
21. `app/lib/features/carpool/widgets/proposal_card.dart`
22. `app/lib/features/carpool/widgets/review_batch_sheet.dart`
23. `app/lib/features/carpool/widgets/seat_indicator.dart`

**Total: 23 files.**

## Rules

### 1. What to Translate

- **UI strings**: `Text('中文')`, `SnackBar(content: Text('中文'))`, `hintText`, `labelText`, `title`, `subtitle`, `tooltip`, dialog content, alert messages — all user-visible text.
- **Code comments**: `// 中文注释` → `// English comment`. Both line comments and doc comments (`///`).
- **AppBar titles**: e.g. `AppBar(title: Text('拼车广场'))` → `AppBar(title: Text('Carpool'))`.

### 2. What NOT to Change

- **Do NOT modify any logic, imports, variable names, function signatures, or widget structure.**
- **Do NOT rename any files or classes.**
- **Do NOT add, remove, or reorder any code.**
- **Do NOT touch `.g.dart` or `.freezed.dart` files.**
- **Do NOT modify files outside the list above.**
- Keep existing English comments as-is (they are already correct).
- Keep comment markers (TODO, FIXME, NOTE, HACK) — only translate the description.

### 3. Translation Style Guide

| Chinese | English |
|---------|---------|
| 拼车 | Carpool / Ride Share |
| 拼车广场 | Carpool |
| 发布拼车 | Post a Ride |
| 出发地点 | Departure Location |
| 目的地点 | Destination |
| 出发时间 | Departure Time |
| 座位数 | Seats |
| 行李限额 | Luggage Limit |
| 不限 | No Limit |
| 仅小包 | Small Bags Only |
| 中等行李 | Medium Luggage |
| 大件行李 | Large Luggage OK |
| 审核模式 | Approval Mode |
| 自动接受申请 | Auto-approve requests |
| 手动审核申请 | Manual approval |
| 截止报名时间 | Registration Deadline |
| 备注 | Notes |
| 选填 | Optional |
| 必填 | Required |
| 发布成功 | Posted successfully |
| 重试 | Retry |
| 提案与投票 | Proposals & Voting |
| 发起新提案 | New Proposal |
| 提案类型 | Proposal Type |
| 修改出发时间 | Change Departure Time |
| 修改出发地点 | Change Departure Location |
| 修改目的地点 | Change Destination |
| 踢出成员 | Remove Member |
| 投票中 | Voting |
| 已通过 | Approved |
| 已拒绝 | Rejected |
| 已过期 | Expired |
| 赞成 | Approve |
| 反对 | Reject |
| 票 | votes |
| 提交提案 | Submit Proposal |
| 选择成员 | Select Member |
| 当前 | Current |
| 改为 | Change to |
| 原来 | Previous |
| 选择新时间 | Select New Time |
| 新地点 | New Location |
| 暂无 | None yet |
| 评价同行者 | Rate Fellow Riders |
| 提交评价 | Submit Reviews |
| 写点评价 | Write a review |
| 可选 | Optional |
| 未知用户 / 未知成员 | Unknown User |
| 角色身份 | Your Role |
| 我是司机 | I'm the Driver |
| 我是发起人（找人分摊）| I'm Organizing (splitting cost) |
| 路线信息 | Route |
| 行程细节 | Trip Details |
| 拼车免责声明 | Carpool Disclaimer |
| 同意并发布 | Agree & Post |
| 取消 | Cancel |
| 加载失败 | Failed to load |
| 投票失败 | Vote failed |
| 已投赞成票 | Voted to approve |
| 已投反对票 | Voted to reject |
| 提案已提交 | Proposal submitted |
| 提交失败 | Submission failed |
| 评价已提交 | Reviews submitted |
| 添加到日历 | Add to Calendar |
| 校园拼车行程 | Campus carpool trip |
| 校园拼车免责声明 | Campus Carpool Disclaimer |
| 同意并继续 | Agree & Continue |
| 不同意 | Decline |
| 暂无拼车信息，快来发布第一个吧！| No carpool rides yet. Be the first to post one! |

Use natural, casual English appropriate for a college student audience.
If a string is not in the table above, translate it yourself using the same tone.

### 4. Verification

After completing ALL 23 files:

1. Run: `cd app && flutter analyze lib/features/carpool/`
2. Confirm: **"No issues found!"**
3. Run: `cd app && grep -rn '[\u4e00-\u9fff]' lib/features/carpool/ --include="*.dart" --exclude="*.g.dart" --exclude="*.freezed.dart"`
4. Confirm: **zero results** (no remaining Chinese characters)

If either check fails, fix the issues before reporting.

## Deliverables

1. All 23 files modified in-place (no new files created).
2. Write your execution report to: `docs/agent_tasks/localize_carpool_report.md`
   - List every file you modified
   - Confirm both verification checks passed
   - Note any translation decisions that were ambiguous

## Important Reminders

- **Read each file fully** before editing. Understand the context.
- **Do NOT change any Dart code logic.** This is a text-only operation.
- Work file by file. Do not try to batch-edit across files.
- If a file has zero Chinese characters, skip it and note in the report.
- Git commit message format: `chore(carpool): localize all Chinese text to English`
