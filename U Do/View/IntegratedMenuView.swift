//
//  IntegratedMenuView.swift
//  U Do
//
//  Created by yoyojun on 31/12/2024.
//

import SwiftUI


enum ViewType: Int, CaseIterable {
    
    
    case settings = -1
    case menu = 0
    // Add future views here with new cases
    // case newFeature = 1
    
    
    
    var offset: CGFloat {
        let basicWidth:Double = 150
        switch self {
        case .settings: return basicWidth-300
        case .menu: return basicWidth
        // Add offsets for future views
        }
    }
    
    var inactiveOffset: CGFloat {
        let basicWidth:Double = 450
        switch self {
        case .settings: return basicWidth-900
        case .menu: return basicWidth
        // Add inactive offsets for future views
        }
    }
}

struct HomeIndicatorView: View {
    @Environment(\.colorScheme) var colorScheme
    var color: Color {
        return colorScheme == .dark ? .white : .black
    }
    var currentView: ViewType
    var basicWidth: Int = 150
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ViewType.allCases, id: \.self) { viewType in
                Circle()
                    .fill(currentView == viewType ? color : color.opacity(0.3))
                
                    .frame(width: 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentView)
            }
        }
        .padding(.vertical, 8)
    }
}

struct IntegratedMenuView: View {
    @StateObject private var taskViewModel: TaskViewModel
    @StateObject private var settingsViewModel = SettingsViewModel.shared
    @State private var currentView: ViewType = .menu
    @State private var isLeftHovered = false
    @State private var isRightHovered = false
    
    init(taskViewModel: TaskViewModel) {
        _taskViewModel = StateObject(wrappedValue: taskViewModel)
    }
    
    private func navigateToView(_ viewType: ViewType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentView = viewType
        }
    }
    
    private func nextView() -> ViewType {
        let currentIndex = ViewType.allCases.firstIndex(of: currentView) ?? 0
        let nextIndex = (currentIndex + 1) % ViewType.allCases.count
        return ViewType.allCases[nextIndex]
    }
    
    private func previousView() -> ViewType {
        let currentIndex = ViewType.allCases.firstIndex(of: currentView) ?? 0
        let previousIndex = (currentIndex - 1 + ViewType.allCases.count) % ViewType.allCases.count
        return ViewType.allCases[previousIndex]
    }
    
    var body: some View {
        ZStack {
            VisualEffectView()
            
            HStack(spacing: 0) {
                MenuView(viewModel: taskViewModel) {
                    navigateToView(.settings)
                }
                .frame(width: 300)
                .offset(x: currentView == .menu ? ViewType.menu.offset : ViewType.menu.inactiveOffset)
                .opacity(currentView == .menu ? 1 : 0.3)
                
                SettingsView(viewModel: settingsViewModel) {
                    navigateToView(.menu)
                }
                .frame(width: 300)
                .offset(x: currentView == .settings ? ViewType.settings.offset : ViewType.settings.inactiveOffset)
                .opacity(currentView == .settings ? 1 : 0.3)
                
                // Add future views here following the same pattern
            }
            
            
            // Navigation arrows
            VStack {
                Spacer()
                HStack {
                    NavigationArrow(
                        direction: .left,
                        isHovered: $isLeftHovered,
                        isEnabled: true,
                        action: { navigateToView(previousView()) }
                    )
                    .padding(.trailing, 235)
                    
                    NavigationArrow(
                        direction: .right,
                        isHovered: $isRightHovered,
                        isEnabled: true,
                        action: { navigateToView(nextView()) }
                    )
                }
            }
            
            
            VStack {
                Spacer()
                HomeIndicatorView(currentView: currentView)
                    .padding(.bottom, 10)
            }
        }
        .frame(width: 310, height: 400)
    }
}

struct NavigationArrow: View {
    enum Direction {
        case left, right
        
        var iconName: String {
            switch self {
            case .left: return "chevron.backward"
            case .right: return "chevron.forward"
            }
        }
        
        var padding: Edge.Set {
            switch self {
            case .left: return .leading
            case .right: return .trailing
            }
        }
    }
    
    let direction: Direction
    @Binding var isHovered: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(Color(.white).opacity(0))
            .frame(width: 50, height: 320)
            .overlay {
                Image(systemName: direction.iconName)
                    .foregroundColor(.primary)
                    .opacity(isHovered ? 0.5 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isHovered)
                    .padding(direction.padding, 20)
                    
            }
            .offset(y: -30)
            .onHover { hovering in
                isHovered = hovering && isEnabled
            }
            .onTapGesture(perform: action)
    }
}




#Preview {
    IntegratedMenuView(taskViewModel: TaskViewModel())
}

