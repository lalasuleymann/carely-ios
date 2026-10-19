//
//  AppointmentsView.swift
//  Carely
//
//  Created by Lala Suleymanova on 12.10.26.
//


import SwiftUI
import SwiftData

struct AppointmentsView: View {

    @Environment(AppointmentViewModel.self)
    private var viewModel
    
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.locale)
    private var locale
    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
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
        let isSelected = viewModel.selectedStatus == status
        return Button {
            viewModel.selectStatus(status)
        } label: {
            Text(statusTitle(for: status))
                .font(AppTypography.bodyMedium)
                .foregroundStyle(
                    isSelected ? AppColors.primaryText : AppColors.secondaryText
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
            return localize("Upcoming")
        case .completed:
            return localize("Completed")
        case .cancelled:
            return localize("Cancelled")
        }
    }

    // MARK: - Appointments List
    private var appointmentsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredAppointments) { appointment in
                NavigationLink {
                    AppointmentDetailView(
                        appointment: appointment,
                        viewModel: viewModel
                    )
                } label: {
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
                .buttonStyle(.plain)
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
        switch viewModel.selectedStatus {
        case .upcoming:
            return localize("No Upcoming Appointments")
        case .completed:
            return localize("No Completed Appointments")
        case .cancelled:
            return localize("No Cancelled Appointments")
        }
    }

    private var emptyMessage: String {
        switch viewModel.selectedStatus {
        case .upcoming:
            return localize("Your upcoming appointments will appear here.")
        case .completed:
            return localize("Your completed appointments will appear here.")
        case .cancelled:
            return localize("Your cancelled appointments will appear here.")
        }
    }

    // MARK: - Content State
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .loading:
            ProgressView("Loading appointments...")
                .tint(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, 50)

        case .loaded:
            appointmentsList

        case .empty:
            emptyState

        case .error(let message):
            ErrorStateView(
                title: localize("Something went wrong"),
                message: message
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusFilter

            ScrollView {
                content
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
        .background(AppColors.background)
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(context: modelContext)
            viewModel.loadAppointments()

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    break
                }

                guard !Task.isCancelled else { break }

                viewModel.loadAppointments()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppointmentsView()
    }
    .environment(AppointmentViewModel())
}
