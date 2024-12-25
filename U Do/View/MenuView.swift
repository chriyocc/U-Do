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
                    
                    
                    Button(action: { viewModel.isAddingNewTask = true }, label: {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .padding(10)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 13)
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
                .padding()
                
                
                ScrollView {
                    
                        if viewModel.isAddingNewTask {
                            NewTaskRow(viewModel: viewModel)
                        }
                        ForEach(viewModel.tasks) { task in
                            TaskRow(task: task, viewModel: viewModel)
                        }
                    }
                    
                    Spacer(minLength: 10)
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
        view.material = .sidebar
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
    

    
    var body: some View {
        Button(action: {
            if isLongPressTriggered {
                    // Long press detected, toggle priority
                viewModel.togglePriority(task)
                
                viewModel.togglePriority(task)
                
                    
                } else {
                    // Tap detected, delete task
                    viewModel.deleteTask(task)
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
                            isEditing = false
                        })
                        
                        CircleButton(icon: "xmark", fontColor: .black, bgColor: Color.white, action: {
                            isEditing = false
                        })
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                    
                } else {
                    CircleButton(icon: "pencil", fontColor: .white, bgColor: Color.gray.opacity(0.2), action: {
                        editText = task.title
                        isEditing = true
                        
                    })
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background((task.isHighPriority) ? Color(SettingsViewModel.shared.priorityColor).opacity(0.2) : Color.gray.opacity(0.2))
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
                }
            
            Spacer()
            
            HStack(spacing: 10) {
                
                CircleButton(icon: "checkmark", fontColor: .white, bgColor: Color.green, action: {
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