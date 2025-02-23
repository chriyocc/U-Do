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
                        withAnimation(.easeInOut(duration: 0.05)){
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
                    
                    LazyVStack(spacing: 8) {
                        
                        if viewModel.isAddingNewTask {
                            NewTaskRow(viewModel: viewModel)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            
                        }
                        ForEach(viewModel.tasks) { task in
                            TaskRow(task: task, viewModel: viewModel)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                                
                        }
                        
                        .onMove(perform: viewModel.moveTask)
                        
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
    @State private var hover: Bool = false
    @State private var isLongPressTriggered = false
    @State private var tapCount = 0
    @State private var isPressed = false
    @State private var isDragging = false
    @GestureState private var isDetectingLongPress = false
    @FocusState private var isFocused: Bool
    @State private var isFading = false // State for fade effect
    @State private var isVisible: Bool = false  // State for visibility
    
    var body: some View {
        HStack {
            if isEditing {
                // Editing mode content (unchanged)
                TextField("Task", text: $editText, onEditingChanged: { isEditing in
                    if !isEditing {
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
                
                Spacer()
                
                HStack(spacing: 10) {
                    EyeCircleButton(iconShow: "eye.fill", iconHide: "eye.slash.fill", size: 10, fontColor: .primary, bgColor: .primary.opacity(0.1), task: task, viewModel: viewModel, isVisible: $isVisible)
                    CircleButton(icon: "checkmark", size: 14, fontColor: .white, bgColor: Color.green, action: {
                        viewModel.editTask(task, newTitle: editText)
                        viewModel.saveTasks()
                        isEditing = false
                    })
                    
                    CircleButton(icon: "xmark", size: 14, fontColor: .primary, bgColor: .primary.opacity(0.1), action: {
                        isEditing = false
                    })
                }
                .padding(.horizontal)
            } else {
                Text(task.title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                EyeState(iconShow: "eye.fill", iconHide: "eye.slash.fill", size: 10, fontColor: .primary, task: task, viewModel: viewModel, isVisible: $isVisible)
                    .padding(.trailing, 4)
               
                CircleButton(icon: "pencil", size: 14, fontColor: .primary, bgColor: Color.gray.opacity(0.2), action: {
                    editText = task.title
                    isEditing = true
                })
                .shadow(radius: 0.3)
                .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(task.isHighPriority ? Color(SettingsViewModel.shared.priorityColor).opacity(0.35) : Color.gray.opacity(0.2))
                    .animation(.easeInOut(duration: 0.15), value: task.isHighPriority)
                    
                
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
        )
        
        .cornerRadius(30)
        .scaleEffect(hover ? 1.02 : 1.0)
        .opacity(hover ? 0.9 : 1.0)
        .opacity(isDragging ? 0.5 : 1.0)
        .scaleEffect(isFading ? 1.0 : 1.03)
        .opacity(isFading ? 1.0 : 0.8) // Apply fading opacity
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isFading = true // Trigger fade-in
                    }
                }
        .gesture(
            SpatialTapGesture(count: 2)
                .onEnded { _ in
                    viewModel.deleteTask(task)
                    
                }
                
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    if !isDragging {
                        isLongPressTriggered = true
                        viewModel.togglePriority(task)
                    }
                }
        )
        .padding(.horizontal)
        .draggable(task.id.uuidString) {
            // Provide a preview
            TaskRowPreview(task: task)
                .frame(width: 280)
        }
        .onDrag {
            isDragging = true
            isPressed = true
            return NSItemProvider(object: task.id.uuidString as NSString)
        }
        .onDrop(of: [.text], delegate: TaskDropDelegate(
           task: task,
           taskViewModel: viewModel,
           isDragging: $isDragging,
           onDropEntered: { currentIndex, dropIndex in
               // Use a smaller threshold for downward movement
               
               withAnimation(.easeInOut(duration: 0.4)) {
                   viewModel.moveTask(from: IndexSet(integer: currentIndex), to: dropIndex-1)
               }
           }
       ))
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.hover = isHovered
            }
            DispatchQueue.main.async {
                if self.hover {
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
    @State private var isVisible: Bool = false  // State for visibility
    
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
                EyeCircleButton(iconShow: "eye.fill", iconHide: "eye.slash.fill", size: 10, fontColor: .primary, bgColor: .primary.opacity(0.1), task: nil, viewModel: viewModel, isVisible: $isVisible)
                CircleButton(icon: "checkmark", size: 14, fontColor: .white, bgColor: Color.green, action: {
                    viewModel.saveTasks()
                    viewModel.addTaskFromInline(isVisible: isVisible)
                })
                
                CircleButton(icon: "xmark", size: 14, fontColor: .white, bgColor: Color.gray.opacity(0.2), action: {
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

struct TaskRowPreview: View {
    let task: Task
    
    var body: some View {
        HStack {
            Text(task.title)
                .font(.callout)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(30)
    }
}




#Preview {
    MenuView(viewModel: TaskViewModel(), onSettingsTap: {})
}
