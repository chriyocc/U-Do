//
//  WindowManager.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

import SwiftUI
import AppKit

class WindowManager: NSObject {
    static let shared = WindowManager()
    
    func setupWindow() {
        if let window = NSApplication.shared.windows.first {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = true
        }
    }
}

