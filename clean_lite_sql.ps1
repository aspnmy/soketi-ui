# 清理与liteSQL3无关的代码和中间文件

Write-Host "当前工作目录: $(Get-Location)"
Write-Host "开始清理与liteSQL3无关的文件和目录..."

# 定义要保留的liteSQL3相关文件
$liteSqlFiles = @(
    "Dockerfile.lite", "docker-compose.lite.yml", "composer.lite.json", ".env.lite", 
    ".gitignore", "LITESQL_INSTALL_GUIDE.md", "LITESQL_DEPLOYMENT_GUIDE.md", 
    "INIT_SQLITE.md", "SQLITE_DEPLOYMENT_GUIDE.md", "clean_lite_sql.ps1", "clean_lite_sql.sh"
)

# 清理不需要的Docker和环境配置文件
Write-Host "清理不需要的Docker和环境配置文件..."

if (Test-Path "Dockerfile" -PathType Leaf) {
    Write-Host "删除原始Dockerfile"
    Remove-Item "Dockerfile" -Force
}

if (Test-Path "docker-compose.yml" -PathType Leaf) {
    Write-Host "删除原始docker-compose.yml"
    Remove-Item "docker-compose.yml" -Force
}

if (Test-Path "composer.json" -PathType Leaf) {
    Write-Host "删除原始composer.json"
    Remove-Item "composer.json" -Force
}

if (Test-Path "composer.lock" -PathType Leaf) {
    Write-Host "删除composer.lock"
    Remove-Item "composer.lock" -Force
}

# 清理node_modules目录（如果存在）
if (Test-Path "node_modules" -PathType Container) {
    Write-Host "删除node_modules目录"
    Remove-Item "node_modules" -Recurse -Force
}

# 清理临时文件和缓存
Write-Host "清理临时文件和缓存..."
Get-ChildItem -Path . -Recurse -Directory -Filter "*.cache" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path . -Recurse -File -Filter "*.log" | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path . -Recurse -File -Filter "*.tmp" | Remove-Item -Force -ErrorAction SilentlyContinue

# 清理vendor目录（如果存在）
if (Test-Path "vendor" -PathType Container) {
    Write-Host "删除vendor目录"
    Remove-Item "vendor" -Recurse -Force
}

# 清理public/build目录中的旧文件（如果存在）
if (Test-Path "public/build" -PathType Container) {
    Write-Host "清理public/build目录"
    Get-ChildItem -Path "public/build" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 清理storage/cache目录
if (Test-Path "storage/cache" -PathType Container) {
    Write-Host "清理storage/cache目录"
    Get-ChildItem -Path "storage/cache" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 清理storage/framework目录
if (Test-Path "storage/framework" -PathType Container) {
    Write-Host "清理storage/framework目录"
    Get-ChildItem -Path "storage/framework" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 创建必要的空目录结构
Write-Host "创建必要的空目录结构..."

$requiredDirs = @(
    "storage/app", "storage/logs", "storage/cache", "storage/framework", 
    "public/build", "database", "app", "resources", "routes"
)

foreach ($dir in $requiredDirs) {
    if (-not (Test-Path $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "创建目录: $dir"
    }
}

# 提示用户这是liteSQL3分支
Write-Host ""
Write-Host "=== 已完成liteSQL3分支的清理工作 ==="
Write-Host "这个分支已优化为只包含liteSQL3相关的代码和配置。"
Write-Host "建议: 运行 'git status' 检查当前状态，然后提交更改。"
Write-Host "=== 清理完成 ==="