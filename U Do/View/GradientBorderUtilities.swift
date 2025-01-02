//
//  GradientBorderUtilities.swift
//  U Do
//
//  Created by yoyojun on 02/01/2025.
//

import SwiftUI

// MARK: - Gradient Border Configuration
public struct GradientBorderConfig {
    let topOpacity: Double
    let middleOpacity: Double
    let bottomOpacity: Double
    let lineWidth: CGFloat
    let color: Color
    
    public static let `default` = GradientBorderConfig(
        topOpacity: 0.5,
        middleOpacity: 0.2,
        bottomOpacity: 0.1,
        lineWidth: 1,
        color: .white
    )
    
    public static func custom(
        topOpacity: Double = 0.2,
        middleOpacity: Double = 0.05,
        bottomOpacity: Double = 0,
        lineWidth: CGFloat = 1,
        color: Color = .white
    ) -> GradientBorderConfig {
        GradientBorderConfig(
            topOpacity: topOpacity,
            middleOpacity: middleOpacity,
            bottomOpacity: bottomOpacity,
            lineWidth: lineWidth,
            color: color
        )
    }
}

// MARK: - Gradient Border Modifier
public struct GradientBorderModifier: ViewModifier {
    private let config: GradientBorderConfig
    
    public init(config: GradientBorderConfig = .default) {
        self.config = config
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                config.color.opacity(config.topOpacity),
                                config.color.opacity(config.middleOpacity),
                                config.color.opacity(config.bottomOpacity)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: config.lineWidth
                    )
            )
    }
}

// MARK: - Custom Gradient Border Modifier
public struct CustomGradientBorderModifier: ViewModifier {
    private let colors: [Color]
    private let lineWidth: CGFloat

    
    public init(
        colors: [Color],
        lineWidth: CGFloat = 1,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.colors = colors
        self.lineWidth = lineWidth

    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: colors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
    }
}


// MARK: - View Extensions
public extension View {
    func gradientBorder(
        topOpacity: Double = 0.2,
        middleOpacity: Double = 0.05,
        bottomOpacity: Double = 0,
        lineWidth: CGFloat = 1,
        color: Color = .white
    ) -> some View {
        let config = GradientBorderConfig.custom(
            topOpacity: topOpacity,
            middleOpacity: middleOpacity,
            bottomOpacity: bottomOpacity,
            lineWidth: lineWidth,
            color: color
        )
        return modifier(GradientBorderModifier(config: config))
    }
    
    func gradientBorder(config: GradientBorderConfig = .default) -> some View {
        modifier(GradientBorderModifier(config: config))
    }
    
    func gradientBorder(
        colors: [Color],
        lineWidth: CGFloat = 1
    ) -> some View {
        modifier(CustomGradientBorderModifier(
            colors: colors,
            lineWidth: lineWidth,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
}


