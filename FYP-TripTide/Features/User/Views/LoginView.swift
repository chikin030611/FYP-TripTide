import SwiftUI

struct LoginView: View {
    @State private var showRegisterSheet = false
    @StateObject var themeManager = ThemeManager()
    @FocusState private var focusedField: Field?
    @StateObject private var viewModel = LoginViewModel()
    
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
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "envelope")))
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(UnderlinedTextFieldStyle(icon: Image(systemName: "lock")))
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                    
                    Button {
                        Task {
                            await viewModel.login()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)
                    
                    if let error = viewModel.error {
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
