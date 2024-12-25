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
    var popOver = NSPopover()
    var timer: Timer?
    var currentTaskIndex = 0
    let taskViewModel = TaskViewModel()

    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menuView = MenuView(viewModel: taskViewModel)
        
        setupPopover(with: menuView)
        setupStatusItem()
        rotateTask()
        startTaskRotation()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTaskRotation),
            name: NSNotification.Name("UpdateTaskRotation"),
            object: nil
        )
    }
    
    func setupPopover(with menuView: MenuView) {
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: menuView)
        popOver.contentViewController?.view.window?.makeKey()
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
        if popOver.isShown {
            popOver.performClose(sender)
        } else if let menuButton = statusItem?.button {
            popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
        }
    }
}
