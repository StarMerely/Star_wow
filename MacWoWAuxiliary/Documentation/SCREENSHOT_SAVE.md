# 截图保存功能说明

## 📸 功能概述

OCR 功能现在会自动将每次截取的屏幕图像保存到临时目录，方便调试和查看识别效果。

---

## 📁 保存位置

截图保存在应用的文档目录下的 `tmp` 文件夹中：

```
~/Library/Containers/com.star.MacWoWAuxiliary/Data/Documents/tmp/
```

或者通过应用内的路径显示查看具体位置。

---

## 🎯 功能特性

### 1. 自动保存
- ✅ 每次扫描时自动保存截图
- ✅ 文件名包含时间戳，格式：`screenshot_20251201_180530.png`
- ✅ PNG 格式，保留完整质量

### 2. 自动清理
- ✅ 只保留最新的 5 张截图
- ✅ 自动删除旧的截图文件
- ✅ 避免占用过多磁盘空间

### 3. 快速访问
- ✅ 点击 **"📂 打开截图"** 按钮
- ✅ 自动在 Finder 中打开 tmp 目录
- ✅ 可以直接查看所有保存的截图

---

## 🖥️ UI 功能

### 新增按钮

**📂 打开截图**
- 位置：OCR 标签页底部
- 功能：在 Finder 中打开截图保存目录
- 快捷操作：直接查看最近的截图

### 路径显示

界面底部会显示截图保存的完整路径：
```
📸 截图保存位置: /Users/xxx/Library/Containers/.../tmp
```

---

## 📝 文件命名规则

截图文件名格式：
```
screenshot_YYYYMMDD_HHMMSS.png
```

示例：
- `screenshot_20251201_180530.png` - 2025年12月1日 18:05:30
- `screenshot_20251201_180531.png` - 2025年12月1日 18:05:31

---

## 🔧 配置说明

### 保留数量

默认保留最新的 **5 张**截图，可以在代码中修改：

```swift
// OCRManager.swift 第 116 行
cleanupOldScreenshots(in: tmpDirectory, keepCount: 5)
```

修改 `keepCount` 参数即可调整保留数量。

### 文件格式

默认保存为 **PNG** 格式，如需修改为 JPEG：

```swift
// OCRManager.swift 第 106 行
let pngData = bitmapImage.representation(using: .png, properties: [:])

// 改为：
let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
```

---

## 📊 存储空间

### 单张截图大小

- **1920x1080 分辨率**: 约 1-3 MB
- **2560x1440 分辨率**: 约 2-5 MB
- **3840x2160 (4K)**: 约 5-10 MB

### 总占用空间

保留 5 张截图的情况下：
- **Full HD**: 约 5-15 MB
- **2K**: 约 10-25 MB
- **4K**: 约 25-50 MB

---

## 🛠️ 调试用途

### 查看 OCR 识别效果

1. 开始扫描
2. 点击 "📂 打开截图"
3. 查看最新的截图
4. 对比识别结果

### 验证截图质量

- 检查截图是否清晰
- 确认文字是否可见
- 调整扫描间隔

### 问题排查

如果 OCR 识别不准确：
1. 查看保存的截图
2. 检查文字是否清晰
3. 确认是否有遮挡
4. 调整屏幕分辨率

---

## 📂 目录结构

```
Documents/
└── tmp/
    ├── screenshot_20251201_180530.png  (最新)
    ├── screenshot_20251201_180529.png
    ├── screenshot_20251201_180528.png
    ├── screenshot_20251201_180527.png
    └── screenshot_20251201_180526.png  (最旧，下次会被删除)
```

---

## 🔍 查找截图

### 方法 1: 通过应用
点击 **"📂 打开截图"** 按钮

### 方法 2: 通过 Finder
1. 打开 Finder
2. 按 `Cmd+Shift+G`
3. 输入路径（从应用底部复制）
4. 回车

### 方法 3: 通过终端
```bash
# 打开 tmp 目录
open ~/Library/Containers/com.star.MacWoWAuxiliary/Data/Documents/tmp/

# 查看所有截图
ls -lh ~/Library/Containers/com.star.MacWoWAuxiliary/Data/Documents/tmp/
```

---

## ⚙️ 高级配置

### 禁用自动保存

如果不需要保存截图，注释掉以下代码：

```swift
// OCRManager.swift 第 57 行
// saveScreenshotToTemp(screenshot)
```

### 修改保存路径

修改 `saveScreenshotToTemp` 方法中的路径：

```swift
// 使用自定义路径
let tmpDirectory = URL(fileURLWithPath: "/Users/你的用户名/Desktop/screenshots")
```

### 禁用自动清理

如果想保留所有截图：

```swift
// OCRManager.swift 第 116 行
// 注释掉这行
// cleanupOldScreenshots(in: tmpDirectory, keepCount: 5)
```

---

## 📝 日志输出

保存截图时会在控制台输出日志：

```
创建 tmp 目录: /Users/xxx/Library/Containers/.../tmp
✅ 截图已保存: /Users/xxx/Library/Containers/.../tmp/screenshot_20251201_180530.png
🗑️ 删除旧截图: screenshot_20251201_180525.png
```

---

## ⚠️ 注意事项

1. **隐私**: 截图可能包含敏感信息，使用后及时清理
2. **空间**: 定期检查磁盘空间，避免占用过多
3. **权限**: 确保应用有文件写入权限
4. **性能**: 保存截图会略微增加 CPU 和磁盘 I/O

---

## 🎯 使用建议

### 开发调试时
- ✅ 启用截图保存
- ✅ 保留较多截图（如 10 张）
- ✅ 经常查看截图质量

### 正式使用时
- ✅ 可以禁用截图保存
- ✅ 或只保留 2-3 张
- ✅ 减少性能开销

---

**截图保存功能已完成！现在可以方便地查看和调试 OCR 识别效果了！** 📸✅
