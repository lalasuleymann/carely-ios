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

    private let networkService: NetworkService
    private var modelContext: ModelContext?
    
    private let tokenProvider: () throws -> String?

    init(
        networkService: NetworkService = DefaultNetworkService(),
        tokenProvider: @escaping () throws -> String? = {
            try KeychainService.readToken()
        }
    ) {
        self.networkService = networkService
        self.tokenProvider = tokenProvider
    }

    var upcomingAppointments: [Appointment] {
        appointments.filter { $0.status == .upcoming }
    }

    func configure(context: ModelContext) {
        modelContext = context

        do {
            let descriptor = FetchDescriptor<Appointment>(
                sortBy: [SortDescriptor(\.date)]
            )

            appointments = try context.fetch(descriptor)
            updateState()
        } catch {
            error.localizedDescription
        }
    }

    // MARK: - Filtering
    func selectStatus(_ status: AppointmentStatus) {
        selectedStatus = status
        updateState()
    }

    var filteredAppointments: [Appointment] {
        appointments.filter { $0.status == selectedStatus }
    }

    // MARK: - Loading from backend
    func loadAppointments() {
        Task {
            await fetchAppointments()
        }
    }

    func fetchAppointments() async {
        if let modelContext {
            do {
                let descriptor = FetchDescriptor<Appointment>(
                    sortBy: [SortDescriptor(\.date)]
                )

                appointments = try modelContext.fetch(descriptor)
                updateState()
            } catch {
                error.localizedDescription
            }
        }

        if appointments.isEmpty {
            state = .loading
        }

        do {
            guard let token = try tokenProvider(),
                  !token.isEmpty else {
                if appointments.isEmpty {
                    state = .error(
                        "Please log in again to view your appointments."
                    )
                }
                return
            }

            let response: [AppointmentDTO] = try await networkService.request(
                AppointmentEndpoint.getAppointments,
                token: token
            )

            let fetchedAppointments = try response.map {
                try makeAppointment(from: $0)
            }

            if let modelContext {
                let descriptor = FetchDescriptor<Appointment>()
                let cachedAppointments = try modelContext.fetch(descriptor)

                for cached in cachedAppointments {
                    modelContext.delete(cached)
                }

                for appointment in fetchedAppointments {
                    modelContext.insert(appointment)
                }

                try modelContext.save()
            }

            appointments = fetchedAppointments.sorted {
                $0.date < $1.date
            }

            updateState()

        } catch {
            if appointments.isEmpty {
                state = .error(
                    "Failed to load appointments: \(error.localizedDescription)"
                )
            } else {
                updateState()
                error.localizedDescription
            }
        }
    }


    private func makeAppointment(from dto: AppointmentDTO) throws -> Appointment {
        let startAt = try parseDate(dto.startAt)
        let status = parseStatus(dto.status)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Baku")
        formatter.dateFormat = "h:mm a"

        let time = formatter.string(from: startAt)

        return Appointment(
            serverID: dto.id,
            doctorID: dto.doctorId,
            doctorName: dto.doctorName,
            specialty: dto.specialty,
            facilityName: dto.facilityName,
            date: startAt,
            time: time,
            consultationFee: dto.consultationFee,
            status: status,
            hasReview: dto.hasReview,
            myRating: dto.myRating
        )
    }

    private func parseDate(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]

        if let date = formatter.date(from: value) {
            return date
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        if let date = dateFormatter.date(from: value) {
            return date
        }

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = dateFormatter.date(from: value) {
            return date
        }

        throw NetworkError.decodingError
    }

    private func parseStatus(_ value: String) -> AppointmentStatus {
        switch value.lowercased() {
        case "upcoming":
            return .upcoming
        case "completed":
            return .completed
        case "cancelled":
            return .cancelled
        default:
            return .upcoming
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

    func formattedDate(for appointment: Appointment, locale: Locale) -> String {
        appointment.date.formatted(
            .dateTime.month(.abbreviated).day().year()
            .locale(locale)
        )
    }

    func formattedFee(for appointment: Appointment) -> String {
        "$\(Int(appointment.consultationFee))"
    }

    func canCancel(_ appointment: Appointment) -> Bool {
        appointment.status == .upcoming
    }

    // MARK: - Booking (not connected yet)
    func bookAppointment(doctor: Doctor,date: Date,time: String) {
        guard let startAt = makeAppointmentDate(date: date, time: time) else {
            state = .error("Could not read the selected appointment time.")
            return
        }

        guard startAt > Date() else {
            state = .error("Appointment time must be in the future.")
            return
        }

        Task {
            await createAppointmentOnServer(
                doctorID: doctor.id,
                startAt: startAt
            )
        }
    }

    private func makeAppointmentDate(date: Date, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Baku")
        formatter.dateFormat = "HH:mm"

        guard let parsedTime = formatter.date(from: time) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let timeComponents = calendar.dateComponents(
            [.hour, .minute],
            from: parsedTime
        )

        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: date
        )
    }
    func submitReview(appointment: Appointment,rating: Int) async throws {
        guard appointment.status == .completed else {
            throw NetworkError.serverMessage(
                "Only completed appointments can be rated."
            )
        }

        guard (1...5).contains(rating) else {
            throw NetworkError.serverMessage(
                "Rating must be between 1 and 5."
            )
        }

        guard let serverID = appointment.serverID else {
            throw NetworkError.serverMessage(
                "This appointment is not linked to the server."
            )
        }

        guard let token = try tokenProvider(),
              !token.isEmpty else {
            throw NetworkError.unauthorized
        }

        let _: SubmitReviewResponse = try await networkService.request(
            AppointmentEndpoint.submitReview(
                id: serverID,
                rating: rating
            ),
            token: token
        )
    }

    private func createAppointmentOnServer(doctorID: Int,startAt: Date) async {
        state = .loading

        do {
            guard let token = try tokenProvider(),
                  !token.isEmpty else {
                state = .error("Please log in again to book an appointment.")
                return
            }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            let request = CreateAppointmentRequestDTO(
                doctorId: doctorID,
                startAt: formatter.string(from: startAt),
                notes: nil
            )

            let _: AppointmentDTO = try await networkService.request(
                CreateAppointmentEndpoint.create(request),
                token: token
            )

            await fetchAppointments()
        } catch {
            state = .error(
                "Failed to book appointment: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Cancellation (not connected yet)
    func cancelAppointment(id: UUID) {
        guard let appointment = appointments.first(where: { $0.id == id }) else {
            return
        }

        guard appointment.status == .upcoming else {
            return
        }

        guard let serverID = appointment.serverID else {
            state = .error("This appointment is not linked to the server.")
            return
        }

        Task {
            await cancelAppointmentOnServer(serverID: serverID)
        }
    }

    private func cancelAppointmentOnServer(serverID: Int) async {
        do {
            guard let token = try tokenProvider(),
                  !token.isEmpty else {
                state = .error("Please log in again to cancel this appointment.")
                return
            }

            let _: CancelAppointmentResponseDTO = try await networkService.request(
                AppointmentEndpoint.cancelAppointment(id: serverID),
                token: token
            )

            await fetchAppointments()
        } catch {
            state = .error(
                "Failed to cancel appointment: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Completion (server-managed)
    func completeAppointment(id: UUID) {
        guard let appointment = appointments.first(where: { $0.id == id }) else {
            return
        }

        guard appointment.status == .upcoming else {
            return
        }

        guard let serverID = appointment.serverID else {
            state = .error("This appointment is not linked to the server.")
            return
        }

        Task {
            await completeAppointmentOnServer(serverID: serverID)
        }
    }

    private func completeAppointmentOnServer(serverID: Int) async {
        do {
            guard let token = try tokenProvider(),
                  !token.isEmpty else {
                state = .error("Please log in again to complete this appointment.")
                return
            }

            let _: CompleteAppointmentResponseDTO =
                try await networkService.request(
                    CompleteAppointmentEndpoint.completeAppointment(id: serverID),
                    token: token
                )

            await fetchAppointments()

        } catch {
            state = .error(
                "Failed to complete appointment: \(error.localizedDescription)"
            )
        }
    }

}
