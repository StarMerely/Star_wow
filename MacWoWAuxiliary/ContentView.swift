//
//  ContentView.swift
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

import SwiftUI
import Carbon
import IOKit.pwr_mgt

struct ContentView: View {
    @ObservedObject var menuBarManager: MenuBarManager
    
    @State private var timerValue: String = "15"
    @State private var keySequence: String = "wwadss1122"
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    @State private var statusMessage: String = ""
    @State private var executionCount: Int = 0
    @State private var nextExecutionTime: Date?
    @State private var updateTimer: Timer?
    private var assertionID: IOPMAssertionID = 0
    
    init(menuBarManager: MenuBarManager) {
        self.menuBarManager = menuBarManager
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Star WoW 辅助工具")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("定时键盘输入")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("菜单栏图标已启用 ↗️")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("定时时间 (分钟):")
                    .font(.headline)
                TextField("请输入定时时间（分钟）", text: $timerValue)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .disabled(isRunning)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("按键序列:")
                    .font(.headline)
                TextField("请输入按键序列，如: wwaass12", text: $keySequence)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .disabled(isRunning)
                Text("支持字母、数字，空格用 space 表示，例如: wwaass12space")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(isRunning ? .green : .blue)
            }
            
            if executionCount > 0 {
                Text("已执行次数: \(executionCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                Button("开始") {
                    startTimer()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunning)
                
                Button("结束") {
                    stopTimer()
                }
                .buttonStyle(.bordered)
                .disabled(!isRunning)
            }
        }
        .padding(40)
        .frame(minWidth: 300, minHeight: 250)
        .onAppear {
            setupMenuBarCallbacks()
        }
    }
    
    func setupMenuBarCallbacks() {
        menuBarManager.onStart = {
            startTimer()
        }
        
        menuBarManager.onStop = {
            stopTimer()
        }
        
        menuBarManager.onQuit = {
            stopTimer()
        }
    }
    
    func startTimer() {
        guard let minutes = Double(timerValue), minutes > 0 else {
            statusMessage = "请输入有效的时间值（分钟），例如：1.5（表示1分30秒）或 0.5（表示30秒）\n支持小数，如 0.1 表示6秒\n最小间隔为0.1分钟（6秒）"
            return
        }
        
        // 将分钟转换为秒
        let seconds = minutes * 60
        
        isRunning = true
        executionCount = 0
        nextExecutionTime = Date().addingTimeInterval(seconds)
        updateStatusMessage(minutes: minutes)
        
        // 更新菜单栏状态
        menuBarManager.setRunning(true)
        
        // 防止系统休眠
        preventSleep()
        
        // 使用 repeats: true 实现循环执行
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { _ in
            self.executionCount += 1
            self.nextExecutionTime = Date().addingTimeInterval(seconds)
            simulateKeyPress()
        }
        
        // 每秒更新一次状态消息
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateStatusMessage(minutes: minutes)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        updateTimer?.invalidate()
        updateTimer = nil
        isRunning = false
        nextExecutionTime = nil
        statusMessage = "定时器已停止，共执行了 \(executionCount) 次"
        
        // 更新菜单栏状态
        menuBarManager.setRunning(false)
        
        // 允许系统休眠
        allowSleep()
    }
    
    /// 更新状态消息，显示剩余时间
    func updateStatusMessage(minutes: Double) {
        guard let nextTime = nextExecutionTime else { return }
        
        let now = Date()
        let remaining = nextTime.timeIntervalSince(now)
        
        if remaining > 0 {
            let remainingMinutes = Int(remaining / 60)
            let remainingSeconds = Int(remaining.truncatingRemainder(dividingBy: 60))
            statusMessage = "循环执行中... 已执行 \(executionCount) 次 | 下次执行: \(remainingMinutes)分\(remainingSeconds)秒后"
        } else {
            statusMessage = "循环执行中... 已执行 \(executionCount) 次 | 即将执行..."
        }
    }
    
    /// 防止系统休眠
    func preventSleep() {
        var assertionID: IOPMAssertionID = 0
        let reason = "MacWoWAuxiliary - 定时键盘输入运行中" as CFString
        
        IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        
        print("已启用防休眠模式")
    }
    
    /// 允许系统休眠
    func allowSleep() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            print("已关闭防休眠模式")
        }
    }
    
    func simulateKeyPress() {
        // 将输入的字符串转换为按键数组
        let keys = convertStringToKeys(keySequence)
        simulateKeyPress(keys: keys)
    }
    
    /// 将字符串转换为按键数组
    /// - Parameter input: 输入的字符串
    /// - Returns: 按键字符数组
    func convertStringToKeys(_ input: String) -> [String] {
        var keys: [String] = []
        var i = input.startIndex
        
        while i < input.endIndex {
            // 检查是否是 "space" 关键字
            if input[i...].hasPrefix("space") {
                keys.append("space")
                i = input.index(i, offsetBy: 5)
            } else {
                // 单个字符
                keys.append(String(input[i]))
                i = input.index(after: i)
            }
        }
        
        return keys
    }
    
    /// 模拟键盘按键输入
    /// - Parameters:
    ///   - keys: 要模拟的按键字符数组，支持 a-z, 0-9 等
    ///   - count: 每个按键的按压次数，默认为 1
    func simulateKeyPress(keys: [String], count: Int = 1) {
        for (index, key) in keys.enumerated() {
            guard let keyCode = getKeyCode(for: key.lowercased()) else {
                print("不支持的按键: \(key)")
                continue
            }
            
            for _ in 1...count {
                // 按下键
                let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
                keyDownEvent?.post(tap: .cghidEventTap)
                
                // 释放键
                let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
                keyUpEvent?.post(tap: .cghidEventTap)
            }
            
            print("模拟键盘 \(key.uppercased()) 键输入完成")
            
            // 如果不是最后一个按键，延迟 0.5 秒
            if index < keys.count - 1 {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        print("所有按键输入完成，共 \(keys.count) 个按键")
    }
    
    /// 获取字符对应的键码
    /// - Parameter key: 按键字符
    /// - Returns: 对应的 CGKeyCode
    func getKeyCode(for key: String) -> CGKeyCode? {
        let keyMap: [String: CGKeyCode] = [
            "a": CGKeyCode(kVK_ANSI_A),
            "b": CGKeyCode(kVK_ANSI_B),
            "c": CGKeyCode(kVK_ANSI_C),
            "d": CGKeyCode(kVK_ANSI_D),
            "e": CGKeyCode(kVK_ANSI_E),
            "f": CGKeyCode(kVK_ANSI_F),
            "g": CGKeyCode(kVK_ANSI_G),
            "h": CGKeyCode(kVK_ANSI_H),
            "i": CGKeyCode(kVK_ANSI_I),
            "j": CGKeyCode(kVK_ANSI_J),
            "k": CGKeyCode(kVK_ANSI_K),
            "l": CGKeyCode(kVK_ANSI_L),
            "m": CGKeyCode(kVK_ANSI_M),
            "n": CGKeyCode(kVK_ANSI_N),
            "o": CGKeyCode(kVK_ANSI_O),
            "p": CGKeyCode(kVK_ANSI_P),
            "q": CGKeyCode(kVK_ANSI_Q),
            "r": CGKeyCode(kVK_ANSI_R),
            "s": CGKeyCode(kVK_ANSI_S),
            "t": CGKeyCode(kVK_ANSI_T),
            "u": CGKeyCode(kVK_ANSI_U),
            "v": CGKeyCode(kVK_ANSI_V),
            "w": CGKeyCode(kVK_ANSI_W),
            "x": CGKeyCode(kVK_ANSI_X),
            "y": CGKeyCode(kVK_ANSI_Y),
            "z": CGKeyCode(kVK_ANSI_Z),
            "0": CGKeyCode(kVK_ANSI_0),
            "1": CGKeyCode(kVK_ANSI_1),
            "2": CGKeyCode(kVK_ANSI_2),
            "3": CGKeyCode(kVK_ANSI_3),
            "4": CGKeyCode(kVK_ANSI_4),
            "5": CGKeyCode(kVK_ANSI_5),
            "6": CGKeyCode(kVK_ANSI_6),
            "7": CGKeyCode(kVK_ANSI_7),
            "8": CGKeyCode(kVK_ANSI_8),
            "9": CGKeyCode(kVK_ANSI_9),
            "space": CGKeyCode(kVK_Space),
            "return": CGKeyCode(kVK_Return),
            "tab": CGKeyCode(kVK_Tab),
            "escape": CGKeyCode(kVK_Escape),
            "delete": CGKeyCode(kVK_Delete)
        ]
        
        return keyMap[key]
    }
}

#Preview {
    ContentView(menuBarManager: MenuBarManager())
}
