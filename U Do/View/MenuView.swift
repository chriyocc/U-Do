//
//  MenuView.swift
//  U Do
//
//  Created by yoyojun on 23/12/2024.
//


import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel = TaskViewModel()
    @State private var hover: Bool = false
    @State private var hoverGearButton: Bool = false
    @State private var hoverPlusButton: Bool = false
    
    var onSettingsTap: () -> Void
    
    var body: some View {
        ZStack {
            VisualEffectView()
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    
                        Text("U Do..")
                        .font(.system(size: 50, weight: .heavy))
                            .padding(.leading, 10)
                            .foregroundStyle(
                                LinearGradient ( colors: [.primary, .gray], startPoint: .topLeading,
                                                 endPoint: .bottomTrailing)
                                )
                            
                                            
                    Spacer()
                    
                    HStack {
                        Button(action:
                            onSettingsTap
                            
                        , label: {
                            Image(systemName: "gear")
                                .fontWeight(.bold)
                                .font(.system(size: 13))
                                .foregroundColor(Color("globalColor"))
                                .padding(10)
                                .background(
                                    Circle().fill(Color.gray.opacity(0.2))
                                )
                                .help("Settings")
                    
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 1)
                        .scaleEffect(hoverGearButton ? 1.1 : 1.0) // Scale effect
                        .onHover { isHovered in
                            withAnimation(.easeInOut(duration: 0.1)){
                                self.hoverGearButton = isHovered
                            }
                            
                            DispatchQueue.main.async {
                                if (self.hoverGearButton) {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        }
                    }
                    
                    
                    Button(action: {
                        withAnimation {
                            viewModel.isAddingNewTask = true
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(Color("globalColor"))
                            .padding(10)
                            .background(
                                Circle().fill(Color.gray.opacity(0.2))
                            )
                            .help("Add Task")
                            
                            
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 13)
                    .scaleEffect(hoverPlusButton ? 1.1 : 1.0) // Scale effect
                    .onHover { isHovered in
                        withAnimation(.easeInOut(duration: 0.1)){
                            self.hoverPlusButton = isHovered
                        }
                        
                        DispatchQueue.main.async {
                            if (self.hoverPlusButton) {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                Spacer()
                
                
                ScrollView {
                    
                    VStack(spacing: 8) {
                        
                        if viewModel.isAddingNewTask {
                            NewTaskRow(viewModel: viewModel)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            
                        }
                        ForEach(viewModel.tasks) { task in
                            TaskRow(task: task, viewModel: viewModel)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                                
                        }
                        Text("Plan your work and work your plan.")
                            .font(.system(size: 10, weight: .ultraLight ,design: .default))
                            .italic()
                            .foregroundStyle(.primary)
                            .padding()
                            .opacity(0.5)
                        
                    }
                    .padding(.top, 1)
                    
                    Spacer(minLength: 10)
                }
                .scrollIndicators(.never)
                    
                    
                }
                .frame(width: 300, height: 400)
                .onAppear {
                    WindowManager.shared.setupWindow()
            }
        
        }
    
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .menu
        view.alphaValue = 1.0 // Adjust opacity (0.0 to 1.0)
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
    
}


struct TaskRow: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var isEditing = false
    @State private var editText: String = ""
    @State private var isLongPressTriggered = false
    @State private var hover: Bool = false
    @State private var tapCount = 0  // Track the number of taps
    @GestureState private var isDetectingLongPress = false
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        Button(action: {
            if isLongPressTriggered {
                // Long press detected, toggle priority
                viewModel.togglePriority(task)
                viewModel.togglePriority(task)
                viewModel.saveTasks()
                
                } else {
                    // Tap detected, delete task
                    tapCount += 1
                    if tapCount == 2 {
                        viewModel.deleteTask(task)
                        tapCount = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if tapCount == 1 {
                           tapCount = 0
                        }
                    }
                }
                isLongPressTriggered = false // Reset after action
            
        }, label: {
            HStack {
                if isEditing {
                    TextField("Task", text: $editText, onEditingChanged: { isEditing in
                        
                        if !isEditing {
                                // Commit changes only when editing ends
                                viewModel.editTask(task, newTitle: editText)
                            }
                        
                    })
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.callout)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .focused($isFocused)
                        .onSubmit {
                            viewModel.editTask(task, newTitle: editText)
                            viewModel.saveTasks()
                            isEditing = false
                        }
                        .onAppear {
                            isFocused = true
                        }
                    
                        
                } else {
                    Text(task.title)
                        .font(.callout)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                if isEditing {
                    HStack(spacing: 10) {
                        CircleButton(icon: "checkmark", fontColor: .white, bgColor: Color.green, action: {
                            viewModel.editTask(task, newTitle: editText)
                            viewModel.saveTasks()
                            isEditing = false
                        })
                        
                        CircleButton(icon: "xmark", fontColor: colorScheme == .dark ? Color.primary : Color.white,
                                     bgColor: .primary.opacity(0.1),
                                     action: {
                            isEditing = false
                        })
                    }
                    .padding(.horizontal)
                    
                    
                } else {
                    CircleButton(icon: "pencil", fontColor: .primary, bgColor: Color.gray.opacity(0.2), action: {
                        editText = task.title
                        isEditing = true
                        
                        
                    })
                    
                    .shadow(radius: 0.3)
                    .padding(.horizontal)
                    
                    
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background((task.isHighPriority) ? Color(SettingsViewModel.shared.priorityColor).opacity(0.3) : Color.gray.opacity(0.2))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .cornerRadius(30)
            
        })
        .contentShape(Rectangle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isDetectingLongPress) { currentState, gestureState, _ in
                    gestureState = currentState
                    
                }
                .onEnded { _ in
                    isLongPressTriggered = true
                    viewModel.togglePriority(task)
                }
        )
        
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 15)
        .scaleEffect(hover ? 1.02 : 1.0)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.1)){
                self.hover = isHovered
            }
            DispatchQueue.main.async {
                if (self.hover) {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }

    }
}



struct NewTaskRow: View {
    @ObservedObject var viewModel: TaskViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField("New Task", text: $viewModel.newTaskText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.callout)
                .fontWeight(.bold)
                .padding(.leading, 20)
                .focused($isFocused)
                .onSubmit {
                    guard !viewModel.newTaskText.isEmpty else { return }
                    viewModel.addTaskFromInline()
                    viewModel.saveTasks()
                }
            
            Spacer()
            
            HStack(spacing: 10) {
                
                CircleButton(icon: "checkmark", fontColor: .white, bgColor: Color.green, action: {
                    viewModel.saveTasks()
                    viewModel.addTaskFromInline()
                })
                
                CircleButton(icon: "xmark", fontColor: .white, bgColor: Color.gray.opacity(0.2), action: {
                    viewModel.isAddingNewTask = false
                    viewModel.newTaskText = ""
                })

                
            }
            .padding(.horizontal)
        }

        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(30)
        .padding(.horizontal, 15)
        .onAppear {
            isFocused = true
        }
    }
}




#Preview {
    MenuView(viewModel: TaskViewModel(), onSettingsTap: {})
}
