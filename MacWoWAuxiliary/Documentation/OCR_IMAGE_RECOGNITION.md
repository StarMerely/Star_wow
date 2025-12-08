# OCR 图片识别功能

## 📸 功能概述

除了识别屏幕截图，OCR 功能现在还支持识别指定的图片文件。

---

## ✨ 支持的图片格式

- ✅ **PNG** (.png)
- ✅ **JPEG** (.jpg, .jpeg)
- ✅ **HEIC** (.heic) - Apple 照片格式
- ✅ **TIFF** (.tiff, .tif)
- ✅ **BMP** (.bmp)

---

## 🎯 使用方法

### 方法 1: 通过 UI 界面

1. **打开 OCR 标签页**
   ```
   点击 "OCR 识别" 标签
   ```

2. **点击识别图片按钮**
   ```
   点击 "🖼️ 识别图片" 按钮
   ```

3. **选择图片文件**
   ```
   在文件选择对话框中选择要识别的图片
   支持的格式: PNG, JPEG, HEIC, TIFF, BMP
   ```

4. **查看识别结果**
   ```
   识别完成后，结果会显示在右侧的识别结果列表中
   可以看到识别到的所有文字
   ```

5. **查找并点击**
   ```
   输入要查找的文字
   点击 "🔍 查找并点击" 按钮
   ```

---

### 方法 2: 通过代码调用

```swift
let ocrManager = OCRManager()

// 识别图片文件
let imagePath = "/Users/username/Desktop/screenshot.png"
let success = ocrManager.performOCROnImage(at: imagePath)

if success {
    print("图片识别成功")
    
    // 查看识别结果
    for location in ocrManager.foundTextLocations {
        print("文字: \(location.text)")
        print("置信度: \(location.confidence)")
        print("位置: \(location.bounds)")
    }
    
    // 查找并点击
    let clicked = ocrManager.findAndClick("确定")
    print("点击结果: \(clicked)")
}
```

---

## 📊 完整工作流程

### 场景 1: 识别保存的截图

```
1. 之前截取的屏幕保存在 ~/Documents/tmp/screenshot_xxx.png
2. 点击 "🖼️ 识别图片"
3. 选择该截图文件
4. 查看识别结果
5. 输入要查找的文字，如 "领取"
6. 点击 "🔍 查找并点击"
```

### 场景 2: 识别游戏截图

```
1. 游戏中截图保存到桌面
2. 点击 "🖼️ 识别图片"
3. 选择桌面上的截图
4. 查看识别到的所有文字
5. 输入要查找的文字，如 "确定;取消"
6. 点击 "🔍 查找并点击" 依次点击
```

### 场景 3: 批量识别

```swift
let imagePaths = [
    "/path/to/image1.png",
    "/path/to/image2.png",
    "/path/to/image3.png"
]

for path in imagePaths {
    ocrManager.performOCROnImage(at: path)
    
    // 等待识别完成
    Thread.sleep(forTimeInterval: 1.0)
    
    // 查找并点击
    ocrManager.findAndClick("领取")
}
```

---

## 🔍 API 说明

### performOCROnImage(at:)

识别指定图片文件中的文字。

**参数**:
- `imagePath: String` - 图片文件的完整路径

**返回值**:
- `Bool` - 是否成功加载并识别图片

**示例**:
```swift
let success = ocrManager.performOCROnImage(at: "/Users/star/Desktop/test.png")
```

---

## 💡 使用技巧

### 1. 图片质量要求

**最佳效果**:
- ✅ 清晰的文字
- ✅ 高分辨率图片
- ✅ 良好的对比度
- ✅ 标准字体

**可能识别不准**:
- ⚠️ 模糊的图片
- ⚠️ 低分辨率
- ⚠️ 艺术字体
- ⚠️ 手写文字

### 2. 文字大小

- **推荐**: 12pt 以上的文字
- **最小**: 8pt（可能不准确）
- **最大**: 无限制

### 3. 图片来源

**支持的来源**:
- ✅ 屏幕截图
- ✅ 相机拍摄
- ✅ 扫描文档
- ✅ 网页截图
- ✅ 游戏截图

---

## 🆚 屏幕识别 vs 图片识别

| 特性 | 屏幕识别 | 图片识别 |
|------|---------|---------|
| **触发方式** | 自动截屏 | 手动选择文件 |
| **实时性** | 实时 | 静态 |
| **保存** | 自动保存到 tmp | 不保存 |
| **适用场景** | 实时监控 | 离线分析 |
| **速度** | 快 | 快 |

