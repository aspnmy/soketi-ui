# Soketi UI - LiteSQL 版本

A dashboard to manage your apps in Soketi, optimized for SQLite.

## 简介

这是 Soketi UI 的 LiteSQL 优化版本，专为 SQLite 数据库设计，提供更轻量、更高效的部署方案。

## 包含的文件

- `.env.lite` - LiteSQL专用环境配置文件
- `Dockerfile.lite` - LiteSQL专用Dockerfile
- `docker-compose.lite.yml` - LiteSQL专用Docker Compose配置
- `composer.lite.json` - LiteSQL专用composer.json文件
- `database/litesql_init.sql` - SQLite数据库初始化SQL脚本
- `scripts/` - 包含数据库维护脚本

## 特点

1. **优化的SQLite配置** - 完全基于SQLite数据库，移除了MySQL等其他数据库引擎的依赖
2. **更小的容器大小** - 移除了不必要的系统依赖和PHP扩展
3. **资源占用降低** - 优化了PHP和Nginx配置，减少内存和CPU使用
4. **持久化数据** - 配置了数据库和存储目录的卷挂载
5. **资源限制** - 为容器设置了合理的资源限制

## 系统要求

- PHP 8.2+
- Node 18+
- SQLite 3+
- Docker（可选，推荐使用）

## 快速开始（Docker方式）

### 1. 准备环境

```bash
# 复制LiteSQL环境配置文件
cp .env.lite .env

# 生成应用密钥
php artisan key:generate
```

### 2. 使用Docker Compose部署

```bash
# 使用LiteSQL专用配置文件启动容器
docker-compose -f docker-compose.lite.yml up -d --build

# 初始化数据库
docker-compose -f docker-compose.lite.yml exec app php artisan migrate

# 可选：填充示例数据
docker-compose -f docker-compose.lite.yml exec app php artisan db:seed
```

### 3. 访问应用

应用将在 http://localhost:8080 上可用

## 手动安装（非Docker方式）

### 1. 安装依赖

```bash
# 使用LiteSQL专用composer文件安装依赖
composer install --no-dev --optimize-autoloader --no-plugins --no-scripts --composer composer.lite.json

# 安装前端依赖
npm install

# 构建前端资源
npm run build
```

### 2. 配置环境

```bash
# 复制LiteSQL环境配置文件
cp .env.lite .env

# 生成应用密钥
php artisan key:generate
```

### 3. 初始化数据库

```bash
# 创建数据库目录（如果不存在）
mkdir -p database

# 运行数据库初始化脚本
chmod +x scripts/init_litesql.sh
./scripts/init_litesql.sh

# 运行数据库迁移
php artisan migrate

# 可选：填充示例数据
php artisan db:seed
```

### 4. 优化应用

```bash
# 运行Laravel优化命令
php artisan optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 5. 启动服务

```bash
# 使用PHP内置服务器（仅开发环境）
php artisan serve

# 或者使用Nginx+PHP-FPM（生产环境推荐）
# 参考常规Laravel部署指南配置Web服务器
```

## 数据库维护

LiteSQL模式已包含以下数据库维护脚本：

- `scripts/backup_sqlite.sh` - 数据库备份脚本
- `scripts/optimize_sqlite.sh` - 数据库优化脚本
- `scripts/init_litesql.sh` - 数据库初始化脚本
- `database/litesql_init.sql` - SQLite数据库初始化SQL脚本

### 运行备份

```bash
# 运行数据库备份
bash scripts/backup_sqlite.sh
```

### 运行优化

```bash
# 运行数据库优化
bash scripts/optimize_sqlite.sh
```

## 性能优化建议

1. **定期运行优化脚本** - 建议每周运行一次`optimize_sqlite.sh`脚本
2. **合理配置资源限制** - 根据实际负载调整`docker-compose.lite.yml`中的资源限制
3. **启用SQLite WAL模式** - 可在`.env.lite`中添加配置以启用WAL模式
4. **避免大事务** - SQLite对大事务处理能力有限，建议拆分为小事务
5. **定期备份** - 建议设置定时任务定期执行备份脚本

## 常见问题

### Q: 如何增加LiteSQL的性能？

A: 可以通过以下方式优化性能：
- 启用SQLite的WAL模式
- 定期运行VACUUM命令（已包含在优化脚本中）
- 优化数据库索引
- 减少大查询，使用分页

### Q: LiteSQL模式支持多少并发用户？

A: 由于SQLite的特性，LiteSQL模式最适合中小型应用，建议并发用户数在50以下。对于高并发场景，建议使用标准的MySQL/PostgreSQL配置。

## 查看数据库内容

使用 SQLite 命令行工具检查数据库：

```bash
sqlite3 database/database.sqlite

# 查看所有表
.tables

# 查看表结构
.schema apps

# 查看数据
SELECT * FROM apps;

# 退出
.quit
```

## 更新日志

- 2025-09-XX: 创建LiteSQL专用配置文件，优化SQLite部署
- 维护者: https://github.com/aspnmy

## 项目截图

<img width="846" alt="Screenshot 2023-12-31 at 12 55 11" src="https://github.com/Daynnnnn/soketi-ui/assets/25618897/502afea9-de7c-4916-881b-5c635e55cd0f">
<img width="938" alt="Screenshot 2023-12-31 at 12 55 24" src="https://github.com/Daynnnnn/soketi-ui/assets/25618897/f075815f-1d54-4929-829d-bc22de37b486">
<img width="836" alt="Screenshot 2023-12-31 at 12 58 40" src="https://github.com/Daynnnnn/soketi-ui/assets/25618897/4c7eb64b-8b7f-4aab-a0c4-a959d07d6d19">
