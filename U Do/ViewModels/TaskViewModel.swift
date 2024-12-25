//
//  TaskViewModel.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

// TaskViewModel.swift
import SwiftUI


class TaskViewModel: ObservableObject {
    

    @Published var newTaskTitle: String = ""
    @Published var isShowingAddTask = false
    @Published var newTaskText: String = ""
    @Published var isAddingNewTask: Bool = false
    @Published var currentTaskIndex = 0
    @Published var tasks: [Task] = []
        
        
    
    private let tasksKey = "savedTasks"
    
    init() {
        loadTasks()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTaskViews),
            name: NSNotification.Name("UpdateTaskRotation"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTaskViews),
            name: NSNotification.Name("UpdatePriorityColor"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTaskViews),
            name: NSNotification.Name("UpdatePriorityEmoji"),
            object: nil
        )

    }
    
    @objc private func refreshTaskViews() {
        // Force a view update by triggering objectWillChange
        objectWillChange.send()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    func addTask(title: String) {
        guard !title.isEmpty else { return }
        tasks.insert(Task(title: title), at: 0)
    }

    func deleteTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
        }
    }
    
    func editTask(_ task: Task, newTitle: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
        }
    }
    
    func addTaskFromInline() {
        if !newTaskText.isEmpty {
            addTask(title: newTaskText)
            newTaskText = ""
            isAddingNewTask = false
        }
    }
    
    func togglePriority(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isHighPriority.toggle()
        }
    }
    

}
