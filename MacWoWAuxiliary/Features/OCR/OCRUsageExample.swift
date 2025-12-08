//
//  OCRUsageExample.swift
//  MacWoWAuxiliary
//
//  OCR 功能使用示例
//  Created by star on 2025/12/1.
//

import Foundation
import SwiftUI

// MARK: - 使用示例

/// 示例 1: 基本的文字查找和点击
func example1_BasicFindAndClick() {
    let ocrManager = OCRManager()
    
    // 开始扫描屏幕，每秒一次
    ocrManager.startScanning(interval: 1.0)
    
    // 等待 2 秒让扫描完成
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        // 查找并点击"确定"按钮
        let success = ocrManager.findAndClick("确定")
        
        if success {
            print("成功找到并点击了'确定'按钮")
        } else {
            print("未找到'确定'按钮")
        }
        
        // 停止扫描
        ocrManager.stopScanning()
    }
}

/// 示例 2: 循环查找并点击
func example2_LoopFindAndClick() {
    let ocrManager = OCRManager()
    
    // 开始扫描
    ocrManager.startScanning(interval: 1.0)
    
    // 每 3 秒查找并点击一次"开始游戏"
    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
        let success = ocrManager.findAndClick("开始游戏")
        
        if success {
            print("已点击'开始游戏'")
        } else {
            print("未找到'开始游戏'按钮")
        }
    }
}

/// 示例 3: 查找多个文字并依次点击（旧方法）
func example3_ClickMultipleTexts() {
    let ocrManager = OCRManager()
    
    // 要依次点击的文字列表
    let textsToClick = ["开始", "确认", "继续", "完成"]
    var currentIndex = 0
    
    // 开始扫描
    ocrManager.startScanning(interval: 1.0)
    
    // 每 2 秒点击下一个
    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
        guard currentIndex < textsToClick.count else {
            timer.invalidate()
            ocrManager.stopScanning()
            print("所有文字已点击完成")
            return
        }
        
        let text = textsToClick[currentIndex]
        let success = ocrManager.findAndClick(text)
        
        if success {
            print("已点击: \(text)")
            currentIndex += 1
        } else {
            print("未找到: \(text)，将在下次重试")
        }
    }
}

/// 🆕 示例 3b: 使用分号分隔的多个文字点击（新方法）
func example3b_ClickMultipleTextsWithSemicolon() {
    let ocrManager = OCRManager()
    
    // 开始扫描
    ocrManager.startScanning(interval: 1.0)
    
    // 等待扫描完成
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        // 使用分号分隔多个文字，一次性点击
        let result = ocrManager.findAndClickMultiple("开始;确认;继续;完成", delayBetweenClicks: 1.0)
        
        print("点击完成! 成功 \(result.success)/\(result.total) 个")
        
        ocrManager.stopScanning()
    }
}

/// 示例 4: 获取所有识别到的文字
func example4_GetAllRecognizedText() {
    let ocrManager = OCRManager()
    
    // 开始扫描
    ocrManager.startScanning(interval: 1.0)
    
    // 等待扫描完成
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        print("识别到的所有文字:")
        
        for location in ocrManager.foundTextLocations {
            print("---")
            print("文字: \(location.text)")
            print("位置: x=\(location.bounds.origin.x), y=\(location.bounds.origin.y)")
            print("大小: w=\(location.bounds.width), h=\(location.bounds.height)")
            print("置信度: \(location.confidence)")
        }
        
        ocrManager.stopScanning()
    }
}

/// 示例 5: 条件点击（只在置信度高时点击）
func example5_ConditionalClick() {
    let ocrManager = OCRManager()
    
    ocrManager.startScanning(interval: 1.0)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        // 查找"确定"按钮
        let matches = ocrManager.findText("确定")
        
        // 只点击置信度大于 0.8 的结果
        if let bestMatch = matches.first(where: { $0.confidence > 0.8 }) {
            let clickPoint = CGPoint(
                x: bestMatch.bounds.midX,
                y: bestMatch.bounds.midY
            )
            ocrManager.clickAt(point: clickPoint)
            print("点击了高置信度的'确定'按钮")
        } else {
            print("未找到高置信度的'确定'按钮")
        }
        
        ocrManager.stopScanning()
    }
}

/// 示例 6: 移动鼠标到文字位置（不点击）
func example6_MoveMouseToText() {
    let ocrManager = OCRManager()
    
    ocrManager.startScanning(interval: 1.0)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        let matches = ocrManager.findText("设置")
        
        if let firstMatch = matches.first {
            let centerPoint = CGPoint(
                x: firstMatch.bounds.midX,
                y: firstMatch.bounds.midY
            )
            
            // 只移动鼠标，不点击
            ocrManager.moveMouse(to: centerPoint)
            print("鼠标已移动到'设置'按钮")
        }
        
        ocrManager.stopScanning()
    }
}

