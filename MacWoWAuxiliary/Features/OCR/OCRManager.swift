//
//  OCRManager.swift
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

import Foundation
import Vision
import CoreGraphics
import AppKit
import Combine

class OCRManager: ObservableObject {
    @Published var isScanning: Bool = false
    @Published var lastScanResult: String = ""
    @Published var foundTextLocations: [TextLocation] = []
    @Published var tmpDirectoryPath: String = ""
    
    private var scanTimer: Timer?
    
    struct TextLocation: Identifiable {
        let id = UUID()
        let text: String
        let bounds: CGRect
        let confidence: Float
    }
    
    /// 开始定期扫描屏幕
    /// - Parameter interval: 扫描间隔（秒）
    func startScanning(interval: TimeInterval = 1.0) {
        guard !isScanning else { return }
        
        isScanning = true
        scanTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.captureAndRecognizeScreen()
        }
        
        // 立即执行一次
        captureAndRecognizeScreen()
    }
    
    /// 停止扫描
    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isScanning = false
    }
    
    /// 抓取屏幕并识别文字（公开方法）
    func performOCR() {
        captureAndRecognizeScreen()
    }
    
    /// 识别指定图片文件中的文字
    /// - Parameter imagePath: 图片文件路径
    /// - Returns: 是否成功识别
    @discardableResult
    func performOCROnImage(at imagePath: String) -> Bool {
        guard let image = loadImage(from: imagePath) else {
            print("❌ 无法加载图片: \(imagePath)")
            return false
        }
        
        print("📸 图片模式：识别图片后将在屏幕上查找对应文字")
        
        recognizeText(in: image) { [weak self] results in
            DispatchQueue.main.async {
                // 图片模式：识别图片中的文字后，再在屏幕上查找这些文字
                print("📸 图片识别到 \(results.count) 个文字，现在在屏幕上查找...")
                
                // 截取当前屏幕
                if let screenshot = self?.captureScreen() {
                    // 在屏幕截图中识别文字
                    self?.recognizeText(in: screenshot) { screenResults in
                        DispatchQueue.main.async {
                            self?.foundTextLocations = screenResults
                            self?.lastScanResult = "屏幕识别到 \(screenResults.count) 个文字区域"
                            print("📸 图片模式：屏幕识别完成 \(screenResults.count) 个文字区域")
                            
                            // 保存标记后的截图
                            if let markedImage = self?.drawMarkersOnImage(screenshot, textLocations: screenResults) {
                                self?.saveScreenshotToTemp(markedImage)
                            }
                        }
                    }
                } else {
                    // 如果无法截屏，使用图片识别结果（但点击可能不准确）
                    self?.foundTextLocations = results
                    self?.lastScanResult = "识别到 \(results.count) 个文字区域（仅图片）"
                    print("⚠️ 无法截取屏幕，使用图片坐标（点击可能不准确）")
                }
            }
        }
        
        return true
    }
    
    /// 从文件路径加载图片
    /// - Parameter path: 图片文件路径
    /// - Returns: CGImage 对象
    private func loadImage(from path: String) -> CGImage? {
        guard let nsImage = NSImage(contentsOfFile: path) else {
            return nil
        }
        
        var imageRect = CGRect(x: 0, y: 0, width: nsImage.size.width, height: nsImage.size.height)
        return nsImage.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }
    
    /// 抓取屏幕并识别文字
    private func captureAndRecognizeScreen() {
        guard let screenshot = captureScreen() else {
            print("截屏失败")
            return
        }
        
        recognizeText(in: screenshot) { [weak self] results in
            DispatchQueue.main.async {
                self?.foundTextLocations = results
                self?.lastScanResult = "识别到 \(results.count) 个文字区域"
                print("OCR识别完成: \(results.count) 个文字区域")
                
                // 在截图上标记识别结果后再保存
                if let markedImage = self?.drawMarkersOnImage(screenshot, textLocations: results) {
                    self?.saveScreenshotToTemp(markedImage)
                } else {
                    self?.saveScreenshotToTemp(screenshot)
                }
            }
        }
    }
    
    /// 保存截图到临时目录
    /// - Parameter image: 要保存的图像
    private func saveScreenshotToTemp(_ image: CGImage) {
        // 获取项目目录
        let fileManager = FileManager.default
        
        // 获取项目根目录（动态获取）
        let tmpDirectory = getProjectTmpDirectory()
        
        // 更新 tmp 目录路径（用于 UI 显示）
        DispatchQueue.main.async {
            self.tmpDirectoryPath = tmpDirectory.path
        }
        
        // 如果 tmp 目录不存在，创建它
        if !fileManager.fileExists(atPath: tmpDirectory.path) {
            do {
                try fileManager.createDirectory(at: tmpDirectory, withIntermediateDirectories: true, attributes: nil)
                print("创建 tmp 目录: \(tmpDirectory.path)")
            } catch {
                print("创建 tmp 目录失败: \(error.localizedDescription)")
                return
            }
        }
        
        // 生成文件名（使用时间戳）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "screenshot_\(timestamp).png"
        let fileURL = tmpDirectory.appendingPathComponent(filename)
        
        // 将 CGImage 转换为 NSImage 并保存
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            print("图像转换失败")
            return
        }
        
        do {
            try pngData.write(to: fileURL)
            print("✅ 截图已保存: \(fileURL.path)")
            
            // 清理旧的截图（只保留最新的 5 张）
            cleanupOldScreenshots(in: tmpDirectory, keepCount: 5)
        } catch {
            print("保存截图失败: \(error.localizedDescription)")
        }
    }
    
    /// 清理旧的截图文件
    /// - Parameters:
    ///   - directory: 目录路径
    ///   - keepCount: 保留的文件数量
    private func cleanupOldScreenshots(in directory: URL, keepCount: Int) {
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            // 过滤出 PNG 文件
            let screenshots = files.filter { $0.pathExtension == "png" && $0.lastPathComponent.hasPrefix("screenshot_") }
            
            // 按创建时间排序
            let sortedFiles = screenshots.sorted { file1, file2 in
                guard let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate,
                      let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                    return false
                }
                return date1 > date2
            }
            
            // 删除多余的文件
            if sortedFiles.count > keepCount {
                for file in sortedFiles[keepCount...] {
                    try fileManager.removeItem(at: file)
                    print("🗑️ 删除旧截图: \(file.lastPathComponent)")
                }
            }
        } catch {
            print("清理旧截图失败: \(error.localizedDescription)")
        }
    }
    
    /// 获取项目的 tmp 目录
    /// - Returns: tmp 目录的 URL
    private func getProjectTmpDirectory() -> URL {
        // 方法 1: 尝试从 Bundle 获取资源路径
        if let bundlePath = Bundle.main.resourcePath {
            let projectPath = (bundlePath as NSString).deletingLastPathComponent
            return URL(fileURLWithPath: projectPath).appendingPathComponent("tmp")
        }
        
        // 方法 2: 使用可执行文件路径
        if let executablePath = Bundle.main.executablePath {
            let path1 = (executablePath as NSString).deletingLastPathComponent
            let path2 = (path1 as NSString).deletingLastPathComponent
            let projectPath = (path2 as NSString).deletingLastPathComponent
            return URL(fileURLWithPath: projectPath).appendingPathComponent("tmp")
        }
        
        // 方法 3: 回退到用户文档目录
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsPath.appendingPathComponent("MacWoWAuxiliary_tmp")
        }
        
        // 方法 4: 最后回退到临时目录
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MacWoWAuxiliary_tmp")
    }
    
    /// 在 Finder 中打开 tmp 目录
    func openTmpDirectory() {
        let fileManager = FileManager.default
        let tmpDirectory = getProjectTmpDirectory()
        
        print("🔍 尝试打开目录: \(tmpDirectory.path)")
        
        // 如果目录不存在，先创建
        if !fileManager.fileExists(atPath: tmpDirectory.path) {
            do {
                try fileManager.createDirectory(at: tmpDirectory, withIntermediateDirectories: true, attributes: nil)
                print("✅ 创建目录成功: \(tmpDirectory.path)")
            } catch {
                print("❌ 创建目录失败: \(error.localizedDescription)")
                return
            }
        }
        
        // 在 Finder 中打开
        let success = NSWorkspace.shared.open(tmpDirectory)
        if success {
            print("✅ 已在 Finder 中打开: \(tmpDirectory.path)")
        } else {
            print("❌ 无法打开目录: \(tmpDirectory.path)")
            
            // 尝试打开父目录
            let parentDirectory = tmpDirectory.deletingLastPathComponent()
            if NSWorkspace.shared.open(parentDirectory) {
                print("✅ 已打开父目录: \(parentDirectory.path)")
            }
        }
    }
    
    /// 截取当前屏幕
    /// - Returns: 屏幕截图
    private func captureScreen() -> CGImage? {
        // 使用 ScreenCaptureHelper 截取屏幕
        if let cgImage = ScreenCaptureHelper.captureMainScreen() {
            return cgImage
        }
        
        // 如果截图失败，返回测试图像
        print("⚠️ 屏幕截图失败，使用测试图像")
        return createTestImage()
    }
    
    /// 创建测试图像（用于调试）
    private func createTestImage() -> CGImage? {
        let size = NSSize(width: 1920, height: 1080)
        let image = NSImage(size: size)
        image.lockFocus()
        
        // 绘制白色背景和测试文字
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let text = "OCR 测试文字\n确定\n开始\n继续\n\n⚠️ 这是测试图像\n请配置 Bridging Header 以启用真实截图"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 48),
            .foregroundColor: NSColor.black
        ]
        (text as NSString).draw(at: NSPoint(x: 100, y: 100), withAttributes: attributes)
        
        image.unlockFocus()
        
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    /// 截取指定应用窗口
    /// - Parameter appName: 应用名称
    /// - Returns: 窗口截图
    func captureWindow(appName: String) -> CGImage? {
        return captureScreen()
    }
    
    /// 使用 Vision 框架识别图像中的文字
    /// - Parameters:
    ///   - image: 要识别的图像
    ///   - completion: 识别完成回调
    private func recognizeText(in image: CGImage, completion: @escaping ([TextLocation]) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR识别错误: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            
            var locations: [TextLocation] = []
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                
                let text = topCandidate.string
                let confidence = topCandidate.confidence
                
                // 转换坐标系（Vision 使用左下角为原点，需要转换为屏幕坐标）
                let boundingBox = observation.boundingBox
                let screenBounds = self.convertVisionToScreen(boundingBox, imageHeight: CGFloat(image.height))
                
                locations.append(TextLocation(
                    text: text,
                    bounds: screenBounds,
                    confidence: confidence
                ))
                
                print("识别到文字: \(text) | 置信度: \(confidence) | 位置: \(screenBounds)")
            }
            
            completion(locations)
        }
        
        // 设置识别语言（支持中文和英文）
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("执行OCR请求失败: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    /// 将 Vision 坐标系转换为屏幕坐标系
    /// - Parameters:
    ///   - visionRect: Vision 框架的矩形（左下角为原点，归一化坐标）
    ///   - imageHeight: 图像高度
    /// - Returns: 屏幕坐标系的矩形
    private func convertVisionToScreen(_ visionRect: CGRect, imageHeight: CGFloat) -> CGRect {
        guard let screen = NSScreen.main else { return .zero }
        
        let screenHeight = screen.frame.height
        let screenWidth = screen.frame.width
        
        // Vision 坐标是归一化的（0-1），左下角为原点
        // 需要转换为屏幕坐标（左上角为原点）
        let x = visionRect.origin.x * screenWidth
        let y = screenHeight - (visionRect.origin.y * screenHeight) - (visionRect.height * screenHeight)
        let width = visionRect.width * screenWidth
        let height = visionRect.height * screenHeight
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// 在图片上绘制识别结果的标记
    /// - Parameters:
    ///   - image: 原始图片
    ///   - textLocations: 识别到的文字位置
    /// - Returns: 标记后的图片
    private func drawMarkersOnImage(_ image: CGImage, textLocations: [TextLocation]) -> CGImage? {
        guard !textLocations.isEmpty else { return image }
        
        let width = image.width
        let height = image.height
        
        // 创建 NSImage
        let nsImage = NSImage(cgImage: image, size: NSSize(width: width, height: height))
        
        // 创建绘图上下文
        let targetSize = NSSize(width: width, height: height)
        let targetImage = NSImage(size: targetSize)
        
        targetImage.lockFocus()
        
        // 绘制原始图片
        nsImage.draw(in: NSRect(origin: .zero, size: targetSize))
        
        // 绘制红色标记
        NSColor.red.setStroke()
        let path = NSBezierPath()
        path.lineWidth = 4.0
        
        for location in textLocations {
            // location.bounds 是屏幕坐标，直接使用
            let bounds = location.bounds
            
            // 绘制矩形框
            let rect = NSRect(x: bounds.origin.x, 
                            y: bounds.origin.y, 
                            width: bounds.width, 
                            height: bounds.height)
            path.appendRect(rect)
            
            // 绘制文字标签
            let text = location.text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 16),
                .foregroundColor: NSColor.red,
                .backgroundColor: NSColor.white.withAlphaComponent(0.9)
            ]
            
            // 文字绘制在矩形上方
            let textPoint = NSPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.height + 2)
            (text as NSString).draw(at: textPoint, withAttributes: attributes)
        }
        
        path.stroke()
        
        targetImage.unlockFocus()
        
        // 转换回 CGImage
        var rect = CGRect(origin: .zero, size: targetSize)
        guard let result = targetImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
            print("⚠️ 无法生成标记后的图片")
            return image
        }
        
        print("✅ 已在截图上标记 \(textLocations.count) 个文字区域")
        return result
    }
    
    /// 查找包含指定文字的位置
    /// - Parameter searchText: 要查找的文字
    /// - Returns: 匹配的文字位置数组
    func findText(_ searchText: String) -> [TextLocation] {
        return foundTextLocations.filter { location in
            location.text.contains(searchText)
        }
    }
    
    /// 在指定坐标模拟鼠标点击
    /// - Parameter point: 点击坐标
    func clickAt(point: CGPoint) {
        // 创建鼠标按下事件
        guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left) else {
            print("创建鼠标按下事件失败")
            return
        }
        
        // 创建鼠标释放事件
        guard let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
            print("创建鼠标释放事件失败")
            return
        }
        
        // 发送事件
        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)
        
        print("在坐标 (\(point.x), \(point.y)) 模拟点击")
    }
    
    /// 查找文字并点击
    /// - Parameter searchText: 要查找并点击的文字
    /// - Returns: 是否成功找到并点击
    @discardableResult
    func findAndClick(_ searchText: String) -> Bool {
        let matches = findText(searchText)
        
        guard let firstMatch = matches.first else {
            print("未找到文字: \(searchText)")
            return false
        }
        
        // 点击文字区域的中心
        let centerX = firstMatch.bounds.midX
        let centerY = firstMatch.bounds.midY
        let clickPoint = CGPoint(x: centerX, y: centerY)
        
        clickAt(point: clickPoint)
        
        print("找到文字 '\(searchText)' 并点击，位置: (\(centerX), \(centerY))")
        return true
    }
    
    /// 移动鼠标到指定位置（不点击）
    /// - Parameter point: 目标坐标
    func moveMouse(to point: CGPoint) {
        guard let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) else {
            print("创建鼠标移动事件失败")
            return
        }
        
        moveEvent.post(tap: .cghidEventTap)
        print("鼠标移动到: (\(point.x), \(point.y))")
    }
    
    /// 查找并点击多个文字（使用分号分隔）
    /// - Parameters:
    ///   - searchTexts: 要查找并点击的文字，使用分号分隔，如 "确定;开始;继续"
    ///   - delayBetweenClicks: 每次点击之间的延迟（秒），默认 0.5 秒
    /// - Returns: 成功点击的文字数量和总数的元组 (成功数, 总数)
    @discardableResult
    func findAndClickMultiple(_ searchTexts: String, delayBetweenClicks: TimeInterval = 0.5) -> (success: Int, total: Int) {
        // 使用分号分割文字
        let textArray = searchTexts.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard !textArray.isEmpty else {
            print("未提供要查找的文字")
            return (0, 0)
        }
        
        var successCount = 0
        let totalCount = textArray.count
        
        print("开始查找并点击 \(totalCount) 个文字: \(textArray.joined(separator: ", "))")
        
        for (index, text) in textArray.enumerated() {
            let success = findAndClick(text)
            
            if success {
                successCount += 1
                print("[\(index + 1)/\(totalCount)] 成功点击: \(text)")
            } else {
                print("[\(index + 1)/\(totalCount)] 未找到: \(text)")
            }
            
            // 如果不是最后一个，添加延迟
            if index < textArray.count - 1 {
                Thread.sleep(forTimeInterval: delayBetweenClicks)
            }
        }
        
        print("完成! 成功点击 \(successCount)/\(totalCount) 个文字")
        return (successCount, totalCount)
    }
}
