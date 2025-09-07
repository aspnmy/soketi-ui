# LiteSQL/SQLite 数据库初始化指南

本指南将帮助您在 soketi-ui 项目中设置和初始化 LiteSQL（SQLite）数据库。

## 前提条件

- 已安装 SQLite 3
- 已完成项目的 Docker 环境配置

## 初始化脚本

项目提供了多个工具来帮助您初始化 LiteSQL/SQLite 数据库：

### 1. Shell 初始化脚本 (init_sqlite.sh)

基础脚本，用于自动创建数据库目录和文件。

使用方法：
```bash
chmod +x scripts/init_sqlite.sh
./scripts/init_sqlite.sh
```

### 2. 高级 LiteSQL 初始化脚本 (init_litesql.sh)

增强版脚本，专门用于应用我们优化的 SQLite 表结构。

使用方法：
```bash
chmod +x scripts/init_litesql.sh
./scripts/init_litesql.sh
```

可选参数：
```bash
# 指定数据库文件路径
./scripts/init_litesql.sh --path custom/path/database.sqlite

# 指定初始化SQL脚本路径
./scripts/init_litesql.sh --sql custom/path/init.sql

# 显示帮助信息
./scripts/init_litesql.sh --help
```

### 3. SQL 结构定义脚本 (litesql_init.sql)

包含完整表结构定义的 SQL 脚本文件，位于 `database/litesql_init.sql`。

直接执行方法：
```bash
sqlite3 database/database.sqlite < database/litesql_init.sql
```

## 在 Docker 环境中使用

如果您使用 Docker 部署项目，数据库初始化会自动处理。Dockerfile 中已包含创建数据库目录的命令。

### Docker Compose

在 `docker-compose.yml` 中，确保您已配置 SQLite 数据库连接：

```yaml
environment:
  - DB_CONNECTION=sqlite
  - DB_DATABASE=/var/www/html/database/database.sqlite
```

### 在 Docker 容器内执行初始化

```bash
docker exec -i soketi-ui bash -c "chmod +x /var/www/html/scripts/init_litesql.sh && /var/www/html/scripts/init_litesql.sh"
```

或者直接执行 SQL 脚本：

```bash
docker exec -i soketi-ui sqlite3 /var/www/html/database/database.sqlite < database/litesql_init.sql
```

## 后续步骤

初始化数据库后，您需要运行数据库迁移和填充命令：

1. 运行迁移：
   ```bash
   php artisan migrate
   # 或在 Docker 容器内
   docker exec -i soketi-ui php artisan migrate
   ```

2. 填充数据：
   ```bash
   php artisan db:seed
   # 或在 Docker 容器内
   docker exec -i soketi-ui php artisan db:seed
   ```

3. 验证数据库连接：
   ```bash
   php artisan tinker --execute="DB::connection()->getPdo()"
   ```

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