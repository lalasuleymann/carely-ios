//
//  HomeView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI
import UIKit

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var localProfileImage: UIImage?

    @Environment(AuthViewModel.self)
    private var authViewModel

    @Environment(AppointmentViewModel.self)
    private var appointmentViewModel

    @Environment(\.selectedTab)
    private var selectedTab

    @Environment(\.locale)
    private var locale

    @State private var selectedAppointment: Appointment?
    @State private var showAppointmentDetail = false
    
    @State private var profileViewModel = ProfileViewModel()

    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }

    // MARK: - User Information
    private var userFullName: String {
        let firstName = (
            profileViewModel.profile?.firstName
            ?? authViewModel.currentUser?.firstName
            ?? ""
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)

        let lastName = (
            profileViewModel.profile?.lastName
            ?? authViewModel.currentUser?.lastName
            ?? ""
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)

        let fullName = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return fullName.isEmpty ? " " : fullName
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
            if let localProfileImage {
                Image(uiImage: localProfileImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageURL = authViewModel.currentUser?.profileImageUrl,
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

                    case .failure:
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
    
    private func loadSavedProfilePhoto() {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let photoURL = documentsDirectory.appendingPathComponent(
            "carely-profile-photo.jpg"
        )

        guard
            let data = try? Data(contentsOf: photoURL),
            let image = UIImage(data: data)
        else {
            localProfileImage = nil
            return
        }

        localProfileImage = image
    }


    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localize(viewModel.greeting()))
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
                .accessibilityLabel(Text(localize("Open profile")))
            }

            ZStack {
                SearchBar(
                    text: $viewModel.searchText,
                    placeholder: localize("Search doctors, specialties...")
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
            Text(localize("Upcoming Appointment"))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            switch appointmentViewModel.state {
            case .idle, .loading:
                ProgressView(localize("Loading appointment..."))
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
                    let doctor = viewModel.doctors.first {
                        $0.id == appointment.doctorID
                    }

                    if let doctor {
                        UpcomingAppointmentCard(
                            doctorName: appointment.doctorName,
                            doctor: doctor,
                            specialty: localize(appointment.specialty),
                            date: appointment.date.formatted(
                                .dateTime
                                    .weekday(.abbreviated)
                                    .month(.abbreviated)
                                    .day()
                                    .year()
                                    .locale(locale)
                            ),
                            time: appointment.time,
                            appointmentType: localize("In-Person")
                        ) {
                            selectedAppointment = appointment
                            showAppointmentDetail = true
                        }
                        .buttonStyle(.plain)
                    } else {
                        emptyUpcomingAppointment
                    }
                }
            case .error(let message):
                VStack(alignment: .leading, spacing: 8) {
                    Text(localize("Could not load appointments"))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)

                    Text(message)
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)

                    Button(localize("Try Again")) {
                        Task {
                            await appointmentViewModel.fetchAppointments()
                        }
                    }
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primary)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
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

            Text(localize("No upcoming appointment"))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)

            Text(localize("Your next appointment will appear here."))
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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
                Text(localize("No specialties available."))
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(spacing: 12) {
                        ForEach(
                            viewModel.specialties,
                            id: \.id
                        ) { specialty in
                            SpecialtyCard(
                                title: localize(specialty.name),
                                icon: SpecialtyIconProvider.icon(
                                    for: specialty.name
                                )
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

            let topDoctors = Array(
                viewModel.doctors
                    .sorted { first, second in
                        if first.rating == second.rating {
                            return first.reviewCount > second.reviewCount
                        }

                        return first.rating > second.rating
                    }
                    .prefix(5)
            )

            if topDoctors.isEmpty {
                Text(localize("No doctors available right now."))
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            } else {
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(spacing: 12) {
                        ForEach(topDoctors) { doctor in
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

        let completedAppointments =
            viewModel.completedAppointmentCount(
                from: appointments
            )

        let nextVisit = viewModel.formattedNextVisit(
            from: appointments
        )

        let cancelledAppointments =
            viewModel.cancelledAppointmentCount(
                from: appointments
            )

        return VStack(alignment: .leading, spacing: 12) {
            Text(localize("Your Health"))
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
                    title: localize("Appointments"),
                    value: "\(totalAppointments)",
                    icon: "calendar",
                    iconColor: AppColors.primary
                )

                HealthStatCard(
                    title: localize("Doctors Seen"),
                    value: "\(completedAppointments)",
                    icon: "stethoscope",
                    iconColor: .blue
                )

                HealthStatCard(
                    title: localize("Next Visit"),
                    value: nextVisit,
                    icon: "clock",
                    iconColor: AppColors.warning
                )

                HealthStatCard(
                    title: localize("Missed"),
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
            Text(localize(title))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            if showSeeAll {
                Button(localize("See all")) {
                    // Add navigation if needed.
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
                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {
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
        .navigationDestination(
            isPresented: $showAppointmentDetail
        ) {
            if let appointment = selectedAppointment {
                AppointmentDetailView(
                    appointment: appointment,
                    viewModel: appointmentViewModel,
                    doctor: viewModel.doctors.first {
                        $0.id == appointment.doctorID
                    }
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

            async let profileTask: Void =
                profileViewModel.loadProfile(locale: locale)

            _ = await (
                appointmentsTask,
                doctorsTask,
                specialtiesTask,
                profileTask
            )
        }
        .onAppear {
            loadSavedProfilePhoto()
        }
        .onChange(of: selectedTab.wrappedValue) { _, newTab in
            if newTab == 0 {
                loadSavedProfilePhoto()
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
