# MacWoWAuxiliary

macOS 辅助工具，提供键盘输入自动化和 OCR 文字识别功能。

---

## 📁 项目结构

```
MacWoWAuxiliary/
├── App/                    # 应用入口
├── Features/               # 功能模块
│   ├── KeyboardInput/     # 键盘输入功能
│   ├── OCR/               # OCR 识别功能
│   └── MenuBar/           # 菜单栏功能
├── Bridge/                # Objective-C 桥接
├── Resources/             # 资源文件
└── Documentation/         # 完整文档
```

详细结构说明：[Documentation/PROJECT_STRUCTURE.md](Documentation/PROJECT_STRUCTURE.md)

---

## ✨ 功能特性

### ⌨️ 键盘输入自动化
- 定时键盘输入
- 循环执行
- 执行统计
- 防休眠功能

### 🔍 OCR 文字识别
- 屏幕截图
- 文字识别（支持中英文）
- 文字定位
- 自动点击
- 多文字依次点击（分号分隔）
- 截图自动保存

---

## 🚀 快速开始

查看 [Documentation/QUICK_START.md](Documentation/QUICK_START.md)

---

## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [PROJECT_STRUCTURE.md](Documentation/PROJECT_STRUCTURE.md) | 项目结构说明 |
| [QUICK_START.md](Documentation/QUICK_START.md) | 快速开始指南 |
| [INSTALLATION.md](Documentation/INSTALLATION.md) | 安装配置指南 |
| [OCR_README.md](Documentation/OCR_README.md) | OCR 功能详细说明 |
| [OCR_FEATURE_SUMMARY.md](Documentation/OCR_FEATURE_SUMMARY.md) | OCR 功能总结 |
| [MULTI_CLICK_UPDATE.md](Documentation/MULTI_CLICK_UPDATE.md) | 多文字点击功能 |
| [SCREENSHOT_SAVE.md](Documentation/SCREENSHOT_SAVE.md) | 截图保存功能 |
| [BRIDGING_HEADER_SETUP.md](Documentation/BRIDGING_HEADER_SETUP.md) | 桥接头配置 |
| [PrivacyInfo.md](Documentation/PrivacyInfo.md) | 隐私权限配置 |

---

## ⚙️ 系统要求

- macOS 10.15+
- Xcode 13.0+
- Swift 5.5+

---

## 🔧 配置

### 权限设置

需要授予以下权限：
- ✅ 屏幕录制权限
- ✅ 辅助功能权限

详见：[Documentation/PrivacyInfo.md](Documentation/PrivacyInfo.md)

### Bridging Header

如果遇到 `Cannot find 'ScreenCapture'` 错误，请配置 Bridging Header：

详见：[Documentation/BRIDGING_HEADER_SETUP.md](Documentation/BRIDGING_HEADER_SETUP.md)

---

## 💡 使用示例

### 键盘输入
```
1. 输入要发送的按键（如 "1"）
2. 设置间隔时间（如 "5" 秒）
3. 点击"开始"
```

### OCR 识别
```
1. 切换到 "OCR识别" 标签
2. 点击"开始扫描"
3. 输入要查找的文字（如 "确定"）
4. 点击"查找并点击"
```

### 多文字点击
```
输入: 确定;开始;继续
延迟: 0.5 秒
点击: 查找并点击
```

---

## 🎯 技术栈

- **SwiftUI** - 用户界面
- **Vision** - OCR 文字识别
- **CoreGraphics** - 屏幕截图和鼠标控制
- **AppKit** - macOS 原生功能
- **Objective-C** - 桥接弃用 API

---

## 📝 更新日志

### v1.0.0 (2025-12-01)
- ✅ 键盘输入自动化功能
- ✅ OCR 文字识别功能
- ✅ 多文字依次点击
- ✅ 截图自动保存
- ✅ 项目结构模块化

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可

MIT License

---

**开始使用：查看 [快速开始指南](Documentation/QUICK_START.md)** 🚀
