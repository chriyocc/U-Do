//
//  MenuView.swift
//  U Do
//
//  Created by yoyojun on 23/12/2024.
//


import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel = TaskViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var editingTask: Task?
    @State private var editText: String = ""
    @State private var hover: Bool = false
    @State private var hoverGearButton: Bool = false
    @State private var hoverPlusButton: Bool = false
    
    
    var body: some View {
        ZStack {
            VisualEffectView()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("U Do")
                        .font(.system(size: 40, weight: .bold))
                    
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            SettingsViewModel.shared.showSettings()
                            
                        }, label: {
                            Image(systemName: "gear")
                                .fontWeight(.bold)
                                .font(.system(size: 13))
                                .foregroundColor(Color("globalColor"))
                                .padding(10)
                                .background(Circle().fill(Color.gray.opacity(0.2)))
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 1)
                        .scaleEffect(hoverGearButton ? 1.1 : 1.0) // Scale effect
                        .onHover { isHovered in
                            self.hoverGearButton = isHovered
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
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 13)
                    .scaleEffect(hoverPlusButton ? 1.1 : 1.0) // Scale effect
                    .onHover { isHovered in
                        self.hoverPlusButton = isHovered
                        DispatchQueue.main.async {
                            if (self.hoverPlusButton) {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .padding()
                
                
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
                    }
                    
                    Spacer(minLength: 10)
                }
                    
                    
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
    @GestureState private var isDetectingLongPress = false
    @State private var isLongPressTriggered = false
    @FocusState private var isFocused: Bool
    @State private var hover: Bool = false
    @State private var tapCount = 0  // Track the number of taps
    @State private var showDeletePrompt = false
    @State private var taskDone = false
   
    

    
    var body: some View {
        Button(action: {
            if isLongPressTriggered {
                    // Long press detected, toggle priority
                viewModel.togglePriority(task)
                
                viewModel.togglePriority(task)
                
                    
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
                        
                        CircleButton(icon: "xmark", fontColor: .black, bgColor: Color.white, action: {
                            isEditing = false
                        })
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                    
                } else {
                    CircleButton(icon: "pencil", fontColor: .primary, bgColor: Color.gray.opacity(0.2), action: {
                        editText = task.title
                        isEditing = true
                        
                    })
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background((task.isHighPriority) ? Color(SettingsViewModel.shared.priorityColor).opacity(0.3) : Color.gray.opacity(0.2))
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
            self.hover = isHovered
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
    MenuView()
}
