//
//  RegisterView.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import SwiftUI
import UIKit

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    
    @Environment(\.locale) private var locale
    
    // MARK: - Localization
    private func localized(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }


    private var isFormValid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 &&
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 &&
        email.contains("@") &&
        password.count >= 8 &&
        password == confirmPassword
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 30))
                .foregroundStyle(AppColors.primary)

            Text("Carely")
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(AppColors.primaryText)

            Spacer()
        }
    }

    // MARK: - Name Field
    private func nameField(title: String,placeholder: String,text: Binding<String>,contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.primaryText)

            TextField(placeholder, text: text)
                .textContentType(contentType)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
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
    private func passwordField(title: String,placeholder: String,text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.primaryText)

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(AppColors.secondaryText)

                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .textContentType(.newPassword)
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create account")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(AppColors.primaryText)
                    }

                    VStack(spacing: 14) {
                        nameField(
                            title: localized("First Name"),
                            placeholder: localized("First Name"),
                            text: $firstName,
                            contentType: .givenName
                        )

                        nameField(
                            title: localized("Last Name"),
                            placeholder: localized("Last Name"),
                            text: $lastName,
                            contentType: .familyName
                        )

                        emailField
                        passwordField(
                            title: localized("Password"),
                            placeholder: localized("At least 8 characters"),
                            text: $password
                        )
                        passwordField(
                            title: localized("Confirm password"),
                            placeholder: localized("Re-enter password"),
                            text: $confirmPassword
                        )
                    }

                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text(localized("Passwords do not match."))
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.error)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.error)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        Task {
                            await viewModel.register(
                                firstName: firstName,
                                lastName: lastName,
                                email: email,
                                password: password
                            )
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }

                            Text(viewModel.isLoading ? localized("Creating account...") : localized("Create account"))
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
                    .disabled(!isFormValid || viewModel.isLoading)
                    .opacity(!isFormValid || viewModel.isLoading ? 0.6 : 1)
                }

                HStack(spacing: 5) {
                    Spacer()

                    Text("Already have an account?")
                        .foregroundStyle(AppColors.secondaryText)

                    Button("Sign in") {
                        viewModel.clearError()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primary)

                    Spacer()
                }
                .font(.system(size: 14))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
        .background(AppColors.background.ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    RegisterView(viewModel: AuthViewModel())
}
