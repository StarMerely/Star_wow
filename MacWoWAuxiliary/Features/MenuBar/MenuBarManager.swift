//
//  MenuBarManager.swift
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

import SwiftUI
import AppKit
import Combine

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    @Published var isRunning: Bool = false
    
    var onStart: (() -> Void)?
    var onStop: (() -> Void)?
    var onQuit: (() -> Void)?
    
    init() {
        setupMenuBar()
    }
    
    func setupMenuBar() {
        // 确保在主线程创建状态栏图标
        if Thread.isMainThread {
            createStatusItem()
        } else {
            DispatchQueue.main.sync {
                createStatusItem()
            }
        }
    }
    
    private func createStatusItem() {
        // 创建状态栏图标
        guard statusItem == nil else { return }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem, let button = statusItem.button else {
            print("⚠️ 无法创建状态栏图标")
            return
        }
        
        // 设置图标（兼容低版本系统）
        if #available(macOS 11.0, *) {
            // macOS 11+ 使用 SF Symbols
            button.image = NSImage(systemSymbolName: "gamecontroller.fill", accessibilityDescription: "Star WoW")
            button.image?.isTemplate = true
        } else {
            // macOS 10.x 使用文本或自定义图标
            button.title = "🎮"
        }
        
        updateMenu()
    }
    
    func updateMenu() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let menu = NSMenu()
            
            // 标题
            let titleItem = NSMenuItem(title: "Star WoW 辅助工具", action: nil, keyEquivalent: "")
            titleItem.isEnabled = false
            menu.addItem(titleItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 开始按钮
            let startItem = NSMenuItem(title: "开始", action: #selector(self.startAction), keyEquivalent: "s")
            startItem.target = self
            startItem.isEnabled = !self.isRunning
            menu.addItem(startItem)
            
            // 停止按钮
            let stopItem = NSMenuItem(title: "停止", action: #selector(self.stopAction), keyEquivalent: "t")
            stopItem.target = self
            stopItem.isEnabled = self.isRunning
            menu.addItem(stopItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 状态显示
            let statusText = self.isRunning ? "运行中 🟢" : "已停止 🔴"
            let statusMenuItem = NSMenuItem(title: "状态: \(statusText)", action: nil, keyEquivalent: "")
            statusMenuItem.isEnabled = false
            menu.addItem(statusMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 退出按钮
            let quitItem = NSMenuItem(title: "退出", action: #selector(self.quitAction), keyEquivalent: "q")
            quitItem.target = self
            menu.addItem(quitItem)
            
            self.statusItem?.menu = menu
        }
    }
    
    @objc func startAction() {
        onStart?()
        isRunning = true
        updateMenu()
    }
    
    @objc func stopAction() {
        onStop?()
        isRunning = false
        updateMenu()
    }
    
    @objc func quitAction() {
        onQuit?()
        NSApplication.shared.terminate(nil)
    }
    
    func setRunning(_ running: Bool) {
        isRunning = running
        updateMenu()
    }
}
