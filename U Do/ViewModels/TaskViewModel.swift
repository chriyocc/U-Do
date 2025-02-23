//
//  TaskViewModel.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

// TaskViewModel.swift
import SwiftUI


class TaskViewModel: ObservableObject {
    
    @Published var newTaskText: String = ""
    @Published var isAddingNewTask: Bool = false
    @Published var tasks: [Task] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("UpdateMenu"), object: nil)
        }
    }
        
    
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
    
    
    
    func saveTasks() {
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
            withAnimation{
                tasks.remove(at: index)
                saveTasks()
            }
            
        }
    }
    
    func editTask(_ task: Task, newTitle: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
        }
    }
    
    func addTaskFromInline(isVisible: Bool = false) {
        if !newTaskText.isEmpty {
            let newTask = Task(title: newTaskText, isVisibleInMenubar: isVisible)
            tasks.insert(newTask, at: 0)
            newTaskText = ""
            isAddingNewTask = false
            saveTasks()
        }
    }
    
    func togglePriority(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isHighPriority.toggle()
        }
    }
    
    // Add this to your TaskViewModel
    func moveTask(from source: IndexSet, to destination: Int) {
        var adjustedDestination = destination
        // Adjust destination index if moving down
        if source.first! < destination {
            adjustedDestination += 0
        }
        
        // Use immediate animation for better responsiveness
        withAnimation(.easeInOut(duration: 0.2)) {
            tasks.move(fromOffsets: source, toOffset: adjustedDestination)
            saveTasks()
            objectWillChange.send()
        }
    }
    
    func toggleTaskVisibility(_ task: Task) {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index].isVisibleInMenubar.toggle()
                saveTasks()
            }
        }
        
    func getVisibleTasks() -> [Task] {
        return tasks.filter { $0.isVisibleInMenubar }
    }
    

}
