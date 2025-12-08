# 项目结构说明

## 📁 文件夹组织

项目已重新组织为模块化结构，每个功能模块都在独立的文件夹中。

```
MacWoWAuxiliary/
├── App/                           # 应用入口
│   └── MacWoWAuxiliaryApp.swift  # 应用主入口文件
│
├── Features/                      # 功能模块
│   ├── KeyboardInput/            # 键盘输入功能
│   │   └── ContentView.swift     # 主界面（包含键盘输入和OCR UI）
│   │
│   ├── OCR/                      # OCR 识别功能
│   │   ├── OCRManager.swift      # OCR 管理类
│   │   └── OCRUsageExample.swift # OCR 使用示例
│   │
│   └── MenuBar/                  # 菜单栏功能
│       └── MenuBarManager.swift  # 菜单栏管理类
│
├── Bridge/                        # Objective-C 桥接
│   ├── ScreenCapture.h           # 屏幕截图头文件
│   ├── ScreenCapture.m           # 屏幕截图实现
│   └── MacWoWAuxiliary-Bridging-Header.h  # 桥接头文件
│
├── Resources/                     # 资源文件
│   └── Assets.xcassets/          # 图片资源
│
└── Documentation/                 # 文档
    ├── BRIDGING_HEADER_SETUP.md  # 桥接头配置指南
    ├── INSTALLATION.md           # 安装指南
    ├── MULTI_CLICK_UPDATE.md     # 多文字点击功能说明
    ├── OCR_FEATURE_SUMMARY.md    # OCR 功能总结
    ├── OCR_README.md             # OCR 功能说明
    ├── PrivacyInfo.md            # 隐私权限配置
    ├── QUICK_START.md            # 快速开始指南
    └── SCREENSHOT_SAVE.md        # 截图保存功能说明
```

---

## 📂 模块说明

### 1. App/ - 应用入口
**文件**: `MacWoWAuxiliaryApp.swift`

应用的主入口点，负责：
- 应用生命周期管理
- 初始化主窗口
- 创建 MenuBarManager

---

### 2. Features/ - 功能模块

#### 2.1 KeyboardInput/ - 键盘输入功能
**文件**: `ContentView.swift`

主界面视图，包含：
- 键盘输入功能 UI
- OCR 识别功能 UI
- TabView 切换
- 所有用户交互逻辑

**功能**:
- ⌨️ 定时键盘输入
- 🔄 循环执行
- 📊 执行统计
- 🌙 防休眠

#### 2.2 OCR/ - OCR 识别功能
**文件**:
- `OCRManager.swift` - 核心管理类
- `OCRUsageExample.swift` - 使用示例

**功能**:
- 📸 屏幕截图
- 🔍 文字识别（Vision 框架）
- 📍 文字定位
- 🖱️ 模拟点击
- 💾 截图保存

**OCRManager 主要方法**:
```swift
- startScanning(interval:)      // 开始扫描
- stopScanning()                 // 停止扫描
- findAndClick(_:)               // 查找并点击单个文字
- findAndClickMultiple(_:)       // 查找并点击多个文字
- openTmpDirectory()             // 打开截图目录
```

#### 2.3 MenuBar/ - 菜单栏功能
**文件**: `MenuBarManager.swift`

菜单栏管理类，负责：
- 创建菜单栏图标
- 管理菜单项
- 处理菜单事件
- 与主界面通信

---

### 3. Bridge/ - Objective-C 桥接

**文件**:
- `ScreenCapture.h` - 屏幕截图接口
- `ScreenCapture.m` - 屏幕截图实现
- `MacWoWAuxiliary-Bridging-Header.h` - Swift 桥接头

**用途**:
解决 Swift 中 `CGWindowListCreateImage` 弃用问题，通过 Objective-C 调用截屏 API。

**配置**:
需要在 Build Settings 中设置：
```
Objective-C Bridging Header = MacWoWAuxiliary/Bridge/MacWoWAuxiliary-Bridging-Header.h
```

