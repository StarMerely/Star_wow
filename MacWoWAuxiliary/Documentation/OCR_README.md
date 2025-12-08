# OCR 图像识别功能说明

## 功能概述

本应用新增了 **OCR 文字识别与自动点击** 功能，可以：

1. **定期截屏**: 每隔指定时间（如 1 秒）自动抓取屏幕
2. **文字识别**: 使用 Apple Vision 框架识别屏幕上的所有文字（支持中英文）
3. **文字定位**: 找到指定文字在屏幕上的坐标位置
4. **模拟点击**: 在找到的文字位置自动模拟鼠标点击

## 使用步骤

### 1. 授予权限

使用前必须授予以下权限：

#### 屏幕录制权限
- 打开 **系统设置** → **隐私与安全性** → **屏幕录制**
- 勾选 `MacWoWAuxiliary` 应用
- 重启应用

#### 辅助功能权限
- 打开 **系统设置** → **隐私与安全性** → **辅助功能**
- 勾选 `MacWoWAuxiliary` 应用
- 重启应用

### 2. 使用 OCR 功能

1. 打开应用，切换到 **"OCR识别"** 标签页
2. 设置 **扫描间隔**（建议 1 秒）
3. 点击 **"开始扫描"** 按钮
4. 应用会每隔指定时间自动截屏并识别文字
5. 在 **"查找文字"** 输入框中输入要查找的文字
6. 点击 **"查找并点击"** 按钮，应用会自动找到该文字并点击

## 核心功能

### OCRManager 类

#### 主要方法

```swift
// 开始定期扫描屏幕（默认 1 秒一次）
ocrManager.startScanning(interval: 1.0)

// 停止扫描
ocrManager.stopScanning()

// 查找包含指定文字的位置
let locations = ocrManager.findText("确定")

// 在指定坐标点击
ocrManager.clickAt(point: CGPoint(x: 100, y: 200))

// 查找文字并自动点击（单个）
ocrManager.findAndClick("确定")

// 🆕 查找并点击多个文字（用分号分隔）
let result = ocrManager.findAndClickMultiple("确定;开始;继续", delayBetweenClicks: 0.5)
print("成功点击 \(result.success)/\(result.total) 个文字")

// 移动鼠标到指定位置（不点击）
ocrManager.moveMouse(to: CGPoint(x: 100, y: 200))
```

### 识别结果

每次扫描后，`OCRManager` 会返回识别到的文字列表，包含：
- **文字内容**: 识别到的文字
- **坐标位置**: 文字在屏幕上的矩形区域
- **置信度**: 识别准确度（0-1）

## 技术实现

### 使用的框架

1. **Vision**: Apple 的计算机视觉框架，用于 OCR 文字识别
2. **CoreGraphics**: 用于屏幕截图和坐标转换
3. **AppKit**: 用于获取屏幕信息

### 坐标系转换

- Vision 框架使用**归一化坐标**（0-1），原点在**左下角**
- macOS 屏幕坐标原点在**左上角**
- `OCRManager` 自动处理坐标转换

### 识别语言

默认支持：
- 简体中文 (`zh-Hans`)
- 英文 (`en-US`)

可在 `OCRManager.swift` 中修改 `recognitionLanguages` 添加更多语言。

## 注意事项

1. **性能**: OCR 识别比较耗资源，建议扫描间隔不要小于 1 秒
2. **权限**: 必须授予屏幕录制和辅助功能权限，否则无法使用
3. **准确度**: 识别准确度取决于屏幕文字的清晰度和字体
4. **隐私**: 本应用所有数据仅在本地处理，不会上传到任何服务器

## 应用场景

- 自动化测试
- 游戏辅助（如自动点击特定按钮）
- 重复性操作自动化
- 屏幕内容监控

## 示例代码

### 定期查找并点击某个按钮

```swift
// 开始每秒扫描一次
ocrManager.startScanning(interval: 1.0)

// 查找并点击"开始游戏"按钮
Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
    ocrManager.findAndClick("开始游戏")
}
```

### 获取所有识别到的文字

```swift
// 扫描后获取所有文字
for location in ocrManager.foundTextLocations {
    print("文字: \(location.text)")
    print("位置: \(location.bounds)")
    print("置信度: \(location.confidence)")
}
```

## 故障排除

### 无法截屏
- 检查是否授予了屏幕录制权限
- 重启应用

### 无法点击
- 检查是否授予了辅助功能权限
- 确认目标应用在前台

### 识别不准确
- 增加扫描间隔，给识别更多时间
- 确保屏幕文字清晰可见
- 调整屏幕分辨率

## 开发者信息

- 作者: star
- 创建日期: 2025/12/1
- 框架: SwiftUI + Vision + CoreGraphics
