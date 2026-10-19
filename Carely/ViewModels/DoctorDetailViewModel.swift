//
//  DoctorDetailViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class DoctorDetailViewModel {

    // MARK: - Date Selection

    var selectedDate = Calendar.current.startOfDay(for: .now)
    var selectedTime: String?

    var draftDate = Calendar.current.startOfDay(for: .now)
    var displayedMonth = Calendar.current.component(.month, from: .now)
    var displayedYear = Calendar.current.component(.year, from: .now)
    var showingMonthYearPicker = false

    // MARK: - Availability

    private(set) var timeSlots: [String] = []
    var isLoadingAvailability = false
    var availabilityError: String?

    private let networkService: NetworkService

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Calendar Localization

    func localizedWeekdays(locale: Locale) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2

        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = TimeZone(identifier: "Asia/Baku")
        formatter.dateFormat = "EEE"

        guard let monday = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 1)
        ) else {
            return []
        }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: monday
            ) else {
                return nil
            }

            return formatter.string(from: date)
        }
    }

    func localizedMonths(locale: Locale) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2

        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = TimeZone(identifier: "Asia/Baku")
        formatter.dateFormat = "LLLL"

        return (1...12).compactMap { month in
            guard let date = calendar.date(
                from: DateComponents(
                    year: 2024,
                    month: month,
                    day: 1
                )
            ) else {
                return nil
            }

            return formatter.string(from: date)
        }
    }

    // MARK: - Working Time Slots

    var allWorkingTimeSlots: [String] {
        (9..<17).flatMap { hour in
            [
                "\(String(format: "%02d", hour)):00",
                "\(String(format: "%02d", hour)):30"
            ]
        }
    }

    var slotPages: [[String]] {
        let slots = allWorkingTimeSlots

        return stride(from: 0, to: slots.count, by: 6).map { start in
            Array(slots[start..<min(start + 6, slots.count)])
        }
    }

    // MARK: - Calendar

    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.firstWeekday = 2
        value.timeZone = TimeZone(identifier: "Asia/Baku") ?? .current
        return value
    }

    func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    var availableDates: [Date] {
        (-2...2).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: selectedDate
            )
        }
    }

    var availableYears: [Int] {
        let currentYear = calendar.component(.year, from: .now)
        return Array(currentYear...(currentYear + 10))
    }

    var daysInMonth: [Date?] {
        guard let firstDay = calendar.date(
            from: DateComponents(
                year: displayedYear,
                month: displayedMonth,
                day: 1
            )
        ),
        let dayRange = calendar.range(
            of: .day,
            in: .month,
            for: firstDay
        ) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingSpaces = (weekday + 5) % 7

        var days: [Date?] = Array(
            repeating: nil,
            count: leadingSpaces
        )

        for day in dayRange {
            if let date = calendar.date(
                from: DateComponents(
                    year: displayedYear,
                    month: displayedMonth,
                    day: day
                )
            ) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    // MARK: - Load Availability

    func loadAvailability(for doctorId: Int) async {
        isLoadingAvailability = true
        availabilityError = nil
        selectedTime = nil

        defer {
            isLoadingAvailability = false
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Baku")
        formatter.dateFormat = "yyyy-MM-dd"

        let dateString = formatter.string(from: selectedDate)

        do {
            let response: DoctorAvailabilityDTO =
                try await networkService.request(
                    DoctorAvailabilityEndpoint.availability(
                        doctorId: doctorId,
                        date: dateString
                    ),
                    token: nil
                )

            timeSlots = response.availableSlots
        } catch {
            timeSlots = []
            availabilityError = error.localizedDescription

            print(
                "Failed to load availability: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Open Calendar

    func openCalendar() {
        draftDate = selectedDate
        displayedMonth = calendar.component(.month, from: draftDate)
        displayedYear = calendar.component(.year, from: draftDate)
        showingMonthYearPicker = false
    }

    // MARK: - Date Selection

    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        selectedTime = nil
    }

    func confirmDraftDate() {
        selectDate(draftDate)
    }

    func selectCalendarDay(_ date: Date) {
        guard !isPastDate(date) else {
            return
        }

        draftDate = calendar.startOfDay(for: date)
    }

    func isSelectedCalendarDay(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: draftDate)
    }

    // MARK: - Time Selection

    func isPastTime(_ time: String, on date: Date) -> Bool {
        guard calendar.isDateInToday(date),
              let slotDate = dateForTime(time, on: date) else {
            return false
        }

        return slotDate <= .now
    }

    func canBook(date: Date, time: String) -> Bool {
        guard !isPastDate(date),
              !isPastTime(time, on: date) else {
            return false
        }

        return true
    }

    func selectTime(_ time: String) {
        guard canBook(date: selectedDate, time: time) else {
            selectedTime = nil
            return
        }

        selectedTime = time
    }

    private func dateForTime(_ time: String, on date: Date) -> Date? {
        let components = time.split(separator: ":")

        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              (0...23).contains(hour),
              (0...59).contains(minute) else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Baku") ?? .current

        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        )
    }

    // MARK: - Past Date Validation

    func isPastDate(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) <
            calendar.startOfDay(for: .now)
    }

    // MARK: - Month and Year Selection

    func changeDisplayedMonth(_ month: Int) {
        displayedMonth = month
        adjustDraftDate()
    }

    func changeDisplayedYear(_ year: Int) {
        displayedYear = year
        adjustDraftDate()
    }

    private func adjustDraftDate() {
        guard let firstDay = calendar.date(
            from: DateComponents(
                year: displayedYear,
                month: displayedMonth,
                day: 1
            )
        ),
        let dayRange = calendar.range(
            of: .day,
            in: .month,
            for: firstDay
        ) else {
            return
        }

        let currentDay = calendar.component(.day, from: draftDate)
        let validDay = min(currentDay, dayRange.count)

        draftDate = calendar.date(
            from: DateComponents(
                year: displayedYear,
                month: displayedMonth,
                day: validDay
            )
        ) ?? draftDate
    }
}
