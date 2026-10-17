//
//  DoctorDetailViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import Foundation
import Observation
import SwiftUI

@Observable
final class DoctorDetailViewModel {
    var selectedDate = Calendar.current.startOfDay(for: .now)
    var selectedTime: String?

    var draftDate = Calendar.current.startOfDay(for: .now)
    var displayedMonth = Calendar.current.component(.month, from: .now)
    var displayedYear = Calendar.current.component(.year, from: .now)
    var showingMonthYearPicker = false

    private(set) var timeSlots: [String] = []
    var isLoadingAvailability = false
    var availabilityError: String?

    let weekdays = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ]

    let months = Calendar.current.monthSymbols

    private let networkService: NetworkService

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }
    
    var allWorkingTimeSlots: [String] {
        (9..<17).flatMap { hour in
            ["\(String(format: "%02d", hour)):00",
             "\(String(format: "%02d", hour)):30"]
        }
    }

    var slotPages: [[String]] {
        let slots = allWorkingTimeSlots
        return stride(from: 0, to: slots.count, by: 6).map { start in
            Array(slots[start..<min(start + 6, slots.count)])
        }
    }
    
    func isWeekend(_ date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.firstWeekday = 2
        return value
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
        return Array(currentYear...currentYear + 10)
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
            print("Failed to load availability: \(error.localizedDescription)")
        }
    }
    
    func openCalendar() {
        draftDate = selectedDate
        displayedMonth = calendar.component(.month, from: draftDate)
        displayedYear = calendar.component(.year, from: draftDate)
        showingMonthYearPicker = false
    }

    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        selectedTime = nil
    }

    func confirmDraftDate() {
        selectDate(draftDate)
    }

    func isPastTime(_ time: String, on date: Date) -> Bool {
        guard Calendar.current.isDateInToday(date),
              let slotDate = dateForTime(time, on: date)
        else {
            return false
        }

        return slotDate <= .now
    }

    func canBook(date: Date, time: String) -> Bool {
        guard !isPastDate(date),
              !isPastTime(time, on: date)
        else {
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

    func selectCalendarDay(_ date: Date) {
        guard !isPastDate(date) else { return }
        draftDate = calendar.startOfDay(for: date)
    }

    func isPastDate(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) <
            calendar.startOfDay(for: .now)
    }

    func isSelectedCalendarDay(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: draftDate)
    }

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
