import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showRegisterSheet = false
    @StateObject var themeManager = ThemeManager()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ScrollView {
            Group {
                VStack(spacing: 20) {
                    Image("user_login")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                
                    Text("Login")
                        .font(themeManager.selectedTheme.largerTitleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "envelope")))
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "lock")))
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    if let error = error {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack {
                        Text("New to TripTide?")
                        Button("Create Account") {
                            showRegisterSheet = true
                        }
                        .foregroundColor(themeManager.selectedTheme.accentColor)
                }
                .padding(.top)

                Spacer()
                }
                .padding(.top, 40)
            }
            .sheet(isPresented: $showRegisterSheet) {
                RegisterView()
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    focusedField = nil // This dismisses the keyboard
                }
        )
    }
}

extension LoginView {
    private func login() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await AuthService.shared.login(email: email, password: password)
                guard response.success else {
                    throw AuthError.serverError(response.message ?? "Login failed")
                }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
