#!/bin/sh

# LiteSQL容器启动脚本
# 此脚本在容器启动时执行数据库初始化和应用服务启动

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 数据库路径和初始化脚本路径
DB_PATH="/var/www/html/database/database.sqlite"
INIT_SQL_PATH="/var/www/html/database/litesql_init.sql"
INIT_SCRIPT="/var/www/html/scripts/init_litesql.sh"

# 函数：检查数据库是否已初始化
check_database() {
    echo -e "${YELLOW}检查LiteSQL数据库状态...${NC}"
    if [ -f "$DB_PATH" ]; then
        # 检查数据库中是否存在apps表
        if sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table' AND name='apps';" | grep -q apps; then
            echo -e "${GREEN}LiteSQL数据库已初始化。${NC}"
            return 0
        else
            echo -e "${YELLOW}LiteSQL数据库文件存在但未初始化。${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}LiteSQL数据库文件不存在。${NC}"
        return 1
    fi
}

# 函数：初始化数据库
init_database() {
    echo -e "${YELLOW}开始LiteSQL数据库初始化...${NC}"
    if [ -x "$INIT_SCRIPT" ]; then
        # 运行初始化脚本
        if sh "$INIT_SCRIPT" -p "$DB_PATH" -s "$INIT_SQL_PATH"; then
            echo -e "${GREEN}LiteSQL数据库初始化成功！${NC}"
            return 0
        else
            echo -e "${RED}LiteSQL数据库初始化失败。${NC}"
            return 1
        fi
    else
        echo -e "${RED}错误: 初始化脚本 '$INIT_SCRIPT' 不可执行。${NC}"
        return 1
    fi
}

# 函数：运行数据库迁移
run_migrations() {
    echo -e "${YELLOW}运行数据库迁移...${NC}"
    if php artisan migrate --force; then
        echo -e "${GREEN}数据库迁移完成。${NC}"
        return 0
    else
        echo -e "${YELLOW}数据库迁移可能已完成或出现非致命错误，继续启动应用。${NC}"
        return 0
    fi
}

# 函数：生成应用密钥
generate_app_key() {
    echo -e "${YELLOW}检查应用密钥...${NC}"
    if ! grep -q "APP_KEY=base64:" /var/www/html/.env 2>/dev/null; then
        echo -e "${YELLOW}生成应用密钥...${NC}"
        php artisan key:generate
        echo -e "${GREEN}应用密钥生成完成。${NC}"
    else
        echo -e "${GREEN}应用密钥已存在。${NC}"
    fi
}

# 主函数
main() {
    echo -e "${GREEN}===== LiteSQL容器启动流程 =====${NC}"
    
    # 检查并初始化数据库
    if ! check_database; then
        if ! init_database; then
            echo -e "${RED}警告: 数据库初始化失败，但将继续启动应用。可能需要手动初始化。${NC}"
        fi
    fi
    
    # 生成应用密钥
    generate_app_key
    
    # 运行数据库迁移
    run_migrations
    
    # 清理缓存
    echo -e "${YELLOW}清理应用缓存...${NC}"
    php artisan config:cache
    php artisan route:cache
    
    echo -e "${GREEN}\n===== LiteSQL应用启动成功 =====${NC}"
    echo -e "${GREEN}应用地址: http://localhost:8000${NC}"
    echo -e "${YELLOW}注意: 首次访问可能需要创建管理员账户。${NC}"
    
    # 启动PHP-FPM和Nginx服务
    echo -e "${YELLOW}\n启动PHP-FPM和Nginx服务...${NC}"
    exec php-fpm82 -D && nginx -g 'daemon off;'
}

# 执行主函数
main