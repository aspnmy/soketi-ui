# LiteSQL 专用 Dockerfile
# 此文件针对SQLite数据库进行了优化，移除了不必要的依赖以减小容器大小

# ===== 构建阶段1：Composer依赖安装 =====
FROM composer:latest AS composer

WORKDIR /src

# 复制composer配置文件
COPY composer.lite.json ./composer.json

# 安装依赖（不包括开发依赖）
RUN composer install --no-dev --no-scripts --optimize-autoloader --ignore-platform-reqs

# ===== 构建阶段2：前端资源构建 =====
FROM node:18-alpine AS frontend

WORKDIR /src

# 复制前端配置文件
COPY package.json  ./

# 安装依赖
RUN yarn install --frozen-lockfile

# 复制前端源代码
COPY public ./public
COPY resources ./resources
COPY jsconfig.json postcss.config.js tailwind.config.js vite.config.mjs ./

# 构建前端资源
RUN yarn build

# ===== 运行阶段：LiteSQL优化版本 =====
FROM jkaninda/nginx-php-fpm:8.2

# 标签信息
LABEL maintainer="https://github.com/aspnmy"
LABEL version="lite-202509-optimized-debian"
LABEL description="Soketi UI with LiteSQL (SQLite) optimization using Debian base"

# 设置工作目录
WORKDIR /var/www/html

# 配置Nginx站点
COPY nginx.conf /var/www/html/conf/nginx/nginx-site.conf

# 安装最小化的系统依赖并配置PHP（Debian系统）
# 根据基础镜像jkaninda/nginx-php-fpm:8.2信息，该镜像已预装了多种PHP扩展
# 包括：zip, mbstring, exif, pcntl, bcmath, gd, intl, redis, memcached, pdo_mysql, pdo_pgsql, opcache, rdkafka

# 基础镜像jkaninda/nginx-php-fpm:8.2已预装SQLite3扩展，无需额外安装
# 仅添加LiteSQL3初始化代码确保数据库正确配置
RUN echo "验证SQLite3扩展是否已启用..." && \
    php -m | grep -q sqlite3 && echo "SQLite3扩展已启用" || echo "Warning: SQLite3扩展未找到"

# 配置SQLite3特定参数
RUN echo "[sqlite3]" >> $PHP_INI_DIR/conf.d/custom.ini && \
    echo "sqlite3.extension_dir = /usr/lib/php/20220829/" >> $PHP_INI_DIR/conf.d/custom.ini

# 使用基础镜像提供的PHP配置路径（$PHP_INI_DIR/conf.d/）
# 这是基础镜像中已设置的标准配置路径
RUN echo "Finding PHP configuration directories..." && \ 
    echo "PHP_INI_DIR is set to: $PHP_INI_DIR" && \ 
    mkdir -p $PHP_INI_DIR/conf.d/ && \ 
    echo "[PHP]" > $PHP_INI_DIR/conf.d/custom.ini && \ 
    echo "memory_limit = 256M" >> $PHP_INI_DIR/conf.d/custom.ini && \ 
    echo "max_execution_time = 60" >> $PHP_INI_DIR/conf.d/custom.ini && \ 
    echo "post_max_size = 20M" >> $PHP_INI_DIR/conf.d/custom.ini && \ 
    echo "upload_max_filesize = 20M" >> $PHP_INI_DIR/conf.d/custom.ini

# 复制应用文件（先复制必要的配置文件）
COPY database/litesql_init.sql ./database/
COPY scripts/init_litesql.sh ./scripts/
COPY start.sh ./

# 复制构建阶段的文件
COPY --from=composer /src/vendor ./vendor
COPY --from=frontend /src/public/build ./public/build

# 创建SQLite数据库目录和必要的应用目录并设置权限
RUN mkdir -p /var/www/html/database \
    && mkdir -p /var/www/html/storage \
    && mkdir -p /var/www/html/bootstrap/cache \
    && chown -R 1000:1000 /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod +x /var/www/html/scripts/init_litesql.sh \
    && chmod +x /var/www/html/start.sh

# 设置环境变量默认值（可被docker-compose覆盖）
ENV APP_ENV=production \
    APP_DEBUG=true \
    DB_CONNECTION=sqlite \
    DB_DATABASE=/var/www/html/database/database.sqlite \
    CACHE_DRIVER=file \
    QUEUE_CONNECTION=sync \
    SESSION_DRIVER=file \
    LITESQL_INIT_SCRIPT=/var/www/html/database/litesql_init.sql

# 暴露端口
EXPOSE 8000

# 容器启动命令
CMD ["/start.sh"]