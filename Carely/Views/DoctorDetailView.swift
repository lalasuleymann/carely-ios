//
//  DoctorDetailView.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import SwiftUI

struct DoctorDetailView: View {
    let doctor: Doctor

    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var selectedTime: String? = nil

    private let timeSlots = [
        "10:00 am",
        "10:30 am",
        "11:00 am",
        "11:30 am",
        "12:00 pm",
        "12:30 pm"
    ]

    private var availableDates: [Date] {
        (0..<5).compactMap { offset in
            Calendar.current.date(
                byAdding: .day,
                value: offset,
                to: Calendar.current.startOfDay(for: .now)
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileSection
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                scheduleSection
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            topTrailingRadius: 28
                        )
                    )
            }
        }
        .background(AppColors.background)
        .navigationTitle("Doctor Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Share", systemImage: "square.and.arrow.up") {
                        // Share functionality will be added later.
                    }

                    Button("Add to Favorites", systemImage: "heart") {
                        // Favorites functionality will be added later.
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bookingButton
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(doctor.specialty)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            AppColors.primary.opacity(0.10)
                        )
                        .clipShape(Capsule())

                    Text(doctor.name)
                        .font(.system(size: 27, weight: .bold))
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)

                    Text("$\(Int(doctor.consultationFee))")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                }

                Spacer(minLength: 0)

                Image(systemName: "person.crop.rectangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(
                        AppColors.primary.opacity(0.75)
                    )
                    .frame(width: 140, height: 190)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 220, alignment: .bottom)

            HStack(spacing: 0) {
                statistic(
                    value: "\(doctor.experience)y+",
                    title: "Experience"
                )

                statistic(
                    value: "—",
                    title: "Patients"
                )

                statistic(
                    value: "\(doctor.reviewCount)",
                    title: "Reviews"
                )

                statistic(
                    value: String(format: "%.1f", doctor.rating),
                    title: "Rating"
                )
            }
            .padding(.vertical, 22)
            .background(
                AppColors.primary.opacity(0.10)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }

    private func statistic(
        value: String,
        title: String
    ) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Create Schedule")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(systemName: "calendar")
                        .foregroundStyle(AppColors.primary)

                    Text(selectedDate.formatted(.dateTime.month(.abbreviated).day()))
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                }

                Text("Easily plan your appointment at a time")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Choose a Date")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                HStack(spacing: 10) {
                    ForEach(availableDates, id: \.self) { date in
                        dateButton(for: date)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Choose a Suitable Time")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(timeSlots, id: \.self) { time in
                        timeButton(for: time)
                    }
                }
            }
        }
    }

    private func dateButton(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(
            date,
            inSameDayAs: selectedDate
        )

        return Button {
            selectedDate = date
            selectedTime = nil
        } label: {
            VStack(spacing: 10) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(AppTypography.caption)

                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(
                isSelected
                    ? AppColors.primaryText
                    : AppColors.secondaryText
            )
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                isSelected
                    ? AppColors.primary.opacity(0.12)
                    : AppColors.background
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private func timeButton(for time: String) -> some View {
        let isSelected = selectedTime == time

        return Button {
            selectedTime = time
        } label: {
            Text(time)
                .font(AppTypography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(
                    isSelected
                        ? AppColors.primaryText
                        : AppColors.secondaryText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    isSelected
                        ? AppColors.primary.opacity(0.12)
                        : AppColors.background
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var bookingButton: some View {
        VStack(spacing: 0) {
            PrimaryButton(
                title: "Book Appointment",
                isDisabled: !doctor.isAvailable || selectedTime == nil
            ) {
                guard let selectedTime else { return }

                print("Doctor: \(doctor.name)")
                print("Date: \(selectedDate.formatted(date: .long, time: .omitted))")
                print("Time: \(selectedTime)")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(AppColors.surface)
    }
}

#Preview {
    NavigationStack {
        DoctorDetailView(
            doctor: MockDoctorData.doctors[0]
        )
    }
}
