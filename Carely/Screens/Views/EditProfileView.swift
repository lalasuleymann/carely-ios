//
//  EditProfileView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//


import SwiftUI

struct EditProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel

    @Bindable var viewModel: ProfileViewModel

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""

    private func loadCurrentUser() {
        guard let user = authViewModel.currentUser else { return }

        firstName = user.firstName
        lastName = user.lastName
        phoneNumber = user.phoneNumber ?? ""
    }

    @MainActor
    private func saveProfile() async {
        await viewModel.updateProfile(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )

        guard viewModel.errorMessage == nil,
              let profile = viewModel.profile else {
            return
        }

        authViewModel.updateCurrentUser(
            firstName: profile.firstName,
            lastName: profile.lastName,
            phoneNumber: profile.phoneNumber
        )

        dismiss()
    }
    
    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)

                TextField("Last Name", text: $lastName)
                    .textContentType(.familyName)
                    .textInputAutocapitalization(.words)

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
            }

            Section("Account") {
                LabeledContent(
                    "Email",
                    value: authViewModel.currentUser?.email ?? "Not available"
                )
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if let successMessage = viewModel.successMessage {
                Section {
                    Text(successMessage)
                        .foregroundStyle(.green)
                }
            }

            Section {
                Button {
                    Task {
                        await saveProfile()
                    }
                } label: {
                    HStack {
                        Spacer()

                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                                .fontWeight(.semibold)
                        }

                        Spacer()
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadCurrentUser()
        }
    }
}

#Preview {
    EditProfileView(viewModel: ProfileViewModel())
}
