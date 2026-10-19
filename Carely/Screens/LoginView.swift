//
//  LoginView.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import SwiftUI
import GoogleSignIn
import UIKit
import AuthenticationServices

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    
    @Environment(\.locale) private var locale
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showRegister = false

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 34))
                .foregroundStyle(AppColors.primary)

            Text("Carely")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(AppColors.primaryText)

            Spacer()
        }
    }

    // MARK: - Email
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email address")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.primaryText)

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(AppColors.secondaryText)

                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.secondaryText.opacity(0.12), lineWidth: 1)
            }
        }
    }

    // MARK: - Password
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.primaryText)

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(AppColors.secondaryText)

                Group {
                    if isPasswordVisible {
                        TextField("Enter your password", text: $password)
                    } else {
                        SecureField("Enter your password", text: $password)
                    }
                }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(AppColors.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.secondaryText.opacity(0.12), lineWidth: 1)
            }
        }
    }

    // MARK: - Social Login
    private var socialLoginSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(AppColors.secondaryText.opacity(0.2))
                    .frame(height: 1)

                Text("OR CONTINUE WITH")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize()

                Rectangle()
                    .fill(AppColors.secondaryText.opacity(0.2))
                    .frame(height: 1)
            }

            
            Button {
                guard !viewModel.isLoading else { return }

                guard let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                      let rootViewController = windowScene.windows
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController else {
                    return
                }

                Task {
                    do {
                        let result = try await GIDSignIn.sharedInstance.signIn(
                            withPresenting: rootViewController
                        )

                        guard let idToken = result.user.idToken?.tokenString else {
                            return
                        }

                        await viewModel.loginWithGoogle(idToken: idToken)
                    } catch {
                        if (error as NSError).code != GIDSignInError.canceled.rawValue {
                            print("Google Sign-In error: \(error.localizedDescription)")
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text("G")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Color(red: 0.13, green: 0.16, blue: 0.17))
                        .clipShape(Circle())

                    Text("Continue with Google")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(AppColors.primaryText)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            AppColors.secondaryText.opacity(0.18),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)

//            SignInWithAppleButton(
//                .signIn,
//                onRequest: { request in
//                    request.requestedScopes = [.fullName, .email]
//                },
//                onCompletion: { result in
//                    switch result {
//                    case .success(let authorization):
//                        guard
//                            let credential = authorization.credential
//                                as? ASAuthorizationAppleIDCredential,
//                            let tokenData = credential.identityToken,
//                            let identityToken = String(
//                                data: tokenData,
//                                encoding: .utf8
//                            )
//                        else {
//                            viewModel.clearError()
//                            return
//                        }
//
//                        let firstName = credential.fullName?.givenName
//                        let lastName = credential.fullName?.familyName
//                        let email = credential.email
//
//                        Task {
//                            await viewModel.loginWithApple(
//                                identityToken: identityToken,
//                                firstName: firstName,
//                                lastName: lastName,
//                                email: email
//                            )
//                        }
//
//                    case .failure(let error):
//                        let authError = error as? ASAuthorizationError
//
//                        if authError?.code != .canceled {
//                            print("Apple Sign-In error: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            )
//            .signInWithAppleButtonStyle(.black)
//            .frame(maxWidth: .infinity)
//            .frame(height: 52)
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//            .disabled(viewModel.isLoading)

        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sign in")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(AppColors.primaryText)
                        }

                        VStack(spacing: 14) {
                            emailField
                            passwordField
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.error)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Button {
                            Task {
                                await viewModel.login(
                                    email: email,
                                    password: password,
                                    locale: locale
                                )
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                }

                                Text(viewModel.isLoading ? "Signing In..." : "Sign In")
                                    .font(.system(size: 16, weight: .semibold))

                                if !viewModel.isLoading {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundStyle(.white)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(
                            viewModel.isLoading ||
                            email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            password.isEmpty
                        )
                        .opacity(viewModel.isLoading ? 0.7 : 1)
                    }

                    socialLoginSection

                    HStack(spacing: 5) {
                        Spacer()

                        Text("New to Carely?")
                            .foregroundStyle(AppColors.secondaryText)

                        Button("Create account") {
                            viewModel.clearError()
                            showRegister = true
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.primary)

                        Spacer()
                    }
                    .font(.system(size: 14))
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 24)
            }
            .background(AppColors.background.ignoresSafeArea())
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
