//
//  PersonalInformationView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import SwiftUI

struct PersonalInformationView: View {

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var showEditProfile = false

    init(profileViewModel: ProfileViewModel) {
        _profileViewModel = State(initialValue: profileViewModel)
    }

    private var user: AuthUserDTO? {
        authViewModel.currentUser
    }

    private var firstName: String {
        profileViewModel.profile?.firstName ?? user?.firstName ?? ""
    }

    private var lastName: String {
        profileViewModel.profile?.lastName ?? user?.lastName ?? ""
    }

    private var email: String {
        profileViewModel.profile?.email ?? user?.email ?? "Not available"
    }

    private var phoneNumber: String {
        profileViewModel.profile?.phoneNumber ?? user?.phoneNumber ?? "Not added"
    }

    private var informationCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Account Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            infoRow(
                title: "First Name",
                value: firstName.isEmpty ? "Not available" : firstName,
                icon: "person"
            )

            infoRow(
                title: "Last Name",
                value: lastName.isEmpty ? "Not available" : lastName,
                icon: "person"
            )

            infoRow(
                title: "Email",
                value: email,
                icon: "envelope"
            )

            infoRow(
                title: "Phone Number",
                value: phoneNumber.isEmpty ? "Not added" : phoneNumber,
                icon: "phone"
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func infoRow(title: String,value: String,icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.secondaryText)

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
                    .textSelection(.enabled)
            }

            Spacer()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                informationCard

                Button {
                    profileViewModel.clearMessages()
                    showEditProfile = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Information")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .padding(18)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await profileViewModel.loadProfile()
        }
        .sheet(isPresented: $showEditProfile) {
            NavigationStack {
                EditProfileView(viewModel: profileViewModel)
                    .environment(authViewModel)
            }
        }
    }
}

#Preview {
    PersonalInformationView(profileViewModel: ProfileViewModel())
}
