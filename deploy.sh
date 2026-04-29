#!/bin/bash
# 自动编译 Flutter Web 并发布到 GitHub

echo "🚀 [1/4] 正在编译 Flutter Web (Admin Panel)..."
flutter build web --base-href /admin/

if [ $? -ne 0 ]; then
  echo "❌ 编译失败！"
  exit 1
fi

echo "📂 [2/4] 正在复制编译文件到 website/admin 目录..."
rm -rf website/admin
cp -r build/web website/admin

echo "📝 [3/4] 正在将改动添加到 Git..."
git add website

echo "⬆️ [4/4] 自动提交并推送到 GitHub..."
# 如果有参数，就用参数作为 commit message，否则使用默认值
COMMIT_MSG=${1:-"chore: auto-build and deploy website to Vercel"}

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD -- website; then
  git commit -m "$COMMIT_MSG"
  git push origin main
  echo "✅ 推送成功！Vercel 将在几秒内自动更新。"
else
  echo "⚠️ website 文件夹没有需要更新的改动。"
fi
