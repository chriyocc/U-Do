//
//  DropViewDelegate.swift
//  U Do
//
//  Created by yoyojun on 03/01/2025.
//

import Foundation
import SwiftUI

struct DropViewDelegate: DropDelegate {
    let item: Task
    let items: [Task]
    @Binding var isDragging: Bool
    let moveAction: (Int, Int) -> Void

    func dropEntered(info: DropInfo) {
        guard let fromIndex = items.firstIndex(where: { $0.id == item.id }),
              let fromId = info.itemProviders(for: [.text]).first else { return }
        
        fromId.loadObject(ofClass: NSString.self) { string, _ in
            guard let id = string as? String,
                  let toIndex = items.firstIndex(where: { $0.id.uuidString == id }) else { return }
            
            
            
            if fromIndex != toIndex {
                DispatchQueue.main.async {
                    moveAction(fromIndex, toIndex)
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        DispatchQueue.main.async {
            isDragging = false
        }
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
}

