#!/bin/bash

# 清理与liteSQL3无关的代码和中间文件

# 设置脚本执行错误时立即退出
set -e

# 打印当前工作目录
echo "当前工作目录: $(pwd)"

echo "开始清理与liteSQL3无关的文件和目录..."

# 定义要保留的liteSQL3相关文件
lite_sql_files=("Dockerfile.lite" "docker-compose.lite.yml" "composer.lite.json" ".env.lite" ".gitignore" "LITESQL_INSTALL_GUIDE.md" "LITESQL_DEPLOYMENT_GUIDE.md" "INIT_SQLITE.md" "SQLITE_DEPLOYMENT_GUIDE.md")

# 定义要保留的目录
echo "保留以下目录内容:"
keep_directories=("app" "database" "public" "resources" "routes" "scripts" "config" "tests" "storage")
for dir in "${keep_directories[@]}"; do
  echo "- $dir"
done

# 清理不需要的Docker和环境配置文件
echo "清理不需要的Docker和环境配置文件..."
if [ -f "Dockerfile" ] && [ "$(basename -- "$0")" != "Dockerfile" ]; then
  echo "删除原始Dockerfile"
  rm -f "Dockerfile"
fi

if [ -f "docker-compose.yml" ] && [ "$(basename -- "$0")" != "docker-compose.yml" ]; then
  echo "删除原始docker-compose.yml"
  rm -f "docker-compose.yml"
fi

if [ -f "composer.json" ] && [ "$(basename -- "$0")" != "composer.json" ]; then
  echo "删除原始composer.json"
  rm -f "composer.json"
fi

if [ -f "composer.lock" ] && [ "$(basename -- "$0")" != "composer.lock" ]; then
  echo "删除composer.lock"
  rm -f "composer.lock"
fi

# 清理node_modules目录（如果存在）
if [ -d "node_modules" ]; then
  echo "删除node_modules目录"
  rm -rf "node_modules"
fi

# 清理临时文件和缓存
echo "清理临时文件和缓存..."
find . -type d -name "*.cache" -exec rm -rf {} +
find . -type f -name "*.log" -delete
find . -type f -name "*.tmp" -delete

# 清理vendor目录（如果存在）
if [ -d "vendor" ]; then
  echo "删除vendor目录"
  rm -rf "vendor"
fi

# 保留composer.lite.json作为主要的composer文件
if [ -f "composer.lite.json" ]; then
  echo "保留composer.lite.json作为主要的composer配置文件"
fi

# 清理public/build目录中的旧文件（如果存在）
if [ -d "public/build" ]; then
  echo "清理public/build目录"
  rm -rf "public/build/*"
fi

# 清理storage/cache目录
if [ -d "storage/cache" ]; then
  echo "清理storage/cache目录"
  rm -rf "storage/cache/*"
fi

# 清理storage/framework目录
if [ -d "storage/framework" ]; then
  echo "清理storage/framework目录"
  rm -rf "storage/framework/*"
fi

# 提示用户这是liteSQL3分支
echo "\n=== 已完成liteSQL3分支的清理工作 ==="
echo "这个分支已优化为只包含liteSQL3相关的代码和配置。"
echo "建议: 运行 'git status' 检查当前状态，然后提交更改。"
echo "=== 清理完成 ==="