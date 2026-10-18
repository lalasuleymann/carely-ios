//
//  HomeViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let networkService: NetworkService

    var doctors: [Doctor] = []
    var searchText = ""

    var isLoadingDoctors = false
    var errorMessage: String?
    
    var specialties: [SpecialtyDTO] = []

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    func loadSpecialties() async {
        do {
            let result: [SpecialtyDTO] = try await networkService.request(
                SpecialtyEndpoint.all,
                token: nil
            )

            specialties = result
        } catch {
            print("Failed to load specialties:", error.localizedDescription)
        }
    }

    var filteredDoctors: [Doctor] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return doctors
        }

        return doctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(searchText) ||
            doctor.specialty.localizedCaseInsensitiveContains(searchText)
        }
    }

    
    func loadDoctors() async {
        guard !isLoadingDoctors else { return }

        isLoadingDoctors = true
        errorMessage = nil

        defer {
            isLoadingDoctors = false
        }

        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                errorMessage = "Please log in to load doctors."
                return
            }

            let response: [DoctorDTO] = try await networkService.request(
                DoctorEndpoint.all(),
                token: token
            )

            try Task.checkCancellation()
            doctors = response.map(\.toDoctor)

            print("Doctors loaded successfully: \(doctors.count)")
        } catch is CancellationError {
            print("Doctor request was cancelled.")
        } catch {
            errorMessage = "Failed to load doctors: \(error.localizedDescription)"
            print("Home doctors error: \(error)")
        }
    }


    func greeting(for date: Date = .now) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    func nextAppointment(
        from appointments: [Appointment],
        now: Date = .now
    ) -> Appointment? {
        appointments
            .filter { $0.status == .upcoming && $0.date >= now }
            .min { $0.date < $1.date }
    }

    func appointmentCount(from appointments: [Appointment]) -> Int {
        appointments.count
    }

    func completedAppointmentCount(from appointments: [Appointment]) -> Int {
        appointments.filter { $0.status == .completed }.count
    }

    func cancelledAppointmentCount(from appointments: [Appointment]) -> Int {
        appointments.filter { $0.status == .cancelled }.count
    }

    func formattedNextVisit(from appointments: [Appointment]) -> String {
        guard let appointment = nextAppointment(from: appointments) else {
            return "No upcoming visit"
        }

        return appointment.date.formatted(
            .dateTime.month(.abbreviated).day()
        )
    }
}
