import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                if let error = error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                NavigationLink("Create Account", destination: RegisterView())
                    .padding(.top)
            }
            .padding()
            .navigationTitle("Login")
        }
    }
    
    private func login() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await AuthService.shared.login(email: email, password: password)
                if response.success {
                    dismiss()
                } else {
                    error = AuthError.serverError(response.message ?? "Login failed")
                }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
} 