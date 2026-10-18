

//
//  HomeView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AppointmentViewModel.self) private var appointmentViewModel
    @Environment(\.selectedTab) private var selectedTab
    
    @State private var showProfile = false
    @State private var selectedAppointment: Appointment?
    @State private var showAppointmentDetail = false
    
    // MARK: - User Information
    private var userFullName: String {
        let firstName = authViewModel.currentUser?.firstName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let lastName = authViewModel.currentUser?.lastName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let fullName = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return fullName.isEmpty ? "there" : fullName
    }

    // MARK: - Profile Placeholder
    private var profilePlaceholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(AppColors.onPrimary)
            .frame(width: 44, height: 44)
    }

    // MARK: - Profile Image
    private var profileImage: some View {
        Group {
            if let imageURL = authViewModel.currentUser?.profileImageUrl,
               !imageURL.isEmpty,
               let url = URL(string: imageURL),
               let scheme = url.scheme,
               scheme == "https" || scheme == "http" {

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure(let error):
                        profilePlaceholder

                    case .empty:
                        ProgressView()
                            .tint(AppColors.onPrimary)
                            .frame(width: 44, height: 44)

                    @unknown default:
                        profilePlaceholder
                    }
                }
            } else {
                profilePlaceholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.greeting()),")
                        .font(AppTypography.body)
                        .foregroundStyle(
                            AppColors.onPrimary.opacity(0.8)
                        )

                    Text(userFullName)
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.onPrimary)
                }

                Spacer()

                Button {
                    selectedTab.wrappedValue = 4
                } label: {
                    profileImage
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open profile")
            }
            
            ZStack {
                SearchBar(
                    text: $viewModel.searchText,
                    placeholder: "Search doctors, specialties..."
                )
                .allowsHitTesting(false)

                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTab.wrappedValue = 1
                    }
            }
            .frame(height: 50)

        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .padding(.bottom, 28)
        .background(AppColors.primary)
    }
    
    // MARK: - Upcoming Appointment
    private var upcomingAppointmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Appointment")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            switch appointmentViewModel.state {
            case .idle, .loading:
                ProgressView("Loading appointment...")
                    .tint(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(AppColors.surface)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

            case .loaded, .empty:
                if let appointment = viewModel.nextAppointment(
                    from: appointmentViewModel.appointments
                ) {
                    UpcomingAppointmentCard(
                        doctorName: appointment.doctorName,
                        specialty: appointment.specialty,
                        date: appointment.date.formatted(
                            .dateTime
                                .weekday(.abbreviated)
                                .month(.abbreviated)
                                .day()
                                .year()
                        ),
                        time: appointment.time,
                        appointmentType: "In-Person"
                    ) {
                        selectedAppointment = appointment
                        showAppointmentDetail = true
                    }
                    .buttonStyle(.plain)
                } else {
                    emptyUpcomingAppointment
                }

            case .error(let message):
                VStack(alignment: .leading, spacing: 8) {
                    Text("Could not load appointments")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)

                    Text(message)
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)

                    Button("Try Again") {
                        Task {
                            await appointmentViewModel.fetchAppointments()
                        }
                    }
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppColors.surface)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }
        }
    }

    // MARK: - Empty Upcoming Appointment
    private var emptyUpcomingAppointment: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 24))
                .foregroundStyle(AppColors.primary)

            Text("No upcoming appointment")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)

            Text("Your next appointment will appear here.")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Specialties
    private var specialtiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Specialties",
                showSeeAll: false
            )

            if viewModel.specialties.isEmpty {
                Text("No specialties available.")
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.specialties, id: \.id) { specialty in
                            SpecialtyCard(
                                title: specialty.name,
                                icon: SpecialtyIconProvider.icon(for: specialty.name)
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Top Doctors
    private var topDoctorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Top Doctors",
                showSeeAll: false
            )

            if viewModel.doctors.isEmpty {
                Text("No doctors available right now.")
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            } else {
                ScrollView(.horizontal,showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.doctors) { doctor in
                            NavigationLink {
                                DoctorDetailView(doctor: doctor)
                            } label: {
                                TopDoctorCard(doctor: doctor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Your Health
    private var healthSection: some View {
        let appointments = appointmentViewModel.appointments

        let totalAppointments = viewModel.appointmentCount(
            from: appointments
        )

        let completedAppointments = viewModel.completedAppointmentCount(
            from: appointments
        )

        let nextVisit = viewModel.formattedNextVisit(
            from: appointments
        )

        let cancelledAppointments = viewModel.cancelledAppointmentCount(
            from: appointments
        )

        return VStack(alignment: .leading, spacing: 12) {
            Text("Your Health")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                HealthStatCard(
                    title: "Appointments",
                    value: "\(totalAppointments)",
                    icon: "calendar",
                    iconColor: AppColors.primary
                )

                HealthStatCard(
                    title: "Doctors Seen",
                    value: "\(completedAppointments)",
                    icon: "stethoscope",
                    iconColor: .blue
                )

                HealthStatCard(
                    title: "Next Visit",
                    value: nextVisit,
                    icon: "clock",
                    iconColor: AppColors.warning
                )

                HealthStatCard(
                    title: "Missed",
                    value: "\(cancelledAppointments)",
                    icon: "calendar.badge.exclamationmark",
                    iconColor: AppColors.error
                )
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String,showSeeAll: Bool) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            if showSeeAll {
                Button("See all") {
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primary)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    upcomingAppointmentSection

                    specialtiesSection

                    topDoctorsSection

                    healthSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 28)
            }
            .background(AppColors.background)
        }
        .background(AppColors.primary)
        .ignoresSafeArea(edges: .top)
        .navigationDestination(isPresented: $showAppointmentDetail) {
            if let appointment = selectedAppointment {
                AppointmentDetailView(
                    appointment: appointment,
                    viewModel: appointmentViewModel
                )
            }
        }
        .task {
            async let appointmentsTask: Void =
                appointmentViewModel.fetchAppointments()

            async let doctorsTask: Void =
                viewModel.loadDoctors()

            async let specialtiesTask: Void =
                viewModel.loadSpecialties()

            _ = await (
                appointmentsTask,
                doctorsTask,
                specialtiesTask
            )
        }
    }
}

#Preview {
    HomeView()
}
