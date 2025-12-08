//
//  ContentView.swift
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

import SwiftUI
import Carbon
import IOKit.pwr_mgt
internal import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var menuBarManager: MenuBarManager
    @StateObject private var ocrManager = OCRManager()
    
    @State private var timerValue: String = "15"
    @State private var keySequence: String = "wwadss1122"
    @State private var useRandomMode: Bool = true
    @State private var currentActionMode: String = ""
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    @State private var statusMessage: String = ""
    @State private var executionCount: Int = 0
    @State private var nextExecutionTime: Date?
    @State private var updateTimer: Timer?
    @State private var searchText: String = ""
    @State private var scanInterval: String = "1"
    @State private var clickDelay: String = "0.5"
    @State private var clickResultMessage: String = ""
    @State private var selectedTab: Int = 0
    @State private var loopTimer: Timer?
    @State private var savedSearchTextBase64: String = ""
    @State private var selectedImagePath: String = ""
    @State private var showImagePicker: Bool = false
    private var assertionID: IOPMAssertionID = 0
    
    init(menuBarManager: MenuBarManager) {
        self.menuBarManager = menuBarManager
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 键盘输入标签页
            keyboardInputView
                .tabItem {
                    Label("键盘输入", systemImage: "keyboard")
                }
                .tag(0)
            
            // OCR 识别标签页
            ocrRecognitionView
                .tabItem {
                    Label("OCR识别", systemImage: "text.viewfinder")
                }
                .tag(1)
        }
        .frame(minWidth: 500, minHeight: 450)
        .onAppear {
            setupMenuBarCallbacks()
        }
    }
    
    // MARK: - 键盘输入视图
    var keyboardInputView: some View {
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
                HStack {
                    Text("操作模式:")
                        .font(.headline)
                    Toggle("智能防挂机", isOn: $useRandomMode)
                        .toggleStyle(.switch)
                        .disabled(isRunning)
                }
                
                if !useRandomMode {
                    TextField("请输入按键序列，如: wwaass12", text: $keySequence)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .disabled(isRunning)
                    Text("支持字母、数字，空格用 space 表示")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("✨ 智能模式：随机移动+技能释放，模拟真人操作")
                        .font(.caption)
                        .foregroundColor(.green)
                    if !currentActionMode.isEmpty {
                        Text("当前动作: \(currentActionMode)")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                }
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
    }
    
    // MARK: - OCR 识别视图
    var ocrRecognitionView: some View {
        VStack(spacing: 15) {
            // 标题
            VStack(spacing: 5) {
                Text("OCR 文字识别与点击")
                    .font(.title)
                    .fontWeight(.bold)
                Text("自动识别屏幕文字并模拟点击")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 参数设置 - 横向布局
            VStack(spacing: 10) {
                // 第一行：循环间隔 + 点击延迟
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("循环间隔 (秒)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("1-5", text: $scanInterval)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            .disabled(ocrManager.isScanning)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("点击延迟 (秒)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("0.5", text: $clickDelay)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                
                // 第二行：查找文字
                VStack(alignment: .leading, spacing: 5) {
                    Text("查找文字")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("输入要查找的文字，多个用 ; 分隔", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 400)
                }
            }
            .padding(.horizontal, 10)
            
            // 状态和结果 - 横向布局
            HStack(alignment: .top, spacing: 15) {
                // 左侧：状态信息
                VStack(alignment: .leading, spacing: 8) {
                    if ocrManager.isScanning {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.6)
                            Text("扫描中...")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // 显示选择的图片
                    if !selectedImagePath.isEmpty {
                        HStack {
                            Text("📸")
                                .font(.caption)
                            Text(URL(fileURLWithPath: selectedImagePath).lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.purple)
                                .lineLimit(1)
                        }
                    }
                    
                    if !clickResultMessage.isEmpty {
                        Text(clickResultMessage)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(2)
                    }
                }
                .frame(minWidth: 200, alignment: .leading)
                
                Spacer()
                
                // 右侧：识别结果
                if !ocrManager.foundTextLocations.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("识别结果 (\(ocrManager.foundTextLocations.count))")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(ocrManager.foundTextLocations.prefix(5)) { location in
                                    Text("• \(location.text)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(height: 60)
                    }
                    .frame(width: 150)
                }
            }
            .frame(height: 70)
            .padding(.horizontal, 10)
            
            // 控制按钮
            VStack(spacing: 10) {
                // 主要操作按钮 - 开始和停止
                HStack(spacing: 15) {
                    Button(ocrManager.isScanning ? "⏸ 停止" : "▶️ 开始") {
                        // 检查是否有输入（文字或图片）
                        let hasInput = !searchText.isEmpty || !selectedImagePath.isEmpty
                        
                        if hasInput {
                            if ocrManager.isScanning {
                                // 停止循环 - 解码还原文字到 UI
                                ocrManager.stopScanning()
                                loopTimer?.invalidate()
                                loopTimer = nil
                                
                                // 从 Base64 还原文字到输入框
                                if !savedSearchTextBase64.isEmpty {
                                    searchText = decodeFromBase64(savedSearchTextBase64)
                                    savedSearchTextBase64 = ""
                                }
                                
                                clickResultMessage = "⏸ 已停止"
                            } else {
                                // 开始循环查找和点击
                                if let interval = Double(scanInterval), interval > 0 {
                                    // 如果是图片模式，先识别图片
                                    if !selectedImagePath.isEmpty {
                                        let manager = ocrManager
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            manager.performOCROnImage(at: selectedImagePath)
                                        }
                                    }
                                    
                                    // 保存原始文字
                                    savedSearchTextBase64 = encodeToBase64(searchText)
                                    
                                    // 保存当前要查找的文字（用于闭包）
                                    let currentSearchText = searchText
                                    
                                    // 将输入框内容替换为 Base64 编码
                                    searchText = savedSearchTextBase64
                                    
                                    ocrManager.startScanning(interval: interval)
                                    // 日志中也使用 Base64 编码
                                    let source = selectedImagePath.isEmpty ? "屏幕" : "图片"
                                    clickResultMessage = "▶️ 开始循环 [\(savedSearchTextBase64)] - \(source)模式，间隔 \(interval) 秒"
                                    
                                    // 预先编码和保存引用（避免闭包中的问题）
                                    let encodedSearchText = encodeToBase64(currentSearchText)
                                    let manager = ocrManager
                                    
                                    // 设置定时器，每次扫描后尝试点击
                                    loopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                                        if !manager.isScanning {
                                            timer.invalidate()
                                            return
                                        }
                                        
                                        let success = manager.findAndClick(currentSearchText)
                                        if success {
                                            // 找到并点击，但继续循环（日志中也用 Base64）
                                            DispatchQueue.main.async {
                                                clickResultMessage = "✅ 已点击 [\(encodedSearchText)]，继续循环中..."
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ocrManager.isScanning ? .red : .green)
                    .disabled(searchText.isEmpty && selectedImagePath.isEmpty)
                }
                
                // 清除和重置按钮
                HStack(spacing: 15) {
                    Button("🖼️ 识别图片") {
                        selectImageFile()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🗑️ 清除") {
                        clickResultMessage = ""
                        searchText = ""
                        selectedImagePath = ""
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🔄 重置") {
                        scanInterval = "1"
                        clickDelay = "0.5"
                        searchText = ""
                        selectedImagePath = ""
                        clickResultMessage = ""
                    }
                    .buttonStyle(.bordered)
                    
                    Button("📂 打开截图") {
                        ocrManager.openTmpDirectory()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Divider()
            
            // 底部提示 - 横向布局
            HStack(spacing: 10) {
                Text("💡")
                    .font(.caption)
                VStack(alignment: .leading, spacing: 3) {
                    Text("▶️ 开始：输入文字或选择图片后，点击开始自动循环查找并点击")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack(spacing: 10) {
                        Text("⚠️ 截图空白？需要授予屏幕录制权限")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        if !ocrManager.tmpDirectoryPath.isEmpty {
                            Text("📸 截图: MacWoWAuxiliary/tmp/")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .padding(30)
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
        
        isRunning = true
        executionCount = 0
        
        // 更新菜单栏状态
        menuBarManager.setRunning(true)
        
        // 防止系统休眠
        preventSleep()
        
        // 执行第一次操作
        scheduleNextAction(baseMinutes: minutes)
    }
    
    /// 调度下一次操作（带随机时间波动）
    func scheduleNextAction(baseMinutes: Double) {
        guard isRunning else { return }
        
        // 计算下次执行时间：基础时间 ± 20% 随机波动
        let randomFactor = Double.random(in: 0.8...1.2)
        let actualMinutes = baseMinutes * randomFactor
        let seconds = actualMinutes * 60
        
        nextExecutionTime = Date().addingTimeInterval(seconds)
        updateStatusMessage(minutes: baseMinutes)
        
        // 使用 DispatchQueue 替代 Timer，避免累积误差
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            guard self.isRunning else { return }
            
            self.executionCount += 1
            
            // 在后台线程执行按键操作
            DispatchQueue.global(qos: .userInitiated).async {
                self.simulateKeyPress()
                
                // 操作完成后调度下一次
                DispatchQueue.main.async {
                    self.scheduleNextAction(baseMinutes: baseMinutes)
                }
            }
        }
        
        // 每秒更新一次状态消息
        if updateTimer == nil {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.updateStatusMessage(minutes: baseMinutes)
            }
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
        if useRandomMode {
            // 智能防挂机模式
            executeRandomAction()
        } else {
            // 传统模式：按固定序列
            let keys = convertStringToKeys(keySequence)
            simulateKeyPressSequence(keys: keys)
        }
    }
    
    /// 执行随机动作（智能防挂机）
    func executeRandomAction() {
        // 定义多种移动模式（4-5个按键组合）
        let movementPatterns: [[String]] = [
            // 前进系列
            ["w", "w", "w", "space"],           // 向前走+跳跃
            ["w", "w", "d", "w"],               // 向前+右转+前进
            ["w", "a", "w", "w"],               // 向前+左转+前进
            ["w", "w", "space", "w"],           // 前进+跳+前进
            
            // 后退系列
            ["s", "s", "s", "space"],           // 后退+跳跃
            ["s", "a", "s", "s"],               // 后退+左转+后退
            ["s", "d", "s", "s"],               // 后退+右转+后退
            
            // 左右移动系列
            ["a", "a", "space", "a"],           // 左移+跳+左移
            ["d", "d", "space", "d"],           // 右移+跳+右移
            ["a", "w", "a", "w"],               // 左前组合移动
            ["d", "w", "d", "w"],               // 右前组合移动
            
            // 复杂组合
            ["w", "space", "d", "w", "w"],      // 前跳右转前进
            ["w", "space", "a", "w", "w"],      // 前跳左转前进
            ["w", "d", "space", "w"],           // 前右跳前
            ["w", "a", "space", "w"],           // 前左跳前
            ["s", "space", "a", "s"],           // 后跳左后
            ["s", "space", "d", "s"],           // 后跳右后
            
            // 原地跳跃+转向
            ["space", "a", "a", "space"],       // 跳+左转+跳
            ["space", "d", "d", "space"],       // 跳+右转+跳
            ["space", "w", "w", "space"],       // 跳+前进+跳
        ]
        
        // 随机选择一个移动模式
        let selectedPattern = movementPatterns.randomElement() ?? ["w", "w", "w", "space"]
        
        // 随机决定是否释放技能（40%概率，提高一点）
        let shouldUseSkill = Double.random(in: 0...1) < 0.4
        let skillKeys = shouldUseSkill ? ["1", "2"].randomElement().map { [$0] } ?? [] : []
        
        // 组合动作
        var actionSequence = selectedPattern + skillKeys
        
        // 更新当前动作显示
        let patternDesc = selectedPattern.map { $0 == "space" ? "跳" : $0.uppercased() }.joined()
        let skillDesc = skillKeys.isEmpty ? "" : "+技能\(skillKeys[0])"
        DispatchQueue.main.async {
            self.currentActionMode = "\(patternDesc)\(skillDesc)"
        }
        
        print("🎮 执行动作: \(patternDesc)\(skillDesc)")
        
        // 执行动作序列
        for (index, key) in actionSequence.enumerated() {
            guard let keyCode = getKeyCode(for: key.lowercased()) else {
                print("不支持的按键: \(key)")
                continue
            }
            
            // 按下键
            let eventSource = CGEventSource(stateID: .hidSystemState)
            if let keyDownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true) {
                keyDownEvent.flags = []
                keyDownEvent.post(tap: .cgSessionEventTap)
            }
            
            // 按住约1秒（0.9-1.1秒随机）
            let holdDuration = Double.random(in: 0.9...1.1)
            Thread.sleep(forTimeInterval: holdDuration)
            
            // 释放键
            if let keyUpEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false) {
                keyUpEvent.flags = []
                keyUpEvent.post(tap: .cgSessionEventTap)
            }
            
            // 按键之间的间隔（0.1-0.3秒随机）
            if index < actionSequence.count - 1 {
                let interval = Double.random(in: 0.1...0.3)
                Thread.sleep(forTimeInterval: interval)
            }
            
            print("✅ 按键 \(key.uppercased()) 完成")
        }
        
        print("🎯 动作序列完成")
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
    
    /// 模拟键盘按键输入（传统模式）
    /// - Parameters:
    ///   - keys: 要模拟的按键字符数组，支持 a-z, 0-9 等
    ///   - count: 每个按键的按压次数，默认为 1
    func simulateKeyPressSequence(keys: [String], count: Int = 1) {
        for (index, key) in keys.enumerated() {
            guard let keyCode = getKeyCode(for: key.lowercased()) else {
                print("不支持的按键: \(key)")
                continue
            }
            
            for _ in 1...count {
                // 创建事件源（使用 HID 系统状态）
                let eventSource = CGEventSource(stateID: .hidSystemState)
                
                // 按下键 - 使用 cgSessionEventTap 以支持游戏
                if let keyDownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true) {
                    // 设置事件标志，确保游戏能识别
                    keyDownEvent.flags = []
                    keyDownEvent.post(tap: .cgSessionEventTap)
                }
                
                // 短暂延迟，模拟真实按键时长（50ms）
                Thread.sleep(forTimeInterval: 0.05)
                
                // 释放键
                if let keyUpEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false) {
                    keyUpEvent.flags = []
                    keyUpEvent.post(tap: .cgSessionEventTap)
                }
                
                // 按键之间的短暂延迟（50ms），防止输入过快
                Thread.sleep(forTimeInterval: 0.05)
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
    
    // MARK: - Base64 编码解码
    func encodeToBase64(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }
    
    func decodeFromBase64(_ base64: String) -> String {
        guard let data = Data(base64Encoded: base64),
              let text = String(data: data, encoding: .utf8) else { return "" }
        return text
    }
    
    // MARK: - 图片选择
    func selectImageFile() {
        let panel = NSOpenPanel()
        panel.title = "选择要识别的图片"
        panel.message = "请选择一张包含文字的图片，点击开始后将循环识别"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .heic, .tiff, .bmp]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                selectedImagePath = url.path
                clickResultMessage = "📸 已选择图片: \(url.lastPathComponent)，点击 ▶️ 开始 按钮开始循环"
            }
        }
    }
}

#Preview {
    ContentView(menuBarManager: MenuBarManager())
}
