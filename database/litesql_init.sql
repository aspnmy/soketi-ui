-- LiteSQL (SQLite) 数据库初始化脚本
-- 此脚本用于创建soketi-ui应用所需的表结构

-- 创建apps表
CREATE TABLE IF NOT EXISTS apps (
    id TEXT NOT NULL PRIMARY KEY,
    key TEXT NOT NULL,
    secret TEXT NOT NULL,
    max_connections INTEGER NOT NULL,
    enable_client_messages INTEGER NOT NULL,
    enabled INTEGER NOT NULL,
    max_backend_events_per_sec INTEGER NOT NULL,
    max_client_events_per_sec INTEGER NOT NULL,
    max_read_req_per_sec INTEGER NOT NULL,
    webhooks TEXT,
    max_presence_members_per_channel INTEGER,
    max_presence_member_size_in_kb INTEGER,
    max_channel_name_length INTEGER,
    max_event_channels_at_once INTEGER,
    max_event_name_length INTEGER,
    max_event_payload_in_kb INTEGER,
    max_event_batch_size INTEGER,
    enable_user_authentication INTEGER NOT NULL
);

-- 添加唯一索引以确保key不重复
CREATE UNIQUE INDEX IF NOT EXISTS idx_apps_key ON apps (key);

-- 添加示例数据（可选）
-- INSERT INTO apps (id, key, secret, max_connections, enable_client_messages, enabled, max_backend_events_per_sec, max_client_events_per_sec, max_read_req_per_sec, webhooks, enable_user_authentication)
-- VALUES (
--     'app-id-1',
--     'app-key-1',
--     'app-secret-1',
--     100,
--     1,
--     1,
--     100,
--     100,
--     100,
--     '[]',
--     0
-- );

-- 脚本执行完成提示
-- SELECT 'LiteSQL数据库初始化完成' AS message;