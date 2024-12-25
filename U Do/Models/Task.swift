//
//  Task.swift
//  U Do
//
//  Created by yoyojun on 24/12/2024.
//

// Task.swift
import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}
