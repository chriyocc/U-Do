//
//  IntegratedMenuView.swift
//  U Do
//
//  Created by yoyojun on 31/12/2024.
//

import SwiftUI

struct HomeIndicatorView: View {
    var currentPage: IntegratedMenuView.MenuTab
    
    var body: some View {
        HStack(spacing: 8) {
            // First dot (Tasks)
            Circle()
                .fill(currentPage == .settings ? .white : .white.opacity(0.3))
                .frame(width: 8, height: 8)
                .animation(.spring(response: 0.3), value: currentPage)
            
            // Second dot (Settings)
            Circle()
                .fill(currentPage == .tasks ? .white : .white.opacity(0.3))
                .frame(width: 8, height: 8)
                .animation(.spring(response: 0.3), value: currentPage)
        }
        .padding(.vertical, 8)
        
        
    }
}

struct IntegratedMenuView: View {
    @StateObject private var taskViewModel: TaskViewModel
    @StateObject private var settingsViewModel = SettingsViewModel.shared
    @State private var currentView: MenuTab = .tasks
    @State private var slideOffset: CGFloat = 0
    
    enum MenuTab {
        case tasks
        case settings
    }
    
    init(taskViewModel: TaskViewModel) {
        _taskViewModel = StateObject(wrappedValue: taskViewModel)
    }
    
    var body: some View {
        ZStack {
            VisualEffectView()
            
            HStack(spacing: 0) {
                // MenuView
                MenuView(viewModel: taskViewModel, onSettingsTap: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentView = .settings
                    }
                })
                .frame(width: 300)
                .offset(x: currentView == .tasks ? 150 : 450)
                .opacity(currentView == .tasks ? 1 : 0.3)
                
                // SettingsView
                SettingsView(viewModel: settingsViewModel, onBackTap: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentView = .tasks
                    }
                })
                .frame(width: 300)
                .offset(x: currentView == .settings ? -150 : -450)
                .opacity(currentView == .settings ? 1 : 0.3)
            }
            
            VStack {
                Spacer()
                HomeIndicatorView(currentPage: currentView)
                    .padding(.bottom, 10)
            }
            
        }
        .frame(width: 300, height: 400)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: slideOffset)
    }
}



#Preview {
    IntegratedMenuView(taskViewModel: TaskViewModel())
}

