# Bridging Header 配置指南

## 问题
Swift 代码中出现 `Cannot find 'ScreenCapture' in scope` 错误。

## 原因
Objective-C Bridging Header 还未正确配置。

---

## ✅ 解决方案

### 步骤 1: 在 Xcode 中配置 Bridging Header

1. **打开项目设置**
   - 在 Xcode 左侧文件列表中，点击最顶部的项目文件（蓝色图标）
   - 在中间区域选择 **TARGETS** 下的 **MacWoWAuxiliary**

2. **进入 Build Settings**
   - 点击顶部的 **Build Settings** 标签
   - 确保选择了 **All** 而不是 **Basic**（在搜索框下方）

3. **搜索 Bridging Header**
   - 在搜索框中输入：`bridging`
   - 找到 **Objective-C Bridging Header** 这一行

4. **设置路径**
   - 双击 **Objective-C Bridging Header** 右侧的值
   - 输入以下路径之一：
     ```
     MacWoWAuxiliary/MacWoWAuxiliary-Bridging-Header.h
     ```
     或
     ```
     $(SRCROOT)/MacWoWAuxiliary/MacWoWAuxiliary-Bridging-Header.h
     ```

5. **清理并重建**
   - 菜单栏: **Product** → **Clean Build Folder** (快捷键: Shift+Cmd+K)
   - 菜单栏: **Product** → **Build** (快捷键: Cmd+B)

---

## 📁 文件结构检查

确保以下文件都在项目中：

```
MacWoWAuxiliary/
├── ScreenCapture.h                          ✅ Objective-C 头文件
├── ScreenCapture.m                          ✅ Objective-C 实现
├── MacWoWAuxiliary-Bridging-Header.h       ✅ 桥接头文件
├── OCRManager.swift                         ✅ Swift 文件
└── ... 其他文件
```

### 验证文件是否添加到 Target

1. 在 Xcode 中选择每个文件
2. 查看右侧 **File Inspector**（文件检查器）
3. 确保 **Target Membership** 中 **MacWoWAuxiliary** 被勾选

---

## 🔍 故障排除

### 问题 1: 仍然找不到 ScreenCapture

**检查桥接头文件内容**

打开 `MacWoWAuxiliary-Bridging-Header.h`，确保内容如下：

```objective-c
#ifndef MacWoWAuxiliary_Bridging_Header_h
#define MacWoWAuxiliary_Bridging_Header_h

#import "ScreenCapture.h"

#endif
```

### 问题 2: 编译错误 "file not found"

**可能原因**: 路径不正确

**解决方案**:
1. 检查 Build Settings 中的路径
2. 尝试使用相对路径：`MacWoWAuxiliary/MacWoWAuxiliary-Bridging-Header.h`
3. 或使用绝对路径：`$(SRCROOT)/MacWoWAuxiliary/MacWoWAuxiliary-Bridging-Header.h`

### 问题 3: ScreenCapture.m 编译错误

**检查 ScreenCapture.m 是否添加到 Target**:
1. 选择 `ScreenCapture.m` 文件
2. 右侧 File Inspector → Target Membership
3. 确保 **MacWoWAuxiliary** 被勾选

---

## 🎯 快速验证

配置完成后，在 `OCRManager.swift` 中应该可以使用：

```swift
private func captureScreen() -> CGImage? {
    return ScreenCapture.captureMainScreen()?.takeRetainedValue()
}
```

如果没有红色错误，说明配置成功！

---

## 📝 配置截图位置

在 Xcode 中的位置：

```
项目导航器
  └── MacWoWAuxiliary (项目文件，蓝色图标)
        └── TARGETS
              └── MacWoWAuxiliary
                    └── Build Settings (标签页)
                          └── 搜索 "bridging"
                                └── Objective-C Bridging Header
```

---

## ⚠️ 常见错误

### 错误 1: 路径包含空格或特殊字符
❌ `MacWoWAuxiliary /MacWoWAuxiliary-Bridging-Header.h`  
✅ `MacWoWAuxiliary/MacWoWAuxiliary-Bridging-Header.h`

### 错误 2: 使用了错误的文件名
❌ `Bridging-Header.h`  
✅ `MacWoWAuxiliary-Bridging-Header.h`

### 错误 3: 文件不在正确的 Target 中
- 确保 `.m` 文件在 Target Membership 中被勾选
- `.h` 文件不需要在 Target 中

---

## ✅ 验证配置成功

配置成功后，你应该能看到：

1. **编译无错误** - 没有红色的 "Cannot find 'ScreenCapture'" 错误
2. **自动补全** - 输入 `ScreenCapture.` 时会显示方法提示
3. **运行正常** - 应用可以正常截屏

---

## 🚀 下一步

配置完成后：

1. 清理项目：Product → Clean Build Folder
2. 重新编译：Product → Build
3. 运行应用：Product → Run
4. 测试 OCR 功能

---

**如果按照以上步骤操作后仍有问题，请检查 Xcode 版本是否支持 Objective-C/Swift 混编。**
