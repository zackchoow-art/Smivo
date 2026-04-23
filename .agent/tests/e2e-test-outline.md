# Smivo 全功能端到端测试大纲

## 测试环境

| 设备 | 账号 | 角色 |
|------|------|------|
| iPhone 17 Pro | test1@smivo.dev | 卖家（创建商品） |
| iPhone Air | test2@smivo.dev | 买家（浏览/下单） |

**前提**：两个模拟器均已登录，数据已通过 `reset_test_data.sql` 清空。

---

## 测试流程

### Phase 1: 卖家发布商品 (test1, iPhone 17 Pro)

#### T01: 创建销售商品
1. 点击首页底部 "+" 按钮进入创建页面
2. 填写：
   - Title: "IKEA Desk Lamp"
   - Description: "Great condition, barely used"
   - Category: furniture
   - Transaction Type: Sale
   - Price: $25
   - Condition: like_new
3. 添加 1-2 张照片（可用模拟器相册图片）
4. 选择 Pickup Location（如果有的话，否则跳过）
5. 点击 Submit
6. **验证**：
   - [ ] 商品创建成功，跳转回首页
   - [ ] 首页 feed 中能看到新商品
   - [ ] 商品卡片显示正确的图片、标题、价格

#### T02: 创建租赁商品
1. 再次进入创建页面
2. 填写：
   - Title: "Canon Camera EOS R5"
   - Description: "Perfect for photography class"
   - Category: electronics
   - Transaction Type: Rental
   - Daily Price: $15
   - Weekly Price: $80
   - Monthly Price: $250
   - Deposit: $200
3. 添加照片
4. 提交
5. **验证**：
   - [ ] 商品创建成功
   - [ ] 首页可见，显示为租赁类型

---

### Phase 2: 买家浏览与互动 (test2, iPhone Air)

#### T03: 浏览与搜索
1. 刷新首页，查看 test1 发布的两个商品
2. 使用搜索栏搜索 "Desk"
3. 使用 Category filter 选择 "furniture"
4. **验证**：
   - [ ] 商品列表正确显示
   - [ ] 搜索结果正确过滤
   - [ ] Category 筛选正常工作

#### T04: 商品详情页（销售商品）
1. 点击 "IKEA Desk Lamp" 进入详情
2. 检查页面内容：
   - [ ] 图片轮播正常，可滑动
   - [ ] 标题、价格、描述正确
   - [ ] 成色标签显示 "LIKE NEW"
   - [ ] 卖家信息卡片显示 test1 的头像和名字
   - [ ] 只有一组返回按钮（不重叠）
3. 点击收藏/书签按钮
4. **验证**：
   - [ ] 收藏成功，图标变为实心

#### T05: 商品详情页（租赁商品）
1. 返回首页，点击 "Canon Camera" 进入详情
2. 检查租赁选项区域：
   - [ ] 显示 Daily / Weekly / Monthly 价格
   - [ ] 可选择日期范围
   - [ ] Deposit 金额显示正确
   - [ ] 总价计算正确

---

### Phase 3: 聊天功能

#### T06: 买家发起聊天 (test2)
1. 在商品详情页点击 "Message" 按钮
2. 发送文字消息: "Hi, is this still available?"
3. **验证**：
   - [ ] 聊天界面正常打开
   - [ ] 消息发送成功，显示在对话中

#### T07: 卖家回复 (test1, iPhone 17 Pro)
1. 检查底部导航栏 Chat tab 的 badge 数字
2. 进入 Chat 列表，看到来自 test2 的对话
3. 打开对话，回复: "Yes, it's available!"
4. **验证**：
   - [ ] Chat badge 显示未读数
   - [ ] 消息实时到达
   - [ ] 聊天列表显示最新消息预览

#### T08: 聊天图片发送 (test2)
1. 在聊天中尝试发送一张图片
2. **验证**：
   - [ ] 图片上传成功，显示在对话中
   - [ ] 无 "Bucket not found" 错误

---

### Phase 4: 销售订单全流程

#### T09: 买家提交订单 (test2)
1. 进入 "IKEA Desk Lamp" 详情页
2. 点击 "Buy Now" / 购买按钮
3. 确认订单提交
4. **验证**：
   - [ ] 订单提交成功弹窗/提示
   - [ ] 返回详情页，按钮变为 "Application Submitted" 卡片
   - [ ] 卡片显示日期和时间（精确到分钟）

#### T10: 卖家查看通知 (test1)
1. 检查首页右上角铃铛 🔔 badge
2. 点击铃铛进入通知中心
3. **验证**：
   - [ ] 显示 "New order received" 通知
   - [ ] 通知有 📦 图标
   - [ ] 未读蓝色圆点可见
   - [ ] 点击通知跳转到订单详情

#### T11: 卖家接受订单 (test1)
1. 进入订单详情（从通知跳转或从 Orders Hub → Seller Center）
2. 点击 "Accept" 按钮
3. **验证**：
   - [ ] 订单状态变为 Confirmed
   - [ ] test2 收到 "Order accepted" 通知

#### T12: 买家确认取货 (test2)
1. 进入 Orders Hub → Buyer Center → Active
2. 找到该订单，点击进入订单详情
3. 可选：上传 1-2 张证据照片
4. 点击 "Confirm Pickup" 按钮
5. **验证**：
   - [ ] 订单状态变为 Completed
   - [ ] 两方都收到 "Order completed" 通知
   - [ ] Cancel 按钮不再显示

---

### Phase 5: 租赁订单全流程

#### T13: 买家提交租赁订单 (test2)
1. 进入 "Canon Camera" 详情页
2. 选择租赁日期和费率
3. 提交租赁申请
4. **验证**：
   - [ ] 订单提交成功
   - [ ] "Application Submitted" 卡片显示

#### T14: 卖家接受租赁 (test1)
1. 从通知或 Seller Center 进入订单
2. 接受订单
3. **验证**：
   - [ ] 状态变为 Confirmed

#### T15: 双方确认交付 (两台设备)
1. **test1 (卖家)**：进入订单详情，点击 "Confirm Delivery"
2. **test2 (买家)**：进入订单详情，点击 "Confirm Delivery"
3. **验证**：
   - [ ] 双方都确认后，rental_status 变为 Active
   - [ ] 订单 status 仍为 Confirmed（不是 completed）
   - [ ] Cancel 按钮已隐藏

#### T16: 租赁归还流程
1. **test2 (买家)**：点击 "Request Return"
2. **test1 (卖家)**：点击 "Confirm Return"
3. **test1 (卖家)**：点击 "Refund Deposit"
4. **验证**：
   - [ ] rental_status 依次变为 return_requested → returned → deposit_refunded
   - [ ] 最终 status 变为 Completed

---

### Phase 6: 卖家管理功能

#### T17: 交易管理页 (test1)
1. 进入任一自己发布的商品详情
2. 点击 "Manage Transactions"
3. 检查三个 Tab：
   - [ ] **Views**: 显示浏览记录（test2 的浏览应被记录）
   - [ ] **Saves**: 显示 test2 的收藏记录
   - [ ] **Orders**: 显示所有订单及状态
4. 在 Orders tab 中，点击 💬 图标
5. **验证**：
   - [ ] 跳转到与该买家的聊天界面

#### T18: 卖家中心 (test1)
1. 进入 Orders Hub → Seller Center
2. **验证**：
   - [ ] Active Listings 区显示两个商品
   - [ ] 每个商品显示 view count
   - [ ] Completed Sales 区显示已完成的订单

#### T19: 买家中心 (test2)
1. 进入 Orders Hub → Buyer Center
2. **验证**：
   - [ ] Requested / Active / History 三个区域正确分类
   - [ ] 状态标签 (Pending/Active/Done) 正确

---

### Phase 7: 通知 & 设置

#### T20: 通知中心完整性
1. 在两个设备上点击铃铛
2. **验证**：
   - [ ] 所有交易通知都已记录
   - [ ] 点击 "Mark All Read" 后所有通知变灰
   - [ ] Badge 数字归零

#### T21: 设置页面 (任一设备)
1. 点击头像进入设置
2. 浏览各设置项：
   - [ ] Edit Profile 可进入
   - [ ] Notification Settings 可进入
   - [ ] Help 可进入
   - [ ] System Settings 可进入
   - [ ] Logout 正常工作（可选测试）

---

### Phase 8: 取消订单测试

#### T22: 取消订单 (创建新订单专门测试)
1. **test2**：对任一商品下新订单
2. **test2 或 test1**：在订单 pending 状态时点击 "Cancel Order"
3. **验证**：
   - [ ] 订单状态变为 Cancelled
   - [ ] 双方收到取消通知
   - [ ] Cancelled 订单不显示 Cancel 按钮

---

## 测试报告格式

测试完成后，将结果写入 `.agent/reports/e2e-test-report.md`，格式：

```markdown
# E2E Test Report — [日期]

## Summary
- Total: XX tests
- Passed: XX
- Failed: XX
- Blocked: XX

## Failures
### [Test ID]: [Test Name]
- **Expected**: ...
- **Actual**: ...
- **Screenshot**: (如果能截图)
- **Severity**: Critical / Major / Minor

## Notes
...
```