---

## 📝 注意事项

### 1. 文件路径

- ✅ 使用完整的绝对路径
- ✅ 确保文件存在
- ✅ 确保有读取权限

```swift
// ✅ 正确
let path = "/Users/star/Desktop/screenshot.png"

// ❌ 错误 - 相对路径
let path = "~/Desktop/screenshot.png"

// ✅ 正确 - 展开波浪号
let path = NSString(string: "~/Desktop/screenshot.png").expandingTildeInPath
```

### 2. 文件格式

- ✅ 确保文件格式正确
- ✅ 文件扩展名与实际格式匹配
- ✅ 文件未损坏

### 3. 内存使用

- ⚠️ 大图片会占用更多内存
- ⚠️ 批量识别时注意内存管理
- ✅ 识别完成后结果会自动更新

---

## 🎮 实际应用示例

### 示例 1: 识别游戏任务截图

```swift
// 1. 选择任务截图
ocrManager.performOCROnImage(at: "/Users/star/Desktop/quest.png")

// 2. 等待识别完成（异步）
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    // 3. 查找任务按钮
    let found = ocrManager.findAndClick("接受任务")
    print("任务按钮: \(found ? "已点击" : "未找到")")
}
```

### 示例 2: 识别对话框

```swift
// 识别对话框截图
ocrManager.performOCROnImage(at: "/Users/star/Desktop/dialog.png")

// 查找并点击多个按钮
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    let result = ocrManager.findAndClickMultiple("确定;取消;关闭", delayBetweenClicks: 0.5)
    print("点击了 \(result.success)/\(result.total) 个按钮")
}
```

### 示例 3: 批量处理截图

```swift
let screenshots = [
    "screenshot_001.png",
    "screenshot_002.png",
    "screenshot_003.png"
]

for (index, filename) in screenshots.enumerated() {
    let path = "/Users/star/Desktop/\(filename)"
    
    print("识别第 \(index + 1) 张图片...")
    ocrManager.performOCROnImage(at: path)
    
    // 等待识别完成
    Thread.sleep(forTimeInterval: 1.0)
    
    // 查找特定文字
    if ocrManager.findText("领取").count > 0 {
        print("✅ 发现领取按钮")
        ocrManager.findAndClick("领取")
    }
}
```

---

## 🔧 技术实现

### 图片加载

```swift
private func loadImage(from path: String) -> CGImage? {
    guard let nsImage = NSImage(contentsOfFile: path) else {
        return nil
    }
    
    var imageRect = CGRect(x: 0, y: 0, 
                          width: nsImage.size.width, 
                          height: nsImage.size.height)
    return nsImage.cgImage(forProposedRect: &imageRect, 
                          context: nil, 
                          hints: nil)
}
```

### 文字识别

```swift
func performOCROnImage(at imagePath: String) -> Bool {
    guard let image = loadImage(from: imagePath) else {
        return false
    }
    
    recognizeText(in: image) { results in
        DispatchQueue.main.async {
            self.foundTextLocations = results
            self.lastScanResult = "识别到 \(results.count) 个文字区域"
        }
    }
    
    return true
}
```

---

## 📊 性能对比

| 操作 | 屏幕识别 | 图片识别 |
|------|---------|---------|
| **截图时间** | ~100ms | 0ms (已有图片) |
| **加载时间** | 0ms | ~50ms |
| **识别时间** | ~500ms | ~500ms |
| **总时间** | ~600ms | ~550ms |

---

## ✅ 优势

1. **离线分析**
   - 可以识别之前保存的截图
   - 不需要实时截屏

2. **灵活性**
   - 支持多种图片格式
   - 可以识别任何来源的图片

3. **批量处理**
   - 可以批量识别多张图片
   - 适合自动化脚本

4. **调试方便**
   - 可以反复识别同一张图片
   - 方便测试和调试

---

## 🎯 使用建议

### 何时使用图片识别

- ✅ 需要识别保存的截图
- ✅ 离线分析图片内容
- ✅ 批量处理多张图片
- ✅ 调试 OCR 识别效果

### 何时使用屏幕识别

- ✅ 实时监控屏幕变化
- ✅ 自动化游戏操作
- ✅ 持续循环查找点击

---

**现在 OCR 功能支持识别指定的图片文件了！** 🎉

可以通过 UI 界面选择图片，也可以通过代码直接调用 API。
