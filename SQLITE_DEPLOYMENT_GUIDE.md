# SQLite 部署指南

本指南提供了如何在 soketi-ui 项目中使用 SQLite 数据库进行 Docker 部署的详细步骤。

## 为什么选择 SQLite？

- **轻量级**：相比 MySQL，SQLite 数据库文件占用空间更小
- **零配置**：不需要额外的数据库服务器，简化了部署过程
- **适合小型应用**：对于 soketi-ui 这样的中小型应用，SQLite 性能完全足够
- **Docker 友好**：单一文件便于容器化部署和数据持久化

## 配置修改内容

项目已经完成了以下配置修改以支持 SQLite：

1. **Dockerfile**：添加了 SQLite 扩展支持
2. **.env.example**：添加了 SQLite 配置选项
3. **docker-compose.yml**：更新了环境变量以使用 SQLite
4. **新增脚本**：添加了 `scripts/init_sqlite.sh` 初始化脚本

## 部署步骤

### 使用 Docker Compose 部署

1. 确保已安装 Docker 和 Docker Compose

2. 克隆项目代码

3. 复制 `.env.example` 到 `.env`
   ```bash
   cp .env.example .env
   ```

4. 生成应用密钥
   ```bash
   docker-compose run --rm app php artisan key:generate
   ```

5. 启动容器
   ```bash
   docker-compose up -d
   ```

6. 运行数据库迁移
   ```bash
   docker-compose exec app php artisan migrate
   ```

7. （可选）运行数据填充
   ```bash
   docker-compose exec app php artisan db:seed
   ```

8. 访问应用：http://localhost:8000

### 手动构建 Docker 镜像

```bash
# 构建镜像
 docker build -t soketi-ui .

# 运行容器
 docker run -p 8000:80 -e DB_CONNECTION=sqlite -e DB_DATABASE=database/database.sqlite soketi-ui
```

## 数据持久化

为了确保数据不会丢失，建议将 SQLite 数据库文件挂载到主机：

```yaml
# 在 docker-compose.yml 中添加卷挂载
volumes:
  - ./database/database.sqlite:/var/www/html/database/database.sqlite
```

## 性能优化建议

1. **启用数据库缓存**
   在 `.env` 文件中添加：
   ```
   DB_CACHE=true
   DB_CACHE_DRIVER=redis
   ```

2. **定期备份数据库**
   添加定时任务备份 SQLite 数据库文件

3. **调整 SQLite 配置**
   可以在 `config/database.php` 中添加 SQLite 特定配置：
   ```php
   'sqlite' => [
       // 现有配置...
       'options' => [
           PDO::ATTR_PERSISTENT => true,
       ],
   ],
   ```

## 注意事项

1. SQLite 适用于中小型应用，不建议在高并发生产环境中使用
2. 确保数据库文件具有正确的读写权限
3. 定期备份数据库文件以防止数据丢失
4. 如果将来需要迁移到其他数据库系统，可以使用 Laravel 的数据迁移功能

## 从 MySQL 迁移到 SQLite

如果您已经在使用 MySQL 并且想要迁移到 SQLite，可以使用以下步骤：

1. 导出 MySQL 数据
   ```bash
   mysqldump -u root -p your_database > dump.sql
   ```

2. 将数据导入 SQLite
   ```bash
   sqlite3 database/database.sqlite < dump.sql
   ```

3. 更新 `.env` 文件中的数据库配置

4. 重新启动应用