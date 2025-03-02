import SwiftUI

struct Toast: View {
    @StateObject private var themeManager = ThemeManager()
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        Text(message)
            .foregroundColor(themeManager.selectedTheme.primaryColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(themeManager.selectedTheme.backgroundColor.opacity(0.9))
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.bottom, 10)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
    }
}
