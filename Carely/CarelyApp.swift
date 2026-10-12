//
//  CarelyApp.swift
//  Carely
//
//  Created by Lala Suleymanova on 05.10.26.
//

import SwiftUI

@main
struct CarelyApp: App {
    @State private var appointmentViewModel = AppointmentViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(appointmentViewModel)
        }
    }
}
