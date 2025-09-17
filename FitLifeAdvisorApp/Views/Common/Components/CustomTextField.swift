//
//  CustomTextField.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var placeholder: String = ""
    
    @State private var isSecureVisible = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.textDark)
            
            HStack {
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(placeholder.isEmpty ? title : placeholder, text: $text)
                    } else {
                        TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                    }
                }
                .keyboardType(keyboardType)
                .focused($isFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                if isSecure {
                    Button(action: {
                        isSecureVisible.toggle()
                    }) {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
            }
            .padding()
            .background(Constants.Colors.backgroundGray)
            .cornerRadius(Constants.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.smallCornerRadius)
                    .stroke(isFocused ? Constants.Colors.primaryBlue : Color.clear, lineWidth: 2)
            )
        }
    }
}
