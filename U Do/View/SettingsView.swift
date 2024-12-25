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
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.leading, 10)
                    
                
                Spacer()
            }
            .padding(.bottom, 5)
            
            Divider()
                .padding(.bottom, 5)
            
            ScrollView {
                
                VStack {
                    HStack {
                        
                        Text("Time Interval:")
                            .font(.system(size: 15))
                            .padding(.leading, 10)
                        
                        Text("\(Int(viewModel.timeSecond))")
                            .font(.system(size: 15))
                            .foregroundColor(isEditing ? .gray : .primary)
                        
                        Spacer()
                        
                        
                    }
                    
                    Slider(
                        value: $viewModel.timeSecond,
                        in: 1...60
                        
                        
                    ) {
                        Text("")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("60")
                    } onEditingChanged: { editing in
                        isEditing = editing
                    }
                    
                
                    
                    
                    Spacer()
                    HStack {
                        CircleButton(icon: "arrow.left.square", fontColor: .white, bgColor: Color(.gray), action: {
                            
                            NSApplication.shared.terminate(nil)
                        })
                        .padding(.bottom, 1)
                        
                        //Save Changes Button
                        CircleButton(icon: "arrow.down.circle", fontColor: .white, bgColor: Color(.gray), action: {
                            viewModel.saveChanges()
                            
                        })
                        .padding(.bottom, 1)
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



