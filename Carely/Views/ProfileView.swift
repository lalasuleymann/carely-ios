//
//  ProfileView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    private var user: AuthUserDTO? {
        authViewModel.currentUser
    }
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "person.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(AppColors.primary)
            }

            Text(fullName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.primaryText)

            Text(user?.email ?? "No email available")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            infoRow(
                title: "First Name",
                value: user?.firstName ?? "Not available",
                icon: "person"
            )

            infoRow(
                title: "Last Name",
                value: user?.lastName ?? "Not available",
                icon: "person"
            )

            infoRow(
                title: "Email",
                value: user?.email ?? "Not available",
                icon: "envelope"
            )

            infoRow(
                title: "Phone Number",
                value: user?.phoneNumber ?? "Not added",
                icon: "phone"
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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

    private var fullName: String {
        let firstName = user?.firstName ?? ""
        let lastName = user?.lastName ?? ""
        let name = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return name.isEmpty ? "Carely User" : name
    }
    
    private var logoutButton: some View {
        Button(role: .destructive) {
            authViewModel.logout()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")

                Text("Log Out")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                accountSection
                logoutButton
            }
            .padding(20)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AuthViewModel())
    }
}
