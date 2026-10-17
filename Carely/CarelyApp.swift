//
//  CarelyApp.swift
//  Carely
//
//  Created by Lala Suleymanova on 05.10.26.
//

import SwiftUI
import SwiftData

@main
struct CarelyApp: App {
    @State private var appointmentViewModel = AppointmentViewModel()

    var body: some Scene {
        WindowGroup {
            AuthRootView()
                .environment(appointmentViewModel)
                .modelContainer(for: Appointment.self)
        }
    }
}
