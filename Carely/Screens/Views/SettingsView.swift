//
//  SettingsView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("carely_notifications_enabled")
    private var notificationsEnabled = true

    @AppStorage("carely_appearance")
    private var appearance = "System"

    @State private var selectedLanguage = "English"
    @State private var showLanguageOptions = false
    @State private var showPrivacyInfo = false
    @State private var showAbout = false

    private func settingsRow(title: String,subtitle: String,icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.primary)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(AppColors.primaryText)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText)
        }
        .contentShape(Rectangle())
    }
    
    var body: some View {
        Form {
            Section("Preferences") {

                Picker(selection: $appearance) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                } label: {
                    Label {
                        Text("Appearance")
                    } icon: {
                        Image(systemName: "paintbrush")
                            .foregroundStyle(AppColors.primary)
                    }
                }

                Button {
                    showLanguageOptions = true
                } label: {
                    settingsRow(
                        title: "Language",
                        subtitle: selectedLanguage,
                        icon: "globe"
                    )
                }
                .buttonStyle(.plain)
            }
            Section("About") {
                Button {
                    showAbout = true
                } label: {
                    settingsRow(
                        title: "About Carely",
                        subtitle: "App information",
                        icon: "heart.text.square"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Choose Language",
            isPresented: $showLanguageOptions,
            titleVisibility: .visible
        ) {
            Button("English") {
                selectedLanguage = "English"
            }
            
            Button("Russian") {
                selectedLanguage = "Russian"
            }

            Button("Azərbaycan dili") {
                selectedLanguage = "Azərbaycan dili"
            }

            Button("Türkçe") {
                selectedLanguage = "Türkçe"
            }

            Button("Cancel", role: .cancel) {}
        }
        .alert("About Carely", isPresented: $showAbout) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Carely helps you discover healthcare services and manage appointments.")
        }
    }

}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
