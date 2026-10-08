//
//  HomeView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good morning")
                        .font(AppTypography.body)
                        .foregroundStyle(
                            AppColors.onPrimary.opacity(0.8)
                        )

                    Text("Alex Johnson")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.onPrimary)
                }

                Spacer()

                HStack(spacing: 12) {
                    notificationButton

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.onPrimary)
                }
            }

            SearchBar(
                text: $viewModel.searchText,
                placeholder: "Search doctors, specialties..."
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .padding(.bottom, 28)
        .background(AppColors.primary)
    }

    // MARK: - Notification Button
    private var notificationButton: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColors.onPrimary)
                .frame(width: 48, height: 48)
                .background(
                    AppColors.onPrimary.opacity(0.15)
                )
                .clipShape(Circle())

            Circle()
                .fill(AppColors.error)
                .frame(width: 9, height: 9)
                .overlay {
                    Circle()
                        .stroke(
                            AppColors.primary,
                            lineWidth: 2
                        )
                }
                .offset(x: -4, y: 4)
        }
    }
    
    // MARK: - Upcoming Appointment
    private var upcomingAppointmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Appointments")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            UpcomingAppointmentCard(
                doctorName: "Dr. Sarah Mitchell",
                specialty: "Cardiologist",
                date: "Thu, Sep 25, 2026",
                time: "10:00 AM",
                appointmentType: "In-Person"
            ) {
                print("Appointment tapped")
            }
        }
    }

    // MARK: - Specialties
    private var specialtiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Specialties", showSeeAll: false)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    SpecialtyCard(
                        title: "Cardiology",
                        icon: "heart.text.square"
                    )

                    SpecialtyCard(
                        title: "Neurology",
                        icon: "brain.head.profile"
                    )

                    SpecialtyCard(
                        title: "Dermatology",
                        icon: "person.crop.circle"
                    )

                    SpecialtyCard(
                        title: "Dentistry",
                        icon: "mouth"
                    )
                }
            }
        }
    }

    // MARK: - Top Doctors
    private var topDoctorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Top Doctors", showSeeAll: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.doctors) { doctor in
                        TopDoctorCard(doctor: doctor)
                    }
                }
            }
        }
    }

    // MARK: - Your Health
    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    value: "12",
                    icon: "calendar",
                    iconColor: AppColors.primary
                )

                HealthStatCard(
                    title: "Doctors Seen",
                    value: "5",
                    icon: "stethoscope",
                    iconColor: .blue
                )

                HealthStatCard(
                    title: "Next Visit",
                    value: "Sep 25",
                    icon: "clock",
                    iconColor: AppColors.warning
                )

                HealthStatCard(
                    title: "Prescriptions",
                    value: "2",
                    icon: "pills",
                    iconColor: AppColors.success
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
                    print("See all \(title)")
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
    }
}

#Preview {
    HomeView()
}
