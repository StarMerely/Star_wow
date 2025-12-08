//
//  MacWoWAuxiliaryApp.swift
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

import SwiftUI

@main
struct MacWoWAuxiliaryApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(menuBarManager: menuBarManager)
        }
    }
}
