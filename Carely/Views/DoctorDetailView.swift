//
//  DoctorDetailView.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import SwiftUI

struct DoctorDetailView: View {
    let doctor: Doctor
    
    @State private var viewModel = DoctorDetailViewModel()
    @State private var showDatePicker = false
    
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
                        .background(
                            AppColors.primary.opacity(0.10)
                        )
                        .clipShape(Capsule())
                    
                    Text(doctor.name)
                        .font(
                            .system(size: 27, weight: .bold)
                        )
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .lineLimit(2)
                    
                    Text("$\(Int(doctor.consultationFee))")
                        .font(
                            .system(size: 22, weight: .bold)
                        )
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
                    .frame(
                        maxHeight: .infinity,
                        alignment: .bottom
                    )
            }
            .frame(height: 190, alignment: .bottom)
            
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
                    value: String(
                        format: "%.1f",
                        doctor.rating
                    ),
                    title: "Rating"
                )
            }
            .padding(.vertical, 22)
            .background(
                AppColors.primary.opacity(0.10)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 22)
            )
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
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Schedule
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Create Schedule")
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
                                        .month(.abbreviated)
                                        .day()
                                )
                            )
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.primaryText)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12,weight: .semibold))
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
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
                    ForEach(viewModel.availableDates,id: \.self) { date in
                        dateButton(for: date)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Choose a Suitable Time")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible()),
                        count: 3
                    ),
                    spacing: 12
                ) {
                    ForEach(viewModel.timeSlots,id: \.self) { time in
                        timeButton(for: time)
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
                
                Text(viewModel.showingMonthYearPicker ? "Select Month & Year" : "Select Date")
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
                    Text("\(viewModel.months[viewModel.displayedMonth - 1]) \(viewModel.displayedYear.formatted(.number.locale(Locale(identifier: "en_US_POSIX"))))")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AppColors.primary)
                .frame(maxWidth: .infinity,alignment: .leading)
            }
            .buttonStyle(.plain)
            
            HStack(spacing: 0) {
                ForEach(viewModel.weekdays,id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.secondaryText)
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
    
    private var monthYearPicker: some View {
        HStack(spacing: 0) {
            Picker(
                "Month",
                selection: Binding(
                    get: { viewModel.displayedMonth },
                    set: {
                        viewModel.changeDisplayedMonth($0)
                    }
                )
            ) {
                ForEach(1...12,id: \.self) { month in
                    Text(viewModel.months[month - 1])
                        .tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            
            Picker(
                "Year",
                selection: Binding(
                    get: { viewModel.displayedYear },
                    set: {
                        viewModel.changeDisplayedYear($0)
                    }
                )
            ) {
                ForEach(viewModel.availableYears,id: \.self) { year in
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
        let isPastDate = viewModel.isPastDate(date)
        
        return Button {
            viewModel.selectCalendarDay(date)
        } label: {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 15,weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected
                                 ? AppColors.onPrimary
                                 : isPastDate
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
        .disabled(isPastDate)
    }
    
    // MARK: - Date and Time Buttons
    private func dateButton(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(
            date,
            inSameDayAs: viewModel.selectedDate
        )
        
        return Button {
            viewModel.selectDate(date)
        } label: {
            VStack(spacing: 10) {
                Text(
                    date.formatted(
                        .dateTime.weekday(.abbreviated)
                    )
                )
                .font(AppTypography.caption)
                
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(isSelected ? AppColors.primaryText : AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(isSelected ? AppColors.primary.opacity(0.12) : AppColors.background)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func timeButton(for time: String) -> some View {
        let isSelected = viewModel.selectedTime == time
        
        return Button {
            viewModel.selectTime(time)
        } label: {
            Text(time)
                .font(AppTypography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(isSelected ? AppColors.primaryText : AppColors.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isSelected ? AppColors.primary.opacity(0.12) : AppColors.background)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Booking Button
    private var bookingButton: some View {
        VStack(spacing: 0) {
            PrimaryButton(
                title: "Book Appointment",
                isDisabled: !doctor.isAvailable ||
                viewModel.selectedTime == nil
            ) {
                guard let selectedTime = viewModel.selectedTime else {
                    return
                }
                
                print("Doctor: \(doctor.name)")
                print("Date: \(viewModel.selectedDate.formatted(date: .long,time: .omitted))")
                print("Time: \(selectedTime)")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(AppColors.surface)
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
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
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
                    Button(
                        "Share",
                        systemImage: "square.and.arrow.up"
                    ) {
                        // Share functionality will be added later.
                    }
                    
                    Button(
                        "Add to Favorites",
                        systemImage: "heart"
                    ) {
                        // Favorites functionality will be added later.
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(
                            .system(size: 20, weight: .semibold)
                        )
                        .foregroundStyle(AppColors.primaryText)
                }
            }
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
}

