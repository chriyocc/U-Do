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
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var isMenuOpen: Bool = false
    
    var onBackTap: () -> Void
    
    
    var body: some View {
        VStack {
            
            HStack(alignment: .center) {
                LocalizedText(key: "Settings")
                    .font(.system(size: 39, weight: .bold))
                    .padding(.leading, 8)
                    
                
                Spacer()
                
                Button(action:
                        {NSApplication.shared.terminate(nil) }
                    
                , label: {
                    Image(systemName: "power")
                        .fontWeight(.bold)
                        .font(.system(size: 14))
                        .padding(10)
                        .foregroundColor(Color("globalColor"))
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                        .help("Quit")
            
                })
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 0.1)
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
                
                
                
                HStack {
                    Button(action: 
                            onBackTap
                    , label: {
                        Image(systemName: "arrow.right")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(Color("globalColor"))
                            .padding(10)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 0.5)
                    .cursorOnHover()
                }
                
                .padding(.trailing, 10)

            }
            .padding(.bottom, 5)
            
            Divider()
                .padding(.bottom, 5)
            
            ScrollView {

                VStack {
                    
                    HStack(alignment: .bottom) {
                        
                        LocalizedText(key:"Time Interval:")
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
                    .cursorOnHover()
                    
                    .padding(.bottom, 10)
                }
       
                Spacer()
                
                VStack {
                    
                    HStack(alignment: .bottom) {
                        
                        LocalizedText(key:"Choose Priority Color:")
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
                                    .stroke(viewModel.priorityColor == "Color_\(index)" ?    (colorScheme == .dark ? Color.primary : Color.white)
                                            : Color.clear,
                                        lineWidth: 3)
                                    .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 0)
                            )
                            .cursorOnHover()
                            .animation(.easeInOut(duration: 0.3), value: viewModel.priorityColor)
                            
                            
                        }
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        
                        LocalizedText(key:"Choose Priority Emoji:")
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
                        HStack {
                            LocalizedText(key:"Language:")
                                .font(.system(size: 15, weight: .light))
                                .padding(.leading, 10)
                                .foregroundColor(.primary)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                            
                            
                            Spacer()
 
                        }
                        // Language Selector
                        Menu {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        languageManager.selectedLanguage = "en"
                                    }
                                }) {
                                    Text("English")
                                }
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        languageManager.selectedLanguage = "zh-Hans"
                                    }
                                }) {
                                    Text("中文")
                                }
                            } label: {
                                HStack {
                                    Text(languageManager.selectedLanguage == "en" ? "English" : "中文")
                                        .font(.system(size: 14, weight: .medium))
                                        .transition(.opacity) // Fade animation for text change
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .rotationEffect(.degrees(isMenuOpen ? 180 : 0)) // Rotate the chevron
                                        .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                                }
                                .padding(8)
                                .frame(width: 100)
                                .background(RoundedRectangle(cornerRadius: 30).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isMenuOpen.toggle() // Toggle the menu state
                                }
                            }
                    
                    
            
                    }

                }

                
                
               
            }
        }
        .id(languageManager.viewRefreshTrigger)
        .scrollIndicators(.never)
        .padding()
    }
}

extension View {
    func cursorOnHover() -> some View {
        self.onHover { isHovered in
            DispatchQueue.main.async {
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel.shared, onBackTap: {})

}



