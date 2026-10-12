//
//  AppointmentsView.swift
//  Carely
//
//  Created by Lala Suleymanova on 12.10.26.
//

import SwiftUI

struct AppointmentsView: View {

    @Environment(AppointmentViewModel.self)
    private var viewModel
    @State private var selectedStatus: AppointmentStatus = .upcoming

    // MARK: - Filtered Appointments
    private var filteredAppointments: [Appointment] {
        viewModel.appointments.filter {
            $0.status == selectedStatus
        }
    }

    // MARK: - Status Filter
    private var statusFilter: some View {
        HStack(spacing: 4) {
            statusButton(.upcoming)
            statusButton(.completed)
            statusButton(.cancelled)
        }
        .padding(5)
        .background(AppColors.surface)
        .clipShape(Capsule())
    }

    private func statusButton(_ status: AppointmentStatus) -> some View {
        let isSelected = selectedStatus == status

        return Button {
            selectedStatus = status
        } label: {
            Text(statusTitle(for: status))
                .font(AppTypography.bodyMedium)
                .foregroundStyle(
                    isSelected
                    ? AppColors.primaryText
                    : AppColors.secondaryText
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(AppColors.background)
                            .shadow(
                                color: .black.opacity(0.06),
                                radius: 4,
                                y: 2
                            )
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func statusTitle(for status: AppointmentStatus) -> String {
        switch status {
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }

    // MARK: - Appointments List
    private var appointmentsList: some View {
        LazyVStack(spacing: 16) {
            if filteredAppointments.isEmpty {
                emptyState
            } else {
                ForEach(filteredAppointments) { appointment in
                    AppointmentCard(
                        appointment: appointment,
                        viewModel: viewModel,
                        onCancel: {
                            viewModel.cancelAppointment(
                                id: appointment.id
                            )
                        }
                    )
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.primary)

            Text(emptyTitle)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            Text(emptyMessage)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var emptyTitle: String {
        switch selectedStatus {
        case .upcoming:
            return "No Upcoming Appointments"
        case .completed:
            return "No Completed Appointments"
        case .cancelled:
            return "No Cancelled Appointments"
        }
    }

    private var emptyMessage: String {
        switch selectedStatus {
        case .upcoming:
            return "Your upcoming appointments will appear here."
        case .completed:
            return "Your completed appointments will appear here."
        case .cancelled:
            return "Your cancelled appointments will appear here."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            statusFilter

            ScrollView {
                appointmentsList
            }
        }
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(AppColors.background)
    }
}

#Preview {
    NavigationStack {
        AppointmentsView()
    }
    .environment(AppointmentViewModel())
}