---

### 4. Resources/ - 资源文件

**文件夹**: `Assets.xcassets/`

包含：
- 应用图标
- 菜单栏图标
- 其他图片资源

---

### 5. Documentation/ - 文档

所有项目文档，包括：

| 文档 | 说明 |
|------|------|
| `BRIDGING_HEADER_SETUP.md` | Objective-C 桥接配置指南 |
| `INSTALLATION.md` | 安装和配置指南 |
| `MULTI_CLICK_UPDATE.md` | 多文字点击功能说明 |
| `OCR_FEATURE_SUMMARY.md` | OCR 功能完整总结 |
| `OCR_README.md` | OCR 功能详细说明 |
| `PrivacyInfo.md` | 隐私权限配置说明 |
| `QUICK_START.md` | 5 分钟快速上手 |
| `SCREENSHOT_SAVE.md` | 截图保存功能说明 |

---

## 🔧 Xcode 配置更新

### 重要：更新 Bridging Header 路径

由于文件移动，需要更新 Xcode 中的 Bridging Header 路径：

1. 选择项目 Target
2. Build Settings → 搜索 "Bridging"
3. 更新 **Objective-C Bridging Header** 为：
   ```
   MacWoWAuxiliary/Bridge/MacWoWAuxiliary-Bridging-Header.h
   ```

### 文件引用

Xcode 会自动更新文件引用，但如果遇到问题：
1. 删除红色的文件引用
2. 重新添加文件到项目
3. 确保文件在正确的 Target 中

---

## 📝 导入路径

由于文件移动，导入语句保持不变（Swift 使用模块导入）：

```swift
// 仍然可以直接使用
import SwiftUI

// 类之间的引用不需要修改
let ocrManager = OCRManager()
let menuBarManager = MenuBarManager()
```

---

## 🎯 模块依赖关系

```
App (MacWoWAuxiliaryApp)
  └── Features/KeyboardInput (ContentView)
        ├── Features/OCR (OCRManager)
        │     └── Bridge (ScreenCapture)
        └── Features/MenuBar (MenuBarManager)
```

**依赖说明**:
- `ContentView` 使用 `OCRManager` 和 `MenuBarManager`
- `OCRManager` 使用 `ScreenCapture`（通过桥接）
- `MenuBarManager` 与 `ContentView` 双向通信

---

## 🚀 开发建议

### 添加新功能

1. **创建新模块文件夹**
   ```bash
   mkdir Features/NewFeature
   ```

2. **添加功能文件**
   ```bash
   touch Features/NewFeature/NewFeatureManager.swift
   ```

3. **在 ContentView 中集成**
   ```swift
   @StateObject private var newFeatureManager = NewFeatureManager()
   ```

### 文档管理

所有新文档放在 `Documentation/` 文件夹中，保持项目根目录整洁。

---

## 📊 文件统计

| 类型 | 数量 | 位置 |
|------|------|------|
| Swift 文件 | 5 | App/, Features/ |
| Objective-C 文件 | 2 | Bridge/ |
| 头文件 | 2 | Bridge/ |
| 文档文件 | 8 | Documentation/ |
| 资源文件 | 1 | Resources/ |

---

## ✅ 优势

### 1. 清晰的模块划分
- 每个功能独立
- 易于维护和扩展

### 2. 文档集中管理
- 所有文档在一个文件夹
- 易于查找和更新

### 3. 资源分离
- 代码和资源分开
- 便于资源管理

### 4. 桥接代码隔离
- Objective-C 代码独立
- 不影响 Swift 代码结构

---

## 🔄 迁移完成

✅ 所有文件已移动到新位置  
✅ 文件夹结构已优化  
✅ 模块化组织完成  
⚠️ 需要更新 Xcode 中的 Bridging Header 路径

---

**项目结构重组完成！** 🎉
