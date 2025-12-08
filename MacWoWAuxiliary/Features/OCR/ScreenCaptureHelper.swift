//
//  ScreenCaptureHelper.swift
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

import Foundation
import CoreGraphics
import AppKit

/// 屏幕截图辅助类
/// 封装屏幕截图功能，处理弃用 API 的警告
class ScreenCaptureHelper {
    
    /// 截取主屏幕
    /// - Returns: 屏幕截图的 CGImage
    static func captureMainScreen() -> CGImage? {
        guard let screen = NSScreen.main else {
            print("⚠️ 无法获取主屏幕")
            return nil
        }
        
        let screenRect = screen.frame
        print("📐 屏幕尺寸: \(Int(screenRect.width))x\(Int(screenRect.height))")
        
        // 使用 CGWindowListCreateImage 截取屏幕
        // 虽然这个 API 被标记为弃用，但它仍然是最简单可靠的方案
        // Apple 建议使用 ScreenCaptureKit，但那需要 macOS 12.3+ 且配置复杂
        let cgImage = CGWindowListCreateImage(
            screenRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        )
        
        if let image = cgImage {
            let width = image.width
            let height = image.height
            print("✅ 屏幕截图成功: \(width)x\(height)")
            
            // 检查是否是空白图片
            if width == 0 || height == 0 {
                print("❌ 截图尺寸为 0，可能是权限问题")
                print("⚠️ 请在 系统设置 -> 隐私与安全性 -> 屏幕录制 中授予权限")
                return nil
            }
            
            // 检查图片数据
            if let dataProvider = image.dataProvider,
               let data = dataProvider.data as Data? {
                print("📊 图片数据大小: \(data.count) 字节")
                
                // 检查是否全是空白数据
                let isBlank = data.allSatisfy { $0 == 0 || $0 == 255 }
                if isBlank {
                    print("⚠️ 截图内容为空白，可能是权限问题")
                    print("💡 解决方法:")
                    print("   1. 打开 系统设置 -> 隐私与安全性 -> 屏幕录制")
                    print("   2. 找到本应用并勾选")
                    print("   3. 重启应用")
                }
            }
        } else {
            print("❌ 屏幕截图失败 - 返回 nil")
            print("⚠️ 可能原因:")
            print("   1. 没有屏幕录制权限")
            print("   2. 系统安全设置阻止")
            print("💡 请在 系统设置 -> 隐私与安全性 -> 屏幕录制 中授予权限")
        }
        
        return cgImage
    }
    
    /// 截取指定窗口
    /// - Parameter windowID: 窗口 ID
    /// - Returns: 窗口截图的 CGImage
    static func captureWindow(windowID: CGWindowID) -> CGImage? {
        let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.bestResolution, .boundsIgnoreFraming]
        )
        
        return cgImage
    }
    
    /// 截取指定区域
    /// - Parameter rect: 要截取的区域
    /// - Returns: 区域截图的 CGImage
    static func captureRect(_ rect: CGRect) -> CGImage? {
        let cgImage = CGWindowListCreateImage(
            rect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        )
        
        return cgImage
    }
}
