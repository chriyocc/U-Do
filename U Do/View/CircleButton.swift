//
//  CircleButton.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

import SwiftUI

struct CircleButton: View {
    let icon: String
    let size: CGFloat
    let fontColor: Color
    let bgColor: Color
    let action: () -> Void
    
    @State private var hover: Bool = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(bgColor)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(fontColor)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

struct ColorButton: View {
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color) // Button color
                .frame(width: 30, height: 30) // Adjust size as needed
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 4) // Outer stroke for subtle depth
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.2), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                )
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button styling
        
    }
}


struct EyeCircleButton: View {
    let iconShow: String
    let iconHide: String
    let size: CGFloat
    let fontColor: Color
    let bgColor: Color
    let task: Task?  // Optional task for existing tasks
    let viewModel: TaskViewModel
    @Binding var isVisible: Bool  // Changed to binding
    
    var body: some View {
        Button(action: {
            if let task = task {
                // Existing task - use the task's visibility
                viewModel.toggleTaskVisibility(task)
            } else {
                // New task - use binding
                isVisible.toggle()
            }
        }) {
            Image(systemName: task?.isVisibleInMenubar == true ? iconShow :
                  (task == nil ? (isVisible ? iconShow : iconHide) : iconHide))
                .font(.system(size: size))
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(bgColor)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(fontColor)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

struct EyeState: View {
    let iconShow: String
    let iconHide: String
    let size: CGFloat
    let fontColor: Color
    let task: Task?  // Optional task for existing tasks
    let viewModel: TaskViewModel
    @Binding var isVisible: Bool  // Changed to binding
    
    var body: some View {

        Image(systemName: task?.isVisibleInMenubar == true ? iconShow :
              (task == nil ? (isVisible ? iconShow : iconHide) : iconHide))
            .font(.system(size: size))
            .foregroundColor(fontColor.opacity(0.4))

    }


}



