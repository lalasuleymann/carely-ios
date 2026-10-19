//
//  ProfileView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//


import SwiftUI
import PhotosUI
import UIKit

struct ProfileView: View {

    @Environment(AuthViewModel.self) private var authViewModel

    @State private var profileViewModel = ProfileViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showPhotoOptions = false
    @State private var showDeleteConfirmation = false
    @State private var showEditProfile = false
    @State private var photoError: String?
    @State private var showChangePassword = false
    @State private var showSetPassword = false
    
    @Environment(\.locale) private var locale
    
    @State private var deleteAccountError: String?
    
    @State private var showDeleteAccountAlert = false
    @State private var isDeletingAccount = false
    
    private let photoFileName = "carely-profile-photo.jpg"

    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
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
        profileViewModel.profile?.email
            ?? user?.email
            ?? localize("No email available")
    }

    private var phoneNumber: String {
        profileViewModel.profile?.phoneNumber
            ?? user?.phoneNumber
            ?? localize("Not added")
    }

    private var fullName: String {
        let name = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return name.isEmpty ? "Carely User" : name
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 8) {
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Circle()
                                .fill(AppColors.primary.opacity(0.12))
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 34))
                                        .foregroundStyle(AppColors.primary)
                                }
                        }
                    }
                    .frame(width: 88, height: 88)
                    .clipShape(Circle())

                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(AppColors.surface, lineWidth: 3)
                        }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change profile photo")

            Button {
                showPhotoOptions = true
            } label: {
                Text(
                    profileImage == nil
                        ? "Add Profile Photo"
                        : "Edit Profile Photo"
                )
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.primary)
            }
            .buttonStyle(.plain)

            Text(fullName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColors.primaryText)

            Text(email)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Account Information
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account Information")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            infoRow(
                title: localize("First Name"),
                value: firstName.isEmpty ? localize("Not available") : firstName,
                icon: "person"
            )

            infoRow(
                title: localize("Last Name"),
                value: lastName.isEmpty ? localize("Not available") : lastName,
                icon: "person"
            )

            infoRow(
                title: localize("Email"),
                value: email,
                icon: "envelope"
            )

            infoRow(
                title: localize("Phone Number"),
                value: phoneNumber.isEmpty ? localize("Not added") : phoneNumber,
                icon: "phone"
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Profile Menu
    private var profileMenu: some View {
        VStack(spacing: 0) {
            NavigationLink {
                PersonalInformationView(
                    profileViewModel: profileViewModel
                )
                .environment(authViewModel)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 17))
                        .frame(width: 24)
                        .foregroundStyle(AppColors.primary)

                    Text("Personal Information")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(minHeight: 50)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            menuDivider

            NavigationLink {
                SettingsView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17))
                        .frame(width: 24)
                        .foregroundStyle(AppColors.primary)

                    Text("Settings")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(minHeight: 50)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            menuDivider

            profileMenuRow(title: localize("Change Password"), icon: "lock") {
                if let profile = profileViewModel.profile {
                    if profile.hasPassword {
                        showChangePassword = true
                    } else {
                        showSetPassword = true
                    }
                } else {
                    Task {
                        await profileViewModel.loadProfile(locale: locale)

                        guard let profile = profileViewModel.profile else {
                            return
                        }

                        if profile.hasPassword {
                            showChangePassword = true
                        } else {
                            showSetPassword = true
                        }
                    }
                }
            }

            menuDivider

            profileMenuRow(
                title: localize("Delete Account"),
                icon: "person.crop.circle.badge.xmark",
                isDestructive: true
            ) {
                showDeleteAccountAlert = true
            }

            menuDivider

            profileMenuRow(
                title: localize("Log Out"),
                icon: "rectangle.portrait.and.arrow.right",
                isDestructive: true
            ) {
                authViewModel.logout()
            }
        }
        .padding(.horizontal, 16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var menuDivider: some View {
        Divider()
            .padding(.leading, 38)
    }

    private func profileMenuRow(title: String,icon: String,isDestructive: Bool = false,action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .frame(width: 24)
                    .foregroundStyle(
                        isDestructive ? Color.red : AppColors.primary
                    )

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(
                        isDestructive ? Color.red : AppColors.primaryText
                    )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(minHeight: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Row
    private func infoRow(title: String,value: String,icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.primary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.secondaryText)

                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
                    .textSelection(.enabled)
            }

            Spacer()
        }
    }

    // MARK: - Photo Handling
    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data),
                let jpegData = image.jpegData(compressionQuality: 0.85)
            else {
                photoError = localize("The selected photo could not be loaded.")
                return
            }

            try jpegData.write(to: photoFileURL(), options: .atomic)

            profileImage = image
            selectedPhoto = nil
        } catch {
            photoError = localize("Could not save the selected photo. Please try again.")
        }
    }

    private func loadSavedPhoto() {
        guard
            let data = try? Data(contentsOf: photoFileURL()),
            let image = UIImage(data: data)
        else {
            return
        }

        profileImage = image
    }

    private func removeProfilePhoto() {
        do {
            let url = photoFileURL()

            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            profileImage = nil
            selectedPhoto = nil
        } catch {
            photoError = localize("Could not remove the profile photo.")
        }
    }

    private func photoFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documentsDirectory.appendingPathComponent(photoFileName)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                profileHeader
                profileMenu
            }
            .padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView()
                .environment(authViewModel)
        }
        .navigationDestination(isPresented: $showSetPassword) {
            SetPasswordView(profileViewModel: profileViewModel)
                .environment(authViewModel)
        }
        .task {
            await profileViewModel.loadProfile(locale: locale)
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}

            Button("Delete", role: .destructive) {
                Task {
                    let success = await authViewModel.deleteAccount()

                    if success {
                        showDeleteAccountAlert = false
                    } else {
                        showDeleteAccountAlert = false
                        deleteAccountError = authViewModel.errorMessage
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .confirmationDialog(
            "Profile Photo",
            isPresented: $showPhotoOptions,
            titleVisibility: .visible
        ) {
            Button("Choose Photo") {
                photoError = localize("Tap the profile picture to choose a photo.")
            }

            if profileImage != nil {
                Button("Remove Photo", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Remove your profile photo?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove Photo", role: .destructive) {
                removeProfilePhoto()
            }

            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                await loadSelectedPhoto(newPhoto)
            }
        }
        .onAppear {
            loadSavedPhoto()
        }
        .alert(
            "Profile Photo",
            isPresented: Binding(
                get: { photoError != nil },
                set: {
                    if !$0 {
                        photoError = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                photoError = nil
            }
        } message: {
            Text(photoError ?? "")
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
    NavigationStack {
        ProfileView()
            .environment(AuthViewModel())
    }
}
