#!/bin/bash

# LiteSQL数据库初始化脚本
# 此脚本用于快速初始化SQLite数据库并应用litesql_init.sql模式

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 默认数据库路径
DB_PATH="database/database.sqlite"
INIT_SQL_PATH="database/litesql_init.sql"

# 显示帮助信息
show_help() {
    echo -e "${GREEN}LiteSQL数据库初始化脚本${NC}"
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -p, --path <路径>    指定数据库文件路径 (默认: $DB_PATH)"
    echo "  -s, --sql <路径>     指定初始化SQL脚本路径 (默认: $INIT_SQL_PATH)"
    echo "  -h, --help           显示此帮助信息"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            DB_PATH="$2"
            shift 2
            ;;
        -s|--sql)
            INIT_SQL_PATH="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知选项 '$1'${NC}"
            show_help
            exit 1
            ;;
    esac

done

# 检查sqlite3命令是否可用
echo -e "${YELLOW}检查SQLite环境...${NC}"
if ! command -v sqlite3 &> /dev/null; then
    echo -e "${RED}错误: sqlite3命令未找到。请先安装SQLite。${NC}"
    exit 1
fi

echo -e "${GREEN}SQLite已安装: $(sqlite3 --version)${NC}"

# 检查初始化SQL脚本是否存在
if [ ! -f "$INIT_SQL_PATH" ]; then
    echo -e "${RED}错误: 初始化SQL脚本 '$INIT_SQL_PATH' 不存在。${NC}"
    exit 1
fi

echo -e "${YELLOW}找到初始化脚本: $INIT_SQL_PATH${NC}"

# 创建数据库目录（如果不存在）
DB_DIR=$(dirname "$DB_PATH")
if [ ! -d "$DB_DIR" ]; then
    echo -e "${YELLOW}创建数据库目录: $DB_DIR${NC}"
    mkdir -p "$DB_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 无法创建数据库目录 '$DB_DIR'。${NC}"
        exit 1
    fi
fi

# 执行初始化SQL脚本
echo -e "${YELLOW}正在初始化LiteSQL数据库...${NC}"
if sqlite3 "$DB_PATH" < "$INIT_SQL_PATH"; then
    echo -e "${GREEN}LiteSQL数据库初始化成功！${NC}"
    echo -e "${GREEN}数据库文件: $DB_PATH${NC}"
    
    # 显示数据库信息
    echo -e "${YELLOW}\n数据库表结构信息:${NC}"
    sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table';"
    
    # 提供后续操作建议
    echo -e "${YELLOW}\n建议操作:${NC}"
    echo "1. 运行数据库迁移: php artisan migrate"
    echo "2. 执行数据填充: php artisan db:seed"
    echo "3. 检查数据库连接: php artisan tinker --execute="DB::connection()->getPdo()""
    
    exit 0
else
    echo -e "${RED}错误: LiteSQL数据库初始化失败。${NC}"
    exit 1
fi