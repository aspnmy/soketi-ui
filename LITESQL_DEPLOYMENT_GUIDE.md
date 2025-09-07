# SQLite 数据库部署指南

## 概述

本指南提供了在 soketi-ui 项目中使用 SQLite 数据库进行 Docker 部署的完整说明。SQLite 是一款轻量级、零配置的数据库引擎，非常适合中小型应用的容器化部署，可以显著减少 Docker 镜像的大小和资源占用。

> **注意**：本指南中提到的 "LiteSQL" 指的是 SQLite 轻量级数据库解决方案，用于优化 Docker 部署环境下的数据库性能和资源占用。

## 为什么选择 SQLite（LiteSQL）？

### 主要优势

- **显著减小镜像体积**：相比 MySQL，SQLite 数据库文件占用空间更小，可将 Docker 镜像体积减少 50% 以上
- **零配置部署**：不需要额外的数据库服务器容器，简化了 Docker Compose 配置
- **单一文件管理**：整个数据库存储在单个文件中，便于备份和迁移
- **性能足够**：对于 soketi-ui 这样的中小型应用，SQLite 性能完全满足需求
- **资源友好**：占用更少的内存和 CPU 资源，适合资源受限环境

### 适用场景

- 开发和测试环境
- 中小型生产应用
- 单机部署的容器化应用
- 资源受限的环境（如小型服务器、边缘设备等）

## 配置修改详解

### 1. Dockerfile 配置

已在 Dockerfile 中添加了 SQLite 相关扩展支持：

```dockerfile
# PHP 扩展安装（包含 SQLite 支持）
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd pdo_sqlite sqlite3

# 创建 SQLite 数据库目录
RUN mkdir -p /var/www/html/database

# 设置适当的权限
RUN chown -R 1000:1000 /var/www/html
```

### 2. 环境配置

在 `.env.example` 文件中，我们已默认启用了 SQLite 配置：

```
# SQLite 配置（推荐Docker部署时使用，占用空间更小）
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

# 数据库缓存设置（可选）
# DB_CACHE=true
# DB_CACHE_DRIVER=redis
```

### 3. Docker Compose 配置

`docker-compose.yml` 文件已更新为使用 SQLite：

```yaml
environment:
  - APP_DEBUG=true
  - APP_KEY=
  - DB_CONNECTION=sqlite
  - DB_DATABASE=database/database.sqlite
  # 可选的数据库缓存配置
  # - DB_CACHE=true
  # - DB_CACHE_DRIVER=redis
```

## 快速部署步骤

### 基本部署流程

1. **准备环境**
   ```bash
   # 确保已安装 Docker 和 Docker Compose
   docker --version
   docker-compose --version
   ```

2. **克隆项目代码**
   ```bash
   git clone <项目仓库地址>
   cd soketi-ui
   ```

3. **复制环境配置文件**
   ```bash
   cp .env.example .env
   ```

4. **生成应用密钥**
   ```bash
   docker-compose run --rm app php artisan key:generate
   ```

5. **启动应用容器**
   ```bash
   docker-compose up -d
   ```

6. **运行数据库迁移**
   ```bash
   docker-compose exec app php artisan migrate
   ```

7. **验证部署**
   访问 http://localhost:8000 确认应用正常运行

### 使用初始化脚本

项目包含多个 SQLite 初始化脚本，可用于设置数据库环境：

#### Shell 初始化脚本

```bash
# 授予脚本执行权限
chmod +x scripts/init_sqlite.sh

# 运行初始化脚本
./scripts/init_sqlite.sh
```

#### 使用LiteSQL初始化脚本

我们提供了专门为SQLite优化的数据库初始化脚本，包含完整的表结构定义：

1. 脚本路径：`database/litesql_init.sql`

2. 执行方式：
   ```bash
   # 在容器内部执行
   sqlite3 /var/www/html/database/database.sqlite < /var/www/html/database/litesql_init.sql
   
   # 或在宿主机上执行
   docker exec -i soketi-ui sqlite3 /var/www/html/database/database.sqlite < database/litesql_init.sql
   ```

3. 脚本特点：
   - 完全兼容SQLite语法
   - 包含适当的索引优化
   - 提供可选的示例数据（默认注释）
   - 自动创建所需的表结构

