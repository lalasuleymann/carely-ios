//
//  DoctorDetailView.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import SwiftUI
import SwiftData

struct DoctorDetailView: View {
    let doctor: Doctor

    @Environment(AppointmentViewModel.self)
    private var appointmentViewModel

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.selectedTab)
    private var selectedTab

    @State private var showBookingConfirmation = false
    @State private var viewModel = DoctorDetailViewModel()
    @State private var showDatePicker = false
    
    @Environment(\.locale) private var locale

    var onBookingConfirmed: (() -> Void)? = nil
    @State private var slotPage = 0
    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }
    
    // MARK: - Doctor Profile
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(doctor.specialty)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.primary.opacity(0.10))
                        .clipShape(Capsule())

                    Text(doctor.name)
                        .font(.system(size: 27, weight: .bold))
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)

                    Text("₼\(Int(doctor.consultationFee))")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                }

                Spacer(minLength: 0)

                Image(systemName: "person.crop.rectangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColors.primary.opacity(0.75))
                    .frame(width: 140, height: 190)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 190, alignment: .bottom)

            HStack(spacing: 0) {
                statistic(
                    value: "\(doctor.experience)y+",
                    title: localize("Experience")
                )

                statistic(
                    value: "—",
                    title: localize("Patients")
                )

                statistic(
                    value: "\(doctor.reviewCount)",
                    title: localize("Reviews")
                    
                )

                statistic(
                    value: doctor.reviewCount > 0
                        ? String(format: "%.1f", doctor.rating)
                        : "—",
                    title: localize("Rating")
                )
            }
            .padding(.vertical, 22)
            .background(AppColors.primary.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }

    private func statistic(value: String,title: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Schedule
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(localize("Create Schedule"))
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Button {
                        viewModel.openCalendar()
                        showDatePicker = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundStyle(AppColors.primary)

                            Text(
                                viewModel.selectedDate.formatted(
                                    .dateTime
                                        .locale(locale)
                                        .month(.abbreviated)
                                        .day()
                                )
                            )
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.primaryText)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text(localize("Easily plan your appointment at a time"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(localize("Choose a Date"))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                HStack(spacing: 10) {
                    ForEach(viewModel.availableDates, id: \.self) { date in
                        dateButton(for: date)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(localize("Choose a Suitable Time"))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                if viewModel.isWeekend(viewModel.selectedDate) {
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 28))
                            .foregroundStyle(AppColors.secondaryText)

                        Text(localize("Not Available on Weekends"))
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.primaryText)

                        Text(
                            localize(
                                "This doctor is not available on Saturdays and Sundays. Please choose a weekday."
                            )
                        )
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                } else if viewModel.isLoadingAvailability {
                    ProgressView(localize("Loading available times..."))
                        .tint(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)

                } else if let error = viewModel.availabilityError {
                    VStack(spacing: 8) {
                        Text(error)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.center)

                        Button(localize("Try Again")) {
                            Task {
                                await viewModel.loadAvailability(for: doctor.id)
                            }
                        }
                        .foregroundStyle(AppColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)

                } else {
                    VStack(spacing: 12) {
                        TabView(selection: $slotPage) {
                            ForEach(Array(viewModel.slotPages.enumerated()),id: \.offset) { index, page in
                                LazyVGrid(
                                    columns: Array(
                                        repeating: GridItem(
                                            .flexible(),
                                            spacing: 10
                                        ),
                                        count: 3
                                    ),
                                    spacing: 10
                                ) {
                                    ForEach(page, id: \.self) { time in
                                        timeButton(
                                            for: time,
                                            isAvailable: viewModel.timeSlots.contains(time)
                                        )
                                    }
                                }
                                .padding(.horizontal, 2)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 108)

                        if viewModel.slotPages.count > 1 {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 10))

                                Text(localize("Swipe to see more times"))
                                    .font(.system(size: 11))

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(AppColors.secondaryText)

                            HStack(spacing: 6) {
                                ForEach(viewModel.slotPages.indices,id: \.self) { index in
                                    Capsule()
                                        .fill(
                                            slotPage == index
                                            ? AppColors.primary
                                            : AppColors.secondaryText.opacity(0.25)
                                        )
                                        .frame(width: slotPage == index ? 18 : 6,height: 6)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
   
    // MARK: - Calendar Sheet
    private var calendarSheet: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") {
                    showDatePicker = false
                }
                .foregroundStyle(AppColors.secondaryText)

                Spacer()

                Text(
                    viewModel.showingMonthYearPicker ? "Select Month & Year" : "Select Date"
                )
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)

                Spacer()

                if viewModel.showingMonthYearPicker {
                    Button("Back") {
                        viewModel.showingMonthYearPicker = false
                    }
                    .foregroundStyle(AppColors.primary)
                } else {
                    Button("Done") {
                        viewModel.confirmDraftDate()
                        showDatePicker = false

                        Task {
                            await viewModel.loadAvailability(
                                for: doctor.id
                            )
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primary)
                }
            }

            if viewModel.showingMonthYearPicker {
                monthYearPicker
            } else {
                calendarGrid
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private var calendarGrid: some View {
        VStack(spacing: 20) {
            Button {
                viewModel.showingMonthYearPicker = true
            } label: {
                HStack(spacing: 6) {
                    Text(
                        formattedDisplayedMonth
                    )
                    .font(.system(size: 17, weight: .semibold))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AppColors.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            HStack(spacing: 0) {
                ForEach(Array(viewModel.localizedWeekdays(locale: locale).enumerated()),id: \.offset) { _, day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 0),
                    count: 7
                ),
                spacing: 8
            ) {
                ForEach(viewModel.daysInMonth.indices,id: \.self) { index in
                    if let date = viewModel.daysInMonth[index] {
                        calendarDayButton(date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }

    private var formattedDisplayedMonth: String {
        var components = DateComponents()
        components.year = viewModel.displayedYear
        components.month = viewModel.displayedMonth
        components.day = 1

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale

        let date = calendar.date(from: components) ?? .now

        return date.formatted(
            .dateTime
                .locale(locale)
                .month(.wide)
                .year()
        )
        .capitalized
    }
    
    private var monthYearPicker: some View {
        HStack(spacing: 0) {
            Picker(
                "Month",
                selection: Binding(
                    get: { viewModel.displayedMonth },
                    set: { viewModel.changeDisplayedMonth($0) }
                )
            ) {
                ForEach(Array(viewModel.localizedMonths(locale: locale).enumerated()),id: \.offset) { index, month in
                    Text(month.capitalized)
                        .tag(index + 1)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Picker(
                "Year",
                selection: Binding(
                    get: { viewModel.displayedYear },
                    set: { viewModel.changeDisplayedYear($0) }
                )
            ) {
                ForEach(viewModel.availableYears, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 220)
    }

    private func calendarDayButton(_ date: Date) -> some View {
        let isSelected = viewModel.isSelectedCalendarDay(date)
        let pastDate = viewModel.isPastDate(date)

        return Button {
            viewModel.selectCalendarDay(date)
        } label: {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 15,weight: isSelected ? .bold : .regular))
                .foregroundStyle(
                    isSelected ? AppColors.onPrimary : pastDate
                            ? AppColors.secondaryText.opacity(0.4)
                            : AppColors.primaryText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background {
                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 38, height: 38)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(pastDate)
    }

    // MARK: - Date and Time Buttons
    private func dateButton(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(
            date,
            inSameDayAs: viewModel.selectedDate
        )

        let pastDate = viewModel.isPastDate(date)

        let weekdayIndex = (Calendar(identifier: .gregorian)
                .component(.weekday, from: date) + 5) % 7

        let weekdays = viewModel.localizedWeekdays(locale: locale)

        let weekdayTitle = weekdays.indices.contains(weekdayIndex) ? weekdays[weekdayIndex] : ""

        return Button {
            viewModel.selectDate(date)

            Task {
                await viewModel.loadAvailability(for: doctor.id)
            }
        } label: {
            VStack(spacing: 10) {
                Text(weekdayTitle)
                    .font(AppTypography.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(date.formatted(.dateTime.locale(locale).day()))
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(
                pastDate ? AppColors.secondaryText.opacity(0.4) : isSelected
                        ? AppColors.primaryText
                        : AppColors.secondaryText
            )
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                isSelected ? AppColors.primary.opacity(0.12) : AppColors.background
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(pastDate)
    }

    private func timeButton(for time: String,isAvailable: Bool) -> some View {
        let isSelected = viewModel.selectedTime == time
        let isPast = viewModel.isPastTime(
            time,
            on: viewModel.selectedDate
        )

        let isDisabled = !isAvailable || isPast ||
            viewModel.isLoadingAvailability

        return Button {
            viewModel.selectTime(time)
        } label: {
            Text(displayTime(time))
                .font(AppTypography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(
                    isDisabled ? AppColors.secondaryText.opacity(0.4) : isSelected
                            ? AppColors.primaryText
                            : AppColors.secondaryText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    isSelected ? AppColors.primary.opacity(0.15) : isDisabled
                            ? AppColors.secondaryText.opacity(0.08)
                            : AppColors.background
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? AppColors.primary : Color.clear,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private func displayTime(_ time: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "HH:mm"

        guard let date = inputFormatter.date(from: time) else {
            return time
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "h:mm a"

        return outputFormatter.string(from: date)
    }

    // MARK: - Booking Button
    private var bookingButton: some View {
        VStack(spacing: 0) {
            PrimaryButton(
                title: localize("Book Appointment"),
                isDisabled: viewModel.selectedTime == nil ||
                    viewModel.isLoadingAvailability ||
                    viewModel.availabilityError != nil
            ) {
                guard let selectedTime = viewModel.selectedTime else {
                    return
                }

                guard viewModel.canBook(
                    date: viewModel.selectedDate,
                    time: selectedTime
                ) else {
                    return
                }

                appointmentViewModel.bookAppointment(
                    doctor: doctor,
                    date: viewModel.selectedDate,
                    time: selectedTime
                )

                showBookingConfirmation = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(AppColors.surface)
        .alert(
            "Appointment Booked",
            isPresented: $showBookingConfirmation
        ) {
            Button("OK") {
                if let onBookingConfirmed {
                    onBookingConfirmed()
                } else {
                    selectedTab.wrappedValue = 2
                }
            }
        } message: {
            Text(
                "\(doctor.name) üçün \(viewModel.selectedDate.formatted(date: .long, time: .omitted)), saat \(displayTime(viewModel.selectedTime ?? "")) rezervasiya edildi."
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileSection
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

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
        .task {
            appointmentViewModel.configure(context: modelContext)
            await viewModel.loadAvailability(for: doctor.id)
        }     
        .sheet(isPresented: $showDatePicker) {
            calendarSheet
                .presentationDetents([.medium, .large])
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bookingButton
        }
    }
}

#Preview {
    NavigationStack {
        DoctorDetailView(
            doctor: MockDoctorData.doctors[0]
        )
    }
    .environment(AppointmentViewModel())
}
