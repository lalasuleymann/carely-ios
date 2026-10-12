//
//  AppointmentViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import Foundation
import Observation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class AppointmentViewModel {
    private(set) var appointments: [Appointment] = []
    private(set) var state: AppointmentsViewState = .idle
    private(set) var selectedStatus: AppointmentStatus = .upcoming

    private var modelContext: ModelContext?

    // MARK: - Configuration
    func configure(context: ModelContext) {
        modelContext = context
    }

    // MARK: - Filtering
    func selectStatus(_ status: AppointmentStatus) {
        selectedStatus = status
        updateState()
    }

    var filteredAppointments: [Appointment] {
        appointments.filter { $0.status == selectedStatus }
    }

    // MARK: - Loading
    func loadAppointments() {
        guard let modelContext else {
            state = .error("Appointment storage is not configured.")
            return
        }

        state = .loading

        do {
            let descriptor = FetchDescriptor<Appointment>(
                sortBy: [
                    SortDescriptor(\.date, order: .forward)
                ]
            )

            appointments = try modelContext.fetch(descriptor)
            updateState()
        } catch {
            state = .error(
                "Failed to load appointments: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - State
    private func updateState() {
        state = filteredAppointments.isEmpty ? .empty : .loaded
    }

    // MARK: - Appointment Information
    func statusTitle(for appointment: Appointment) -> String {
        switch appointment.status {
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }

    func statusColor(for appointment: Appointment) -> Color {
        switch appointment.status {
        case .upcoming:
            return AppColors.primary
        case .completed:
            return AppColors.success
        case .cancelled:
            return AppColors.error
        }
    }

    func formattedDate(for appointment: Appointment) -> String {
        appointment.date.formatted(
            .dateTime.month(.abbreviated).day().year()
        )
    }

    func formattedFee(for appointment: Appointment) -> String {
        "$\(Int(appointment.consultationFee))"
    }

    func canCancel(_ appointment: Appointment) -> Bool {
        appointment.status == .upcoming
    }

    // MARK: - Booking
    func bookAppointment(doctor: Doctor,date: Date,time: String) {
        guard let modelContext else {
            state = .error("Appointment storage is not configured.")
            return
        }

        let appointment = Appointment(
            doctorID: doctor.id,
            doctorName: doctor.name,
            specialty: doctor.specialty,
            date: date,
            time: time,
            consultationFee: doctor.consultationFee
        )

        modelContext.insert(appointment)

        do {
            try modelContext.save()

            let descriptor = FetchDescriptor<Appointment>(
                sortBy: [
                    SortDescriptor(\.date, order: .forward)
                ]
            )

            appointments = try modelContext.fetch(descriptor)
            updateState()
        } catch {
            modelContext.rollback()
            state = .error(
                "Failed to book appointment: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Cancellation
    func cancelAppointment(id: UUID) {
        guard let modelContext,
              let appointment = appointments.first(where: { $0.id == id })
        else {
            return
        }

        guard appointment.status == .upcoming else {
            return
        }

        appointment.status = .cancelled

        do {
            try modelContext.save()
            updateState()
        } catch {
            modelContext.rollback()
            loadAppointments()
            state = .error(
                "Failed to cancel appointment: \(error.localizedDescription)"
            )
        }
    }
}