/// 示例 7: 监控特定文字出现
func example7_MonitorTextAppearance() {
    let ocrManager = OCRManager()
    let targetText = "任务完成"
    var hasAppeared = false
    
    ocrManager.startScanning(interval: 1.0)
    
    // 每秒检查一次
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        let matches = ocrManager.findText(targetText)
        
        if !matches.isEmpty && !hasAppeared {
            hasAppeared = true
            print("检测到'\(targetText)'出现在屏幕上！")
            
            // 执行相应操作
            ocrManager.findAndClick("领取奖励")
            
            // 停止监控
            timer.invalidate()
            ocrManager.stopScanning()
        }
    }
}

/// 示例 8: 结合键盘输入和 OCR
func example8_CombineKeyboardAndOCR() {
    let ocrManager = OCRManager()
    
    // 1. 先查找并点击输入框
    ocrManager.startScanning(interval: 1.0)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        // 点击"用户名"输入框
        if ocrManager.findAndClick("用户名") {
            print("已点击用户名输入框")
            
            // 等待 0.5 秒后输入文字
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 这里可以调用键盘输入功能
                print("可以在这里调用键盘输入功能")
                
                // 然后点击"登录"按钮
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ocrManager.findAndClick("登录")
                }
            }
        }
        
        ocrManager.stopScanning()
    }
}

/// 示例 9: 自定义扫描区域（截取特定应用窗口）
func example9_ScanSpecificWindow() {
    let ocrManager = OCRManager()
    
    // 截取特定应用的窗口（例如 "World of Warcraft"）
    if let windowImage = ocrManager.captureWindow(appName: "World of Warcraft") {
        print("成功截取 WoW 窗口")
        
        // 可以对这个窗口图像进行 OCR 识别
        // 注意：需要修改 OCRManager 使其支持传入自定义图像
    } else {
        print("未找到 WoW 窗口")
    }
}

/// 示例 10: 智能重试机制
func example10_SmartRetry() {
    let ocrManager = OCRManager()
    let targetText = "开始战斗"
    let maxRetries = 10
    var retryCount = 0
    
    ocrManager.startScanning(interval: 1.0)
    
    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
        retryCount += 1
        
        let success = ocrManager.findAndClick(targetText)
        
        if success {
            print("成功找到并点击'\(targetText)'")
            timer.invalidate()
            ocrManager.stopScanning()
        } else if retryCount >= maxRetries {
            print("重试 \(maxRetries) 次后仍未找到'\(targetText)'，停止尝试")
            timer.invalidate()
            ocrManager.stopScanning()
        } else {
            print("第 \(retryCount) 次尝试，未找到'\(targetText)'")
        }
    }
}

// MARK: - SwiftUI 视图示例

/// 一个完整的 SwiftUI 视图示例，展示如何集成 OCR 功能
struct OCRExampleView: View {
    @StateObject private var ocrManager = OCRManager()
    @State private var searchText: String = ""
    @State private var resultMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("OCR 功能演示")
                .font(.title)
            
            TextField("输入要查找的文字", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack(spacing: 15) {
                Button("开始扫描") {
                    ocrManager.startScanning(interval: 1.0)
                    resultMessage = "扫描中..."
                }
                .disabled(ocrManager.isScanning)
                
                Button("停止扫描") {
                    ocrManager.stopScanning()
                    resultMessage = "已停止扫描"
                }
                .disabled(!ocrManager.isScanning)
                
                Button("查找并点击") {
                    let success = ocrManager.findAndClick(searchText)
                    resultMessage = success ? "找到并点击了'\(searchText)'" : "未找到'\(searchText)'"
                }
                .disabled(searchText.isEmpty)
            }
            
            Text(resultMessage)
                .foregroundColor(.secondary)
            
            if !ocrManager.foundTextLocations.isEmpty {
                VStack(alignment: .leading) {
                    Text("识别到的文字:")
                        .font(.headline)
                    
                    ScrollView {
                        ForEach(ocrManager.foundTextLocations.prefix(20)) { location in
                            HStack {
                                Text(location.text)
                                Spacer()
                                Text(String(format: "%.2f", location.confidence))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .frame(height: 200)
                }
            }
        }
        .padding()
        .frame(width: 500, height: 500)
    }
}

// MARK: - 预览
#Preview {
    OCRExampleView()
}
