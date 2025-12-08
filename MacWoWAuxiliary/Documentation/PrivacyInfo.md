# 隐私权限配置说明

## 需要在 Info.plist 中添加的权限说明

为了使 OCR 功能正常工作，需要在项目的 `Info.plist` 文件中添加以下权限说明：

### 1. 屏幕录制权限

```xml
<key>NSScreenCaptureUsageDescription</key>
<string>需要屏幕录制权限以识别屏幕上的文字内容</string>
```

### 2. 辅助功能权限

```xml
<key>NSAppleEventsUsageDescription</key>
<string>需要辅助功能权限以模拟鼠标点击和键盘输入</string>
```

## 如何添加权限说明

### 方法 1: 通过 Xcode

1. 在 Xcode 中打开项目
2. 选择项目的 Target
3. 点击 **Info** 标签页
4. 点击 **+** 按钮添加新的键值对
5. 添加上述两个键和对应的说明文字

### 方法 2: 直接编辑 Info.plist

如果项目中有 `Info.plist` 文件，可以直接编辑添加上述内容。

## 完整的 Info.plist 示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 应用基本信息 -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    
    <!-- 隐私权限说明 -->
    <key>NSScreenCaptureUsageDescription</key>
    <string>需要屏幕录制权限以识别屏幕上的文字内容</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>需要辅助功能权限以模拟鼠标点击和键盘输入</string>
    
    <!-- 应用类别 -->
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
</dict>
</plist>
```

## 用户授权流程

### 首次运行时

1. 应用会自动请求屏幕录制权限
2. 用户需要在系统设置中手动授予权限
3. 授予权限后需要重启应用

### 手动授予权限

#### 屏幕录制权限
```
系统设置 → 隐私与安全性 → 屏幕录制 → 勾选 MacWoWAuxiliary
```

#### 辅助功能权限
```
系统设置 → 隐私与安全性 → 辅助功能 → 勾选 MacWoWAuxiliary
```

## 检查权限状态

可以在代码中检查权限状态：

```swift
import AVFoundation

// 检查屏幕录制权限
func checkScreenRecordingPermission() -> Bool {
    if #available(macOS 10.15, *) {
        let stream = CGDisplayStream(
            display: CGMainDisplayID(),
            outputWidth: 1,
            outputHeight: 1,
            pixelFormat: Int32(kCVPixelFormatType_32BGRA),
            properties: nil,
            queue: .global()
        ) { _, _, _, _ in }
        
        return stream != nil
    }
    return true
}

// 请求辅助功能权限
func requestAccessibilityPermission() -> Bool {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    return AXIsProcessTrustedWithOptions(options)
}
```

## 注意事项

1. **权限说明必须清晰**: 告诉用户为什么需要这些权限
2. **首次运行提示**: 建议在应用首次运行时显示权限说明
3. **权限检查**: 在使用功能前检查权限是否已授予
4. **用户体验**: 如果权限未授予，提供清晰的引导说明

## 安全性

- 所有数据仅在本地处理
- 不会上传任何屏幕内容到服务器
- 符合 Apple 隐私政策要求
