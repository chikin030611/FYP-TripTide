import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @StateObject var themeManager = ThemeManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Become a TripTide member")
                    .font(themeManager.selectedTheme.largeTitleFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "person")))
                    .autocapitalization(.none)

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "envelope")))
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "lock")))
                    .textContentType(.newPassword)
                
                Button(action: {
                    Task {
                        await viewModel.register()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading || !viewModel.isFormValid)
                
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(themeManager.selectedTheme.warningColor)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(.top, 40)
            .alert("Registration Successful", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
} 