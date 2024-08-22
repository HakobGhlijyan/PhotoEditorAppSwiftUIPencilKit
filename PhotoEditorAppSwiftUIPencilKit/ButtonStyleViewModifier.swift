//
//  ButtonStyleViewModifier.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 21.08.2024.
//

import SwiftUI

//asButton
struct ButtonStyleViewModifier: ButtonStyle {
    
    let scale: CGFloat
    let opacity: Double
    let brightness: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? opacity : 1)
            .brightness(configuration.isPressed ? brightness : 0)
    }
}

public enum ButtonType {
    case press, opacity, tap
}

public extension View {
    
    /// Wrap a View in a Button and add a custom ButtonStyle.
    func asButton(scale: CGFloat = 0.95, opacity: Double = 1, brightness: Double = 0, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            self
        })
        .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
    }
    
    @ViewBuilder
    func asButton(_ type: ButtonType = .tap, action: @escaping () -> Void) -> some View {
        switch type {
        case .press:
            self.asButton(scale: 0.975, action: action)
        case .opacity:
            self.asButton(scale: 1, opacity: 0.85, action: action)
        case .tap:
            self.onTapGesture {
                action()
            }
        }
    }
}

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(8)
            .foregroundStyle(.black)
            .frame(height: 30)
            .background(.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.07), radius: 5, x: 5, y: 5)
            .shadow(color: .black.opacity(0.07), radius: 5, x: -5, y: -5)
    }
}

extension View {
    func buttonStyleCustom() -> some View {
        self.modifier(ButtonModifier())
    }
}
