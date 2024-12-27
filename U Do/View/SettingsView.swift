//
//  Setting.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

import SwiftUI

import Combine



struct SettingsView: View {
    @State private var timeInterval: String = "" // State for the time interval input
    @State private var isEditing = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: SettingsViewModel
    @State private var isPressed: Bool = false
    @State private var hover: Bool = false
    @Namespace private var animationNamespace
    
    
    
    
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Settings")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.leading, 10)
                    
                
                Spacer()
                
                HStack {
                    Button(action: {
                        
                        viewModel.closeWindow()
                        
                        
                    }, label: {
                        Image(systemName: "arrow.left.square")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(Color("globalColor"))
                            .padding(10)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 1)
                    .onHover { isHovered in
                        self.hover = isHovered
                        DispatchQueue.main.async { //<-- Here
                            if (self.hover) {
                                NSCursor.pointingHand.push()
                            } else {
                                self.hover = false
                                NSCursor.pop()
                            }
                        }
                    }
                }
                
                .padding(.trailing, 13)
                
                
            }
            .padding(.bottom, 5)
            
            Divider()
                .padding(.bottom, 5)
            
            ScrollView {
                
                
                    
                VStack {
                    
                    HStack(alignment: .bottom) {
                        
                        Text("Time Interval:")
                            .font(.system(size: 15, weight: .light))
                            .padding(.leading, 10)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        
                        Text("\(viewModel.timeSecond)")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(isEditing ? .gray : .primary)
                        
                        
                        Spacer()
                        
                        
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.timeSecond) },
                            set: { viewModel.timeSecond = Int($0) }
                        ),
                        in: 1...60
                        
                        
                    ) {
                        Text("")
                    } minimumValueLabel: {
                        Text("1")
                            .font(.system(size: 10, weight: .light))
                    } maximumValueLabel: {
                        Text("60")
                            .font(.system(size: 10, weight: .light))
                    } onEditingChanged: { editing in
                        isEditing = editing
                        isPressed = true
                    }
                    .onHover { isHovered in
                        self.hover = isHovered
                        DispatchQueue.main.async { //<-- Here
                            if (self.hover) {
                                NSCursor.pointingHand.push()
                            } else {
                                self.hover = false
                                NSCursor.pop()
                            }
                        }
                    }
                    
                    .padding(.bottom, 10)
                }
       
                Spacer()
                
                VStack {
                    
                    HStack(alignment: .bottom) {
                        
                        Text("Choose Priority Color:")
                            .font(.system(size: 15, weight: .light))
                            .padding(.leading, 10)
                            .foregroundColor(.primary)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        
                        
                        Spacer()
                        
                        
                    }
                    
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        ForEach(1...5, id: \.self) { index in
                            ColorButton(color: Color("Color_\(index)"), action: {
                                
                                viewModel.priorityColor = "Color_\(index)"
                                isPressed = true
                                print(viewModel.priorityColor)
                                viewModel.saveChanges()
                                
                            })
                            .buttonStyle(PlainButtonStyle())
                            .overlay(
                                // Add a stroke when the color is selected
                                
                                Circle()
                                    .stroke(viewModel.priorityColor == "Color_\(index)" ?    (colorScheme == .dark ? Color.primary : Color.white).opacity(0.8)
                                            : Color.clear,
                                        lineWidth: 2)
                                    .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 0)
                            )
                            .onHover { isHovered in
                                self.hover = isHovered
                                DispatchQueue.main.async { //<-- Here
                                    if (self.hover) {
                                        NSCursor.pointingHand.push()
                                    } else {
                                        self.hover = false
                                        NSCursor.pop()
                                    }
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: viewModel.priorityColor)
                            
                            
                        }
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        
                        Text("Choose Priority Emoji:")
                            .font(.system(size: 15, weight: .light))
                            .padding(.leading, 10)
                            .foregroundColor(.primary)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        
                        
                        Spacer()
                        
                        
                    }
                    
                    Spacer()
                    
                    
                    VStack {
                        
                        HStack(spacing: 16) {
                                Spacer()
                                
                            let emojis = [ "🔴","🛑","‼️","💥","⚠️"]
                                ForEach(emojis, id: \.self) { emoji in
                                    Button(action: {
                                        // Your button action here
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                                       viewModel.priorityEmoji = emoji
                                                   }
                                        print("Emoji tapped: \(emoji)")
                                        viewModel.priorityEmoji = "\(emoji)"
                                        isPressed = true
                                    }) {
                                        ZStack(alignment: .bottom) {
                                            Text(emoji)
                                                .font(.system(size: 30))
                                            
                                            // Show a circle below the selected emoji
                                            if viewModel.priorityEmoji == emoji {
                                                Circle()
                                                    .frame(width: 5, height: 5)
                                                    .foregroundColor((colorScheme == .dark ? Color.primary : Color.gray))
                                                    .offset(y: 8) // Adjust the position of the circle
                                                    .matchedGeometryEffect(id: "selectedEmoji", in: animationNamespace)
                                                
                                                    
                                                    
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    
                                }
                                
                                
                                Spacer()
                        }
                        
                    }
                    
                    
                }
                
                
                    
                
                
                
                Spacer()
                    .padding(.bottom, 70)
                HStack (alignment: .bottom) {
                    Spacer()
                    Button(action: { 
                        
                        NSApplication.shared.terminate(nil) }, label: {
                        Image(systemName: "power")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .padding(10)
                            .foregroundColor(Color("globalColor"))
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 1)
                    .padding(.trailing, 10)
                    .onHover { isHovered in
                        self.hover = isHovered
                        DispatchQueue.main.async { //<-- Here
                            if (self.hover) {
                                NSCursor.pointingHand.push()
                            } else {
                                self.hover = false
                                NSCursor.pop()
                            }
                        }
                    }
                }
                
                
                    
                
                
                
                
               
            }
        }
        .frame(width: 300, height: 400)
        .padding()
    }
}




#Preview {
    SettingsView(viewModel: SettingsViewModel.shared)

}



