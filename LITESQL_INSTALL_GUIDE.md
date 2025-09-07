# LiteSQL 模式安装指南

本指南提供了如何使用为LiteSQL（SQLite优化版本）创建的专用配置文件来部署Soketi UI应用。

## 包含的文件

- `.env.lite` - LiteSQL专用环境配置文件
- `Dockerfile.lite` - LiteSQL专用Dockerfile
- `docker-compose.lite.yml` - LiteSQL专用Docker Compose配置
- `composer.lite.json` - LiteSQL专用composer.json文件

## 特点

1. **优化的SQLite配置** - 完全基于SQLite数据库，移除了MySQL等其他数据库引擎的依赖
2. **更小的容器大小** - 移除了不必要的系统依赖和PHP扩展
3. **资源占用降低** - 优化了PHP和Nginx配置，减少内存和CPU使用
4. **持久化数据** - 配置了数据库和存储目录的卷挂载
5. **资源限制** - 为容器设置了合理的资源限制

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

### Q: 如何从MySQL迁移到LiteSQL？

A: 可以使用Laravel的导出/导入功能：

```bash
# 从MySQL导出数据
php artisan db:dump --connection=mysql

# 导入到LiteSQL
php artisan db:import --connection=sqlite dump.sql
```

### Q: 如何增加LiteSQL的性能？

A: 可以通过以下方式优化性能：
- 启用SQLite的WAL模式
- 定期运行VACUUM命令（已包含在优化脚本中）
- 优化数据库索引
- 减少大查询，使用分页

### Q: LiteSQL模式支持多少并发用户？

A: 由于SQLite的特性，LiteSQL模式最适合中小型应用，建议并发用户数在50以下。对于高并发场景，建议使用标准的MySQL/PostgreSQL配置。

## 更新日志

- 2025-09-XX: 创建LiteSQL专用配置文件，优化SQLite部署
- 维护者: https://github.com/aspnmy