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
                let destinationIndex = taskViewModel.tasks.firstIndex(where: { $0.id == task.id })
            else { return }
            
            // Don't process if source and destination are the same
            if sourceIndex == destinationIndex { return }
            
            DispatchQueue.main.async {
                let adjustedDestination: Int
                
                // If moving down, insert after the destination
                if sourceIndex < destinationIndex {
                    adjustedDestination = destinationIndex + 1
                } else {
                    // If moving up, insert at the destination
                    adjustedDestination = destinationIndex
                }
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    taskViewModel.moveTask(from: IndexSet(integer: sourceIndex), to: adjustedDestination)
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
