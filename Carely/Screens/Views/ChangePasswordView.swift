//
//  ChangePasswordView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var successMessage: String?
    @State private var showSuccessAlert = false
    
    @Environment(\.locale) private var locale
    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "lock.shield")
                .font(.system(size: 38))
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 4)

            Text("Keep your account secure")
                .font(.title2.bold())

            Text("Enter your current password, then choose a new one.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func passwordField(title: String,placeholder: String,text: Binding<String>,isVisible: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))

            HStack {
                Group {
                    if isVisible.wrappedValue {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    isVisible.wrappedValue.toggle()
                } label: {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 18) {
                    passwordField(
                        title: localize("Current Password"),
                        placeholder: localize("Enter current password"),
                        text: $currentPassword,
                        isVisible: $showCurrentPassword
                    )

                    passwordField(
                        title: localize("New Password"),
                        placeholder: localize("Enter new password"),
                        text: $newPassword,
                        isVisible: $showNewPassword
                    )

                    passwordField(
                        title: localize("Confirm New Password"),
                        placeholder: localize("Re-enter new password"),
                        text: $confirmPassword,
                        isVisible: $showConfirmPassword
                    )

                    Text("Password must contain at least 8 characters.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let error = authViewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task {
                            let success = await authViewModel.changePassword(
                                currentPassword: currentPassword,
                                newPassword: newPassword,
                                confirmPassword: confirmPassword,
                                locale: locale
                            )

                            if success {
                                successMessage = localize("Your password has been changed successfully.")
                                showSuccessAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }

                            Text(authViewModel.isLoading
                                 ? localize("Changing Password...")
                                 : localize("Change Password"))
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(authViewModel.isLoading)
                }
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authViewModel.clearError()
        }
        .alert(localize("Password Changed"), isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(successMessage ?? localize("Your password has been changed successfully."))
        }
    }
}

#Preview {
    ChangePasswordView()
}
