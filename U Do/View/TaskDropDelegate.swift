//
//  TaskDropDelegate.swift
//  U Do
//
//  Created by yoyojun on 09/01/2025.
//

import SwiftUI

struct TaskDropDelegate: DropDelegate {
    let task: Task
    let taskViewModel: TaskViewModel
    @Binding var isDragging: Bool
    let onDropEntered: (Int, Int) -> Void
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }
    
    func dropEntered(info: DropInfo) {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return }
        
        itemProvider.loadObject(ofClass: NSString.self) { (id, error) in
            guard
                let droppedId = id as? String,
                let sourceIndex = taskViewModel.tasks.firstIndex(where: { $0.id.uuidString == droppedId }),
                let destinationIndex = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }),
                sourceIndex != destinationIndex
            else { return }
            
            // Check drag direction and adjust threshold
            let isDraggingDown = destinationIndex > sourceIndex
            let distance = abs(destinationIndex - sourceIndex)
            
            if !isDraggingDown || distance > 1 { // Allow quicker swaps for downward drags
                DispatchQueue.main.async {
                    withAnimation {
                        taskViewModel.moveTask(from: IndexSet(integer: sourceIndex), to: destinationIndex)
                    }
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                isDragging = false
            }
        }
        return true
    }
}
