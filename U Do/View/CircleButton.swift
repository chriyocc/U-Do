//
//  CircleButton.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

import SwiftUI

struct CircleButton: View {
    let icon: String
    let fontColor: Color
    let bgColor: Color
    let action: () -> Void
    @State private var hover: Bool = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .frame(width: 30, height: 30)
                .background(Circle().fill(bgColor))
                .foregroundColor(fontColor)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
        

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


