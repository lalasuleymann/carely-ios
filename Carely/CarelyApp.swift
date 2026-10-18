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

    init() {
        let iosClientID = "818466594908-43oars70nnp36mf49e0ht20uluvf8o8t.apps.googleusercontent.com"
        let webClientID = "818466594908-j08reb92eo4uoqm8p9ekuttmeqhfbt68.apps.googleusercontent.com"

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: iosClientID,
            serverClientID: webClientID
        )
    }

    var body: some Scene {
        WindowGroup {
            AuthRootView()
                .environment(appointmentViewModel)
                .modelContainer(for: Appointment.self)
        }
    }
}
