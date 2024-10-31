//
//  ButtonStyles.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 31/10/2024.
//

import SwiftUI

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 290)
            .foregroundColor(Color("mnBtnTextColor"))
            .padding(7)
            .background(Color("mnAccentColor"))
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 290)
            .foregroundColor(Color("mnAccentColor"))
            .padding(7)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("mnAccentColor"), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Tertiary Button Style
struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 290)
            .foregroundColor(Color("mnPrimaryColor"))
            .padding(7)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("mnPrimaryColor"), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Quaternary Button Style
struct QuaternaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .regular, design: .default))
            .frame(width: 290)
            .foregroundColor(Color("mnAccentColor"))
            .padding(7)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Add Button Style
struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: "plus")
            .padding(.bottom, 10)
            .padding(.top, 10)
            .frame(width: 32, height: 32)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("mnAccentColor"), lineWidth: 1)
            )
            .foregroundColor(Color("mnAccentColor"))
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Remove Button Style
struct RemoveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: "minus")
            .padding(.bottom, 10)
            .padding(.top, 10)
            .frame(width: 32, height: 32)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.red, lineWidth: 1)
            )
            .foregroundColor(Color.red)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Tag Button Style
struct TagButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundColor(Color("mnBtnTextColor"))
            .padding(7)
            .padding(.horizontal, 5)
            .background(Color("mnAccentColor"))
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Remove Tag Button Style
struct RemoveTagButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "xmark")
                .foregroundColor(Color("mnAccentColor"))
            configuration.label
        }
        .font(.system(size: 16, weight: .regular, design: .default))
        .foregroundColor(Color("mnAccentColor"))
        .padding(7)
        .padding(.horizontal, 5)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color("mnAccentColor"), lineWidth: 1)
        )
        .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}


