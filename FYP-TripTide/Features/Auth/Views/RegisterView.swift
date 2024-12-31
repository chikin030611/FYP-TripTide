import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)
            
            Button(action: register) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || username.isEmpty || email.isEmpty || password.isEmpty)
            
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .navigationTitle("Register")
    }
    
    private func register() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await AuthService.shared.register(
                    username: username,
                    email: email,
                    password: password
                )
                if response.success {
                    dismiss()
                } else {
                    error = AuthError.serverError(response.message ?? "Registration failed")
                }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
} 