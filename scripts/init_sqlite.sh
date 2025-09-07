#!/bin/bash

# 设置数据库目录
DB_DIR="database"
DB_FILE="$DB_DIR/database.sqlite"

# 创建数据库目录（如果不存在）
if [ ! -d "$DB_DIR" ]; then
    echo "创建数据库目录: $DB_DIR"
    mkdir -p "$DB_DIR"
fi

# 创建SQLite数据库文件（如果不存在）
if [ ! -f "$DB_FILE" ]; then
    echo "创建SQLite数据库文件: $DB_FILE"
    touch "$DB_FILE"
    echo "数据库文件已创建"
else
    echo "SQLite数据库文件已存在: $DB_FILE"
fi

# 设置正确的权限
chmod -R 775 "$DB_DIR"
echo "已设置数据库目录权限"

# 提示用户运行迁移命令
echo "\n请确保在首次运行应用时执行迁移命令："
echo "php artisan migrate"
echo "\n要使用填充数据（如果有）："
echo "php artisan db:seed"