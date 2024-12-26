//
//  U_DoApp.swift
//  U Do
//
//  Created by yoyojun on 23/12/2024.
//

import SwiftUI

@main
@MainActor
struct U_DoApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
 
    
    var statusItem: NSStatusItem?
    var window = NSWindow()
    var timer: Timer?
    var currentTaskIndex = 0
    let taskViewModel = TaskViewModel()

    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menuView = MenuView(viewModel: taskViewModel)
        
        setupWindow(with: menuView)
        setupStatusItem()
        rotateTask()
        startTaskRotation()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTaskRotation),
            name: NSNotification.Name("UpdateTaskRotation"),
            object: nil
        )
        
        window.hidesOnDeactivate = false
            
        // Add these window behavior flags
        window.collectionBehavior = [.transient, .ignoresCycle]
        
    }
    
    func setupWindow(with menuView: MenuView) {
        let hostingView = NSHostingView(rootView: menuView)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.backgroundColor = .clear // Changed to clear
        window.isMovable = true
        window.level = .floating
        window.hasShadow = true
        
        window.titleVisibility = .hidden
        window.isOpaque = false
       
        window.titlebarAppearsTransparent = true
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 20
        hostingView.layer?.masksToBounds = true
      
        
        let monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.window.isVisible else { return }
            
            let clickLocation = event.locationInWindow
            let windowFrame = self.window.frame
            
            // Check if click is outside the window
            if !NSPointInRect(clickLocation, windowFrame) {
                self.window.orderOut(nil)
            }
        }
        
        // Store the monitor to prevent it from being deallocated
        objc_setAssociatedObject(window, "monitorKey", monitor, .OBJC_ASSOCIATION_RETAIN)
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.action = #selector(MenuButtonToggle)
    }
    
    func startTaskRotation() {
        timer?.invalidate()
        
        let interval = SettingsViewModel.shared.timeSecond
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.rotateTask()
        }
    }
    
    @objc func updateTaskRotation() {
        startTaskRotation() // This will create a new timer with the updated interval
    }
    
    public func rotateTask() {

        guard !taskViewModel.tasks.isEmpty else {
            statusItem?.button?.title = "No Tasks"
            return
        }
        
        // Function to rotate tasks and call itself after the specified time interval
        
        // Rotate through tasks
        currentTaskIndex = (currentTaskIndex + 1) % taskViewModel.tasks.count
        let task = taskViewModel.tasks[currentTaskIndex]
        var priority: Bool
        priority = task.isHighPriority
        print(priority)
    
        // Update the status item with the task title
        
        if priority {
            self.statusItem?.button?.title = "\(SettingsViewModel.shared.priorityEmoji) \(task.title)"
        } else {
            self.statusItem?.button?.title = task.title
        }

    }

    
    @objc func MenuButtonToggle(sender: AnyObject) {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            
            SettingsViewModel.shared.menuWindow = window
            
            // Position window below the status item
            if let button = statusItem?.button {
                let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
                let windowFrame = window.frame
                let x = buttonFrame.minX - (windowFrame.width - buttonFrame.width) / 2
                let y = buttonFrame.minY - windowFrame.height + window.titlebarHeightAdjustment()
                
                // Ensure the window stays within screen bounds
                if let screen = NSScreen.main {
                    let screenFrame = screen.visibleFrame
                    let adjustedX = min(max(x, screenFrame.minX), screenFrame.maxX - windowFrame.width)
                    window.setFrameOrigin(NSPoint(x: adjustedX, y: y))
                }
                NSApplication.shared.activate(ignoringOtherApps: true)
                window.makeKeyAndOrderFront(nil)
                window.makeFirstResponder(window.contentView)
            }
        }
    }
}

extension NSWindow {
    func titlebarHeightAdjustment() -> CGFloat {
        guard let contentView = self.contentView else { return 0 }
        return self.frame.height - contentView.frame.height
    }
}
