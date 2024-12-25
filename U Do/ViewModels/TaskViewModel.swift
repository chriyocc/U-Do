//
//  TaskViewModel.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

// TaskViewModel.swift
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var newTaskTitle: String = ""
    @Published var isShowingAddTask = false
    
    func addTask(title: String) {
        guard !title.isEmpty else { return }
        tasks.append(Task(title: title))
        newTaskTitle = ""
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func editTask(_ task: Task, newTitle: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
        }
    }
}
