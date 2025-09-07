#!/bin/bash

# SQLite 数据库备份脚本

# 备份目录
BACKUP_DIR="backups"
DB_FILE="database/database.sqlite"

# 检查数据库文件是否存在
if [ ! -f "$DB_FILE" ]; then
    echo "错误：数据库文件 $DB_FILE 不存在！"
    exit 1
fi

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行备份
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sqlite"
cp $DB_FILE $BACKUP_FILE

# 压缩备份文件
gzip $BACKUP_FILE

# 保留最近7天的备份
find $BACKUP_DIR -name "*.sqlite.gz" -mtime +7 -delete

# 输出备份完成信息
echo "备份完成: $BACKUP_FILE.gz"
echo "备份大小: $(du -h $BACKUP_FILE.gz | cut -f1)"
echo "保留了最近7天的备份文件"

# 可选：发送备份完成通知
# echo "数据库备份已完成" | mail -s "SQLite 备份报告" admin@example.com