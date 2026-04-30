# SMIVO 数据字典模块规范

> **文档定位**:Smivo 数据字典模块的工程规范。让运营人员自助管理 App 各处的可选项(商品分类、提货地点、举报原因等),无需程序员发版。
>
> **配套文档**:
> - `04_ADMIN_WEB_SPEC.md` §16(Admin Web 中数据字典的 UI)

---

## 1. 设计哲学

### 1.1 核心价值

> **让运营改业务规则不用程序员发版**。

### 1.2 范围界定

**该字典化的字段**:
- 商品分类(listing_category)
- 提货地点(pickup_location)
- 物品成色(item_condition)
- 举报原因(report_reason)
- 用户标签(user_tag)
- 反馈标签(feedback_tag)

**不该字典化的字段**(代码逻辑硬依赖):
- 订单状态(pending/shipped/delivered)
- 用户角色(super_admin/moderator)
- 审核优先级(urgent/normal/low)
- 审核状态(pending_review/approved)

**判断标准**:改了这个值是否**只影响显示**?是 → 字典化;否 → 硬编码。

### 1.3 关键约束

- **扁平结构**(不支持父子层级)— 决策已锁定
- **只能停用不能删除** — 保护历史数据
- **code 创建后不建议修改** — 历史数据按 code 引用
- **多语言预留** — 当前仅英文,中文字段保留供未来启用

---

## 2. 数据库 Schema

### 2.1 dict_categories(字典分类)

```sql
CREATE TABLE dict_categories (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code            text UNIQUE NOT NULL,           -- 'listing_category'
  name_en         text NOT NULL,                  -- 'Listing Category'
  name_zh         text,                            -- '商品分类'(预留)
  description     text,                            -- 给 admin 看的说明
  is_system       boolean DEFAULT false,           -- 系统级保护(不允许停用整个字典)
  display_order   int DEFAULT 0,
  is_active       boolean DEFAULT true,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now(),
  created_by      uuid REFERENCES user_profiles(id)
);
CREATE INDEX idx_dict_categories_code ON dict_categories(code) WHERE is_active = true;
```

### 2.2 dict_items(字典项)

```sql
CREATE TABLE dict_items (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  dict_code       text NOT NULL REFERENCES dict_categories(code),
  code            text NOT NULL,                  -- 'textbook'(同字典内唯一)
  label_en        text NOT NULL,                  -- 'Textbook'
  label_zh        text,                            -- '教材'(预留)
  icon            text,                            -- emoji 或 URL
  sort_order      int DEFAULT 0,
  is_active       boolean DEFAULT true,
  meta            jsonb DEFAULT '{}'::jsonb,      -- 扩展属性,如颜色
  created_by      uuid REFERENCES user_profiles(id),
  updated_by      uuid REFERENCES user_profiles(id),
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now(),
  
  UNIQUE (dict_code, code)
);
CREATE INDEX idx_dict_items_dict ON dict_items(dict_code) WHERE is_active = true;
CREATE INDEX idx_dict_items_sort ON dict_items(dict_code, sort_order);
```

### 2.3 RLS 策略

```sql
ALTER TABLE dict_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE dict_items ENABLE ROW LEVEL SECURITY;

-- 任何人可读(包括未登录,因为 App 启动时就需要拉取)
CREATE POLICY "anyone_read_categories" ON dict_categories FOR SELECT USING (true);
CREATE POLICY "anyone_read_items" ON dict_items FOR SELECT USING (true);

-- 仅平台超管可写
CREATE POLICY "super_admin_write_categories" ON dict_categories FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid() AND role = 'platform_super'));
CREATE POLICY "super_admin_write_items" ON dict_items FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid() AND role = 'platform_super'));
```

---

## 3. MVP 阶段初始化字典

### 3.1 listing_category(商品分类)

```sql
INSERT INTO dict_categories (code, name_en, description, is_system, display_order) VALUES
  ('listing_category', 'Listing Category', '商品发布时的分类', false, 1);

INSERT INTO dict_items (dict_code, code, label_en, icon, sort_order) VALUES
  ('listing_category', 'textbook',   'Textbook',     '📚', 1),
  ('listing_category', 'electronic', 'Electronics',  '💻', 2),
  ('listing_category', 'apparel',    'Apparel',      '👗', 3),
  ('listing_category', 'furniture',  'Furniture',    '🛋️', 4),
  ('listing_category', 'beauty',     'Beauty',       '💄', 5),
  ('listing_category', 'sports',     'Sports & Outdoor', '⚽', 6),
  ('listing_category', 'event',      'Event Tickets',     '🎫', 7),
  ('listing_category', 'misc',       'Other',        '📦', 99);
```

### 3.2 pickup_location(提货地点)

```sql
INSERT INTO dict_categories (code, name_en, description, is_system, display_order) VALUES
  ('pickup_location', 'Pickup Location', '提货地点(Smith 校内主要点)', false, 2);

INSERT INTO dict_items (dict_code, code, label_en, sort_order) VALUES
  ('pickup_location', 'campus_center',  'Campus Center', 1),
  ('pickup_location', 'mailroom',       'Mailroom (Mendenhall)', 2),
  ('pickup_location', 'library',        'Neilson Library', 3),
  ('pickup_location', 'dining_hall',    'Dining Hall', 4),
  ('pickup_location', 'green_st',       'Green Street Dorms', 5),
  ('pickup_location', 'elm_st',         'Elm Street Dorms', 6),
  ('pickup_location', 'quad',           'The Quad Dorms', 7),
  ('pickup_location', 'gym',            'Indoor Track & Tennis', 8),
  ('pickup_location', 'downtown',       'Downtown Northampton', 9),
  ('pickup_location', 'other',          'Other (specify in chat)', 99);
```

### 3.3 item_condition(物品成色)

```sql
INSERT INTO dict_categories (code, name_en, description, is_system, display_order) VALUES
  ('item_condition', 'Item Condition', '物品成色等级', true, 3);

INSERT INTO dict_items (dict_code, code, label_en, icon, sort_order) VALUES
  ('item_condition', 'new',         'Brand New',       '✨', 1),
  ('item_condition', 'like_new',    'Like New (95%+)', '🌟', 2),
  ('item_condition', 'good',        'Good (80%+)',     '👍', 3),
  ('item_condition', 'fair',        'Fair (50%+)',     '👌', 4),
  ('item_condition', 'used',        'Used (< 50%)',    '🔧', 5);
```

### 3.4 report_reason(举报原因)

```sql
INSERT INTO dict_categories (code, name_en, description, is_system, display_order) VALUES
  ('report_reason', 'Report Reason', '举报原因(用于 Listing/聊天/用户举报)', true, 4);

INSERT INTO dict_items (dict_code, code, label_en, icon, sort_order) VALUES
  ('report_reason', 'spam',         'Spam or Misleading', '📢', 1),
  ('report_reason', 'scam',         'Scam or Fraud',      '⚠️', 2),
  ('report_reason', 'harassment',   'Harassment',         '🚫', 3),
  ('report_reason', 'nsfw',         'Inappropriate Content','🔞', 4),
  ('report_reason', 'other',        'Other',              '❓', 99);
```

### 3.5 user_tag(用户标签)

```sql
INSERT INTO dict_categories (code, name_en, description, is_system, display_order) VALUES
  ('user_tag', 'User Tag', 'Admin 给用户打的标签', false, 5);

INSERT INTO dict_items (dict_code, code, label_en, icon, sort_order) VALUES
  ('user_tag', 'vip_buyer',      'VIP Buyer',           '💎', 1),
  ('user_tag', 'vip_seller',     'VIP Seller',          '⭐', 2),
  ('user_tag', 'attention',      'Needs Attention',     '👁️', 3),
  ('user_tag', 'student_org',    'Student Org Member',  '🎓', 4),
  ('user_tag', 'verified',       'Identity Verified',   '✅', 5),
  ('user_tag', 'beta_tester',    'Beta Tester',         '🧪', 6);
```

### 3.6 feedback_tag(反馈标签)

```sql
INSERT INTO dict_categories (code, name_en, description, is_system, display_order) VALUES
  ('feedback_tag', 'Feedback Tag', '反馈分类标签,便于聚类分析', false, 6);

INSERT INTO dict_items (dict_code, code, label_en, sort_order) VALUES
  ('feedback_tag', 'ui',           'UI/UX',          1),
  ('feedback_tag', 'performance',  'Performance',    2),
  ('feedback_tag', 'chat',         'Chat',           3),
  ('feedback_tag', 'listing',      'Listing',        4),
  ('feedback_tag', 'rental',       'Rental',         5),
  ('feedback_tag', 'plaza',        'Plaza',          6),
  ('feedback_tag', 'other',        'Other',          99);
```

---

## 4. App 端接入

### 4.1 Flutter 模块

```
app/lib/core/dict/
├── dict_service.dart              # 拉取 + 缓存
├── dict_provider.dart             # Riverpod provider
└── models/
    ├── dict_item.dart
    └── dict_category.dart
```

### 4.2 DictService 实现

```dart
class DictService {
  Map<String, List<DictItem>> _cache = {};
  DateTime? _lastFetched;
  
  /// App 启动时调用
  Future<void> refresh() async {
    final result = await Supabase.instance.client.rpc('get_all_dicts');
    _cache = _parseResult(result);
    _lastFetched = DateTime.now();
  }
  
  /// 1 小时自动刷新一次
  Future<void> ensureFresh() async {
    if (_lastFetched == null || 
        DateTime.now().difference(_lastFetched!).inMinutes > 60) {
      await refresh();
    }
  }
  
  /// 获取某字典的全部启用项(已排序)
  List<DictItem> getActive(String dictCode) {
    return (_cache[dictCode] ?? [])
      .where((i) => i.isActive)
      .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  
  /// 根据 code 找单个项的 label
  /// 即使该项已停用,仍能返回(用于显示历史数据)
  String labelOf(String dictCode, String itemCode) {
    final item = _cache[dictCode]?.firstWhere(
      (i) => i.code == itemCode, 
      orElse: () => DictItem.fallback(itemCode)
    );
    return item?.labelEn ?? itemCode;
  }
  
  /// 获取 icon
  String? iconOf(String dictCode, String itemCode) {
    return _cache[dictCode]
      ?.firstWhere((i) => i.code == itemCode, orElse: () => null)
      ?.icon;
  }
}
```

### 4.3 数据存储约定

App 端**写入数据库时,存的是 code,不是 label**:

```dart
// ✅ 正确
await supabase.from('listings').insert({
  'category': 'textbook',     // code
  'condition': 'like_new',    // code
  'pickup_location': 'campus_center',
});

// ❌ 错误
await supabase.from('listings').insert({
  'category': 'Textbook',    // label
});
```

显示时通过 `DictService.labelOf` 转换:

```dart
Text(dictService.labelOf('listing_category', listing.category))
// → 'Textbook'
```

### 4.4 RPC 函数(批量拉取)

```sql
CREATE OR REPLACE FUNCTION get_all_dicts()
RETURNS jsonb AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_object_agg(
    c.code,
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', i.id,
          'code', i.code,
          'labelEn', i.label_en,
          'labelZh', i.label_zh,
          'icon', i.icon,
          'sortOrder', i.sort_order,
          'isActive', i.is_active,
          'meta', i.meta
        ) ORDER BY i.sort_order
      )
      FROM dict_items i
      WHERE i.dict_code = c.code AND i.is_active = true
    )
  ) INTO result
  FROM dict_categories c
  WHERE c.is_active = true;
  
  RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

---

## 5. Admin Web 接入

### 5.1 字典分类列表页 `/settings/dictionary`

见 `04_ADMIN_WEB_SPEC.md` §16.1。

### 5.2 字典项管理页 `/settings/dictionary/:dictCode`

见 `04_ADMIN_WEB_SPEC.md` §16.2。

### 5.3 拖拽排序实现

使用 `@dnd-kit/core`:

```typescript
// 拖拽结束后,批量更新 sort_order
const handleDragEnd = async (event) => {
  const { active, over } = event;
  if (active.id !== over.id) {
    const newOrder = arrayMove(items, active.id, over.id);
    await api.patch('/admin/dictionary/items/reorder', {
      dict_code: dictCode,
      ordered_item_ids: newOrder.map(i => i.id)
    });
  }
};
```

### 5.4 批量导入 CSV

CSV 格式:`code, label_en, label_zh, icon, sort_order`

```
new_category, New Category, 新分类, 📦, 100
another, Another, 另一个, 🌟, 101
```

导入时:
- 重复 code 跳过
- 校验失败行单独显示
- 成功导入数量提示

---

## 6. 既有代码迁移清单

App 端现有的硬编码枚举,需要逐处迁移到 DictService:

| 位置 | 硬编码值 | 迁移到字典 |
|---|---|---|
| Listing 发布表单 - 分类下拉 | 写死的 enum | `listing_category` |
| Listing 发布表单 - 提货地点 | 写死的 enum | `pickup_location` |
| Listing 发布表单 - 成色 | 写死的 enum | `item_condition` |
| Listing 详情 - 显示分类 | 写死的 label 映射 | `dictService.labelOf` |
| 举报对话框 - 原因下拉 | 写死的 enum | `report_reason` |
| 反馈表单 - 标签下拉(若有) | — | `feedback_tag` |

迁移策略:
1. **数据库已有数据保持不变**(都是 code 形式)
2. **只改 UI 渲染逻辑**——读取改为 `dictService.getActive(code)`
3. **写入逻辑不变**(仍写 code)

---

## 7. 已知风险与待办

| 风险 | 缓解策略 |
|---|---|
| 改 code 导致历史数据孤儿 | UI 警告"创建后不可改";若必须改走 SQL 数据迁移流程 |
| 字典缓存与服务端不一致 | 1 小时自动刷新 + 关键操作前 ensureFresh |
| 系统级字典被误停用 | is_system 标记保护,UI 禁用停用按钮 |
| 字典项过多导致 App 启动慢 | 当前预估 < 100 项,无问题;> 500 项时按需懒加载 |
| 多语言切换时 label 缺失 | label_zh 为空时 fallback 到 label_en |

---

## 8. 未来扩展

- **支持父子层级**(若需要):Schema 已预留 `parent_id` 思路,但当前阶段强制扁平
- **i18n 全局支持**:启用 label_zh,App 端按用户语言偏好选择
- **字典项使用统计**:统计每个项被引用了多少次,辅助清理无用项
- **字典版本快照**:重大变更时保存历史版本,支持回滚

---

*文档版本:v1.0 · 维护者:Smivo 项目主导*
*最后更新:2026-04-30*