## 高级配置与优化

### 1. 数据持久化配置

为防止容器重启时数据丢失，建议配置数据持久化：

```yaml
# 在 docker-compose.yml 文件中添加
volumes:
  - ./database/database.sqlite:/var/www/html/database/database.sqlite
```

### 2. 性能优化设置

SQLite 可以通过以下方式进行优化：

#### 2.1 启用数据库缓存

在 `.env` 文件中添加：
```
DB_CACHE=true
DB_CACHE_DRIVER=redis
```

#### 2.2 调整 SQLite 连接配置

编辑 `config/database.php` 文件中的 SQLite 配置：
```php
'sqlite' => [
    'driver' => 'sqlite',
    'url' => env('DATABASE_URL'),
    'database' => env('DB_DATABASE', database_path('database.sqlite')),
    'prefix' => '',
    'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
    // 添加以下优化配置
    'options' => [
        PDO::ATTR_PERSISTENT => true,  // 启用持久连接
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
        PDO::ATTR_TIMEOUT => 5,  // 设置连接超时
    ],
],
```

### 3. 定期维护任务

建议设置以下定期维护任务：

#### 3.1 数据库备份

创建备份脚本 `scripts/backup_sqlite.sh`：
```bash
#!/bin/bash

# 备份目录
BACKUP_DIR="backups"
DB_FILE="database/database.sqlite"

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
```

设置为每日定时任务：
```bash
# 添加到 crontab
0 0 * * * /path/to/soketi-ui/scripts/backup_sqlite.sh
```

#### 3.2 数据库优化

创建优化脚本 `scripts/optimize_sqlite.sh`：
```bash
#!/bin/bash

DB_FILE="database/database.sqlite"

# 执行 VACUUM 命令优化数据库
sqlite3 $DB_FILE "VACUUM;"

echo "数据库优化完成"
```

## 监控与故障排查

### 1. 查看数据库状态

```bash
# 进入容器
 docker-compose exec app bash

# 使用 SQLite 命令行工具检查数据库
 sqlite3 database/database.sqlite

# 查看数据库表
sqlite> .tables

# 查看表结构
sqlite> .schema table_name

# 退出
 sqlite> .exit
```

### 2. 常见问题排查

#### 权限问题
如果遇到数据库文件权限错误：
```bash
# 调整主机上的文件权限
sudo chmod 775 database/database.sqlite
sudo chown 1000:1000 database/database.sqlite
```

#### 数据库锁定
如果遇到数据库锁定错误，可能是因为多个进程同时访问数据库。可以通过以下方式解决：
- 减少并发写入操作
- 调整应用代码中的事务处理
- 考虑使用连接池管理数据库连接

## 从其他数据库迁移

### 从 MySQL 迁移到 SQLite

1. **导出 MySQL 数据**
   ```bash
   mysqldump -u root -p --compatible=ansi --skip-extended-insert your_database > dump.sql
   ```

2. **清理导出的 SQL**
   可能需要手动编辑 dump.sql 文件，移除 SQLite 不支持的语法。

3. **导入到 SQLite**
   ```bash
   sqlite3 database/database.sqlite < dump.sql
   ```

4. **更新配置**
   修改 `.env` 文件中的数据库配置为 SQLite。

5. **重新启动应用**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## 生产环境注意事项

### 不适合的场景
SQLite 不适合以下场景：
- 高并发写入的生产环境
- 需要水平扩展的应用
- 多服务器访问同一数据库的情况

### 推荐的生产环境配置

对于生产环境，建议：
1. 配置适当的文件系统权限
2. 实现定期备份策略
3. 考虑使用网络文件系统 (NFS) 挂载数据库文件
4. 监控数据库文件大小和性能
5. 如果应用规模扩大，考虑迁移到其他数据库系统

## 相关资源

- [SQLite 官方文档](https://www.sqlite.org/docs.html)
- [Laravel SQLite 文档](https://laravel.com/docs/database#sqlite-configuration)
- [SQLite 性能优化指南](https://www.sqlite.org/queryplanner.html)

---

更新日期：2025年9月
维护者：https://github.com/aspnmy