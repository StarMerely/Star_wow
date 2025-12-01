#!/bin/bash

# MacWoW 辅助工具构建脚本
# 用于将项目打包成可执行的 .app 文件

# ⚠️  首次运行需要授权：
#   - 系统设置 > 隐私与安全性 > 辅助功能
#   - 添加 star_wow.app

# 如果提示无法打开，运行以下命令：
#   xattr -cr ~/Desktop/star_wow.app

echo "🚀 开始构建 MacWoW 辅助工具..."

# 项目名称
PROJECT_NAME="MacWoWAuxiliary"
SCHEME_NAME="MacWoWAuxiliary"

# 构建配置
BUILD_CONFIG="Release"

# 输出目录
OUTPUT_DIR="./build"

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# 执行构建
echo "🔨 正在构建应用..."
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration "$BUILD_CONFIG" \
    clean build \
    -derivedDataPath "$OUTPUT_DIR/DerivedData"

# 检查构建是否成功
if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    
    # 复制 .app 文件到输出目录
    APP_PATH="$OUTPUT_DIR/DerivedData/Build/Products/$BUILD_CONFIG/${PROJECT_NAME}.app"
    
    if [ -d "$APP_PATH" ]; then
        # 自定义输出文件名
        OUTPUT_APP_NAME="star_wow.app"
        
        cp -R "$APP_PATH" "$OUTPUT_DIR/$OUTPUT_APP_NAME"
        echo "📦 应用已复制到: $OUTPUT_DIR/$OUTPUT_APP_NAME"
        
        # 同时复制一份到桌面
        cp -R "$APP_PATH" ~/Desktop/"$OUTPUT_APP_NAME"
        echo "📦 应用已复制到桌面: ~/Desktop/$OUTPUT_APP_NAME"
        
        echo ""
        echo "🎉 打包完成！"
        echo "应用位置："
        echo "  1. 项目目录: $OUTPUT_DIR/$OUTPUT_APP_NAME"
        echo "  2. 桌面: ~/Desktop/$OUTPUT_APP_NAME"
        echo ""
        echo "⚠️  首次运行需要授权："
        echo "  - 系统设置 > 隐私与安全性 > 辅助功能"
        echo "  - 添加 $OUTPUT_APP_NAME"
        echo ""
        echo "如果提示无法打开，运行以下命令："
        echo "  xattr -cr ~/Desktop/$OUTPUT_APP_NAME"
    else
        echo "❌ 错误：找不到构建的应用文件"
        exit 1
    fi
else
    echo "❌ 构建失败！"
    exit 1
fi
