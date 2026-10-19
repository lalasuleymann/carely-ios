//
//  SettingsView.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("carely_appearance")
    private var appearance = "System"
    
    @AppStorage("carely_language")
    private var selectedLanguage = "English"

    @State private var showLanguageOptions = false
    @State private var showAbout = false
    @Environment(\.locale) private var locale
    

    private var selectedLocale: Locale {
        switch selectedLanguage {
        case "Russian":
            return Locale(identifier: "ru")
        case "Azərbaycan dili":
            return Locale(identifier: "az-AZ")
        case "Türkçe":
            return Locale(identifier: "tr")
        default:
            return Locale(identifier: "en")
        }
    }
    // MARK: - Localization
    private func localized(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }


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
                        title: localized("Language"),
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
                        title: localized("About Carely"),
                        subtitle: localized("App information"),
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

            Button("Русский") {
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
