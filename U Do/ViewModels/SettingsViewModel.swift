//
//  SettingsViewModel.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    
    @Published var timeSecond: Int {
        didSet {
            UserDefaults.standard.set(timeSecond, forKey: "timeInterval")
            updateRotationTimer()
            print("Time setting to: \(timeSecond)")
            saveChanges()
        }
    
    }
    
    @Published var priorityColor: String {
        didSet {
            UserDefaults.standard.set(priorityColor, forKey: "priorityColor")
        }
    }
    
    @Published var priorityEmoji: String {
        didSet {
            UserDefaults.standard.set(priorityEmoji, forKey: "priorityEmoji")
        }
    }
    
    var settingsWindow: NSWindow?
    
    @Published var temporaryTimeSecond: Double = 1.0
    weak var timer: Timer?
    
    var menuWindow: NSWindow? // Add a reference to MenuView's window
    
    private init() {
            // Load saved time interval or use default
            timeSecond = UserDefaults.standard.integer(forKey: "timeInterval")
            priorityColor = UserDefaults.standard.string(forKey: "priorityColor") ?? "Color_1"
            priorityEmoji = UserDefaults.standard.string(forKey: "priorityEmoji") ?? "🔴"
            if timeSecond == 0 { timeSecond = 3 }
            updateRotationTimer()
            
        }
    

    func saveChanges() {
        NotificationCenter.default.post(
            name: NSNotification.Name("UpdateTaskRotation"),
            object: nil
        )
        print("Save Changes(t): \(timeSecond)")
        
        NotificationCenter.default.post(
            name: NSNotification.Name("UpdatePriorityColor"),
            object: nil
        )
        print("Save Changes(c): \(priorityColor)")
        
        NotificationCenter.default.post(
           name: NSNotification.Name("UpdatePriorityEmoji"),
           object: nil
       )
        print("Save Changes(e): \(priorityEmoji)")
        
        
    
    }
    
    func closeWindow() {
        settingsWindow?.close()
        settingsWindow = nil
        NSWindow().isReleasedWhenClosed = true
    }
    
    private func updateRotationTimer() {
           // Invalidate existing timer
           timer?.invalidate()
           
           // Create new timer with updated interval
           timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeSecond), repeats: true) { _ in
               if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                   appDelegate.rotateTask()
               }
           }
       }
   }
    
    






