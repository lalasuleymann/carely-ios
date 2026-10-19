//
//  CarelyApp.swift
//  Carely
//
//  Created by Lala Suleymanova on 05.10.26.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct CarelyApp: App {

    @State private var appointmentViewModel = AppointmentViewModel()

    @AppStorage("carely_appearance")
    private var appearance = "System"

    @AppStorage("carely_language")
    private var selectedLanguage = "English"

    init() {
        let iosClientID = "818466594908-43oars70nnp36mf49e0ht20uluvf8o8t.apps.googleusercontent.com"
        let webClientID = "818466594908-j08reb92eo4uoqm8p9ekuttmeqhfbt68.apps.googleusercontent.com"

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: iosClientID,
            serverClientID: webClientID
        )
    }

    private var appLocale: Locale {
        switch selectedLanguage {
        case "Russian", "Русский":
            return Locale(identifier: "ru")

        case "Azərbaycan dili":
            return Locale(identifier: "az-AZ")

        case "Türkçe", "Turkish":
            return Locale(identifier: "tr")

        default:
            return Locale(identifier: "en")
        }
    }

    var body: some Scene {
        WindowGroup {
            AuthRootView()
                .environment(appointmentViewModel)
                .environment(\.locale, appLocale)
                .modelContainer(for: Appointment.self)
                .preferredColorScheme(
                    appearance == "Light" ? .light :
                    appearance == "Dark" ? .dark : nil
                )
        }
    }
}
