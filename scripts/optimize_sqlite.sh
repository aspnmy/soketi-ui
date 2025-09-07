#!/bin/bash

# SQLite 数据库优化脚本

DB_FILE="database/database.sqlite"

# 检查数据库文件是否存在
if [ ! -f "$DB_FILE" ]; then
    echo "错误：数据库文件 $DB_FILE 不存在！"
    exit 1
fi

# 检查 sqlite3 命令是否可用
if ! command -v sqlite3 &> /dev/null; then
    echo "错误：sqlite3 命令未找到，请安装 SQLite！"
    exit 1
fi

# 获取优化前的数据库大小
BEFORE_SIZE=$(du -h $DB_FILE | cut -f1)
BEFORE_SIZE_BYTES=$(stat -c%s $DB_FILE 2> /dev/null || stat -f%z $DB_FILE 2> /dev/null)

# 显示开始优化信息
echo "开始优化 SQLite 数据库..."
echo "数据库文件: $DB_FILE"
echo "优化前大小: $BEFORE_SIZE"

# 执行 VACUUM 命令优化数据库
sqlite3 $DB_FILE "VACUUM;"

# 执行 ANALYZE 命令更新统计信息
sqlite3 $DB_FILE "ANALYZE;"

# 执行 REINDEX 命令重建索引
sqlite3 $DB_FILE "REINDEX;"

# 获取优化后的数据库大小
AFTER_SIZE=$(du -h $DB_FILE | cut -f1)
AFTER_SIZE_BYTES=$(stat -c%s $DB_FILE 2> /dev/null || stat -f%z $DB_FILE 2> /dev/null)

# 计算节省的空间
if [ ! -z "$BEFORE_SIZE_BYTES" ] && [ ! -z "$AFTER_SIZE_BYTES" ]; then
    SAVED_BYTES=$((BEFORE_SIZE_BYTES - AFTER_SIZE_BYTES))
    SAVED_MB=$(echo "scale=2; $SAVED_BYTES / 1024 / 1024" | bc)
    echo "优化后大小: $AFTER_SIZE"
    echo "节省空间: $SAVED_MB MB ($SAVED_BYTES 字节)"
else
    echo "优化后大小: $AFTER_SIZE"
    echo "无法精确计算节省空间大小"
fi

# 显示优化完成信息
echo "数据库优化完成！"
echo "建议：定期运行此脚本以保持数据库性能"
echo "推荐的优化频率：每周一次或在大量数据变更后"