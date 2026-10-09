//
//  DoctorDetailViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import Foundation
import Observation

@Observable
final class DoctorDetailViewModel {
    var selectedDate = Calendar.current.startOfDay(for: .now)
    var selectedTime: String?

    var draftDate = Calendar.current.startOfDay(for: .now)
    var displayedMonth = Calendar.current.component(.month, from: .now)
    var displayedYear = Calendar.current.component(.year, from: .now)
    var showingMonthYearPicker = false

    let timeSlots = [
        "10:00 am",
        "10:30 am",
        "11:00 am",
        "11:30 am",
        "12:00 pm",
        "12:30 pm"
    ]

    let weekdays = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ]

    let months = Calendar.current.monthSymbols

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

    func selectTime(_ time: String) {
        selectedTime = time
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
