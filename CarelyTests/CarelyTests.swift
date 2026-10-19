//
//  CarelyTests.swift
//  CarelyTests
//
//  Created by Lala Suleymanova on 19.10.26.
//

import XCTest
import SwiftData
@testable import Carely

@MainActor
final class AppointmentViewModelTests: XCTestCase {

    private var viewModel: AppointmentViewModel!
    private var modelContext: ModelContext!
    private var modelContainer: ModelContainer!

    override func setUp() {
        super.setUp()

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        modelContainer = try! ModelContainer(
            for: Appointment.self,
            configurations: configuration
        )

        modelContext = ModelContext(modelContainer)

        viewModel = AppointmentViewModel(
            tokenProvider: { "test-token" }
        )

        viewModel.configure(context: modelContext)
    }

    override func tearDown() {
        viewModel = nil
        modelContext = nil
        modelContainer = nil

        super.tearDown()
    }

    // MARK: - Initial State
    func testInitialSelectedStatusIsUpcoming() {
        XCTAssertEqual(viewModel.selectedStatus, .upcoming)
    }

    // MARK: - Status Selection
    func testSelectCompletedUpdatesSelectedStatus() {
        viewModel.selectStatus(.completed)

        XCTAssertEqual(viewModel.selectedStatus, .completed)
    }

    func testSelectCancelledUpdatesSelectedStatus() {
        viewModel.selectStatus(.cancelled)

        XCTAssertEqual(viewModel.selectedStatus, .cancelled)
    }

    // MARK: - Appointment Filtering
    func testFilteredAppointmentsReturnsOnlySelectedStatus() {
        let upcoming = makeAppointment(
            doctorName: "Dr. A",
            status: .upcoming
        )

        let completed = makeAppointment(
            doctorName: "Dr. B",
            status: .completed
        )

        let cancelled = makeAppointment(
            doctorName: "Dr. C",
            status: .cancelled
        )

        modelContext.insert(upcoming)
        modelContext.insert(completed)
        modelContext.insert(cancelled)

        viewModel.configure(context: modelContext)

        XCTAssertEqual(viewModel.filteredAppointments.count, 1)
        XCTAssertEqual(
            viewModel.filteredAppointments.first?.doctorName,
            "Dr. A"
        )

        viewModel.selectStatus(.completed)

        XCTAssertEqual(viewModel.filteredAppointments.count, 1)
        XCTAssertEqual(
            viewModel.filteredAppointments.first?.doctorName,
            "Dr. B"
        )

        viewModel.selectStatus(.cancelled)

        XCTAssertEqual(viewModel.filteredAppointments.count, 1)
        XCTAssertEqual(
            viewModel.filteredAppointments.first?.doctorName,
            "Dr. C"
        )
    }

    // MARK: - Cancellation Rules
    func testCanCancelUpcomingAppointment() {
        let appointment = makeAppointment(status: .upcoming)

        XCTAssertTrue(viewModel.canCancel(appointment))
    }

    func testCannotCancelCompletedAppointment() {
        let appointment = makeAppointment(status: .completed)

        XCTAssertFalse(viewModel.canCancel(appointment))
    }

    func testCannotCancelCancelledAppointment() {
        let appointment = makeAppointment(status: .cancelled)

        XCTAssertFalse(viewModel.canCancel(appointment))
    }

    // MARK: - Appointment Information
    func testStatusTitleForUpcomingAppointment() {
        let appointment = makeAppointment(status: .upcoming)

        XCTAssertEqual(
            viewModel.statusTitle(for: appointment),
            "Upcoming"
        )
    }

    func testStatusTitleForCompletedAppointment() {
        let appointment = makeAppointment(status: .completed)

        XCTAssertEqual(
            viewModel.statusTitle(for: appointment),
            "Completed"
        )
    }

    func testStatusTitleForCancelledAppointment() {
        let appointment = makeAppointment(status: .cancelled)

        XCTAssertEqual(
            viewModel.statusTitle(for: appointment),
            "Cancelled"
        )
    }

    func testFormattedFeeReturnsDollarAmount() {
        let appointment = makeAppointment(
            consultationFee: 75.0
        )

        XCTAssertEqual(
            viewModel.formattedFee(for: appointment),
            "$75"
        )
    }

    // MARK: - Fetch Appointments
    func testFetchAppointmentsLoadsServerData() async {
        let mock = MockNetworkService()

        mock.result = .success([
            makeDTO(id: 1, status: "upcoming"),
            makeDTO(id: 2, status: "completed")
        ])

        let testViewModel = AppointmentViewModel(
            networkService: mock,
            tokenProvider: { "test-token" }
        )

        await testViewModel.fetchAppointments()

        XCTAssertEqual(mock.requestCount, 1)
        XCTAssertEqual(
            testViewModel.upcomingAppointments.count,
            1
        )
        XCTAssertEqual(
            testViewModel.filteredAppointments.count,
            1
        )

        if case .loaded = testViewModel.state {
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func testFetchAppointmentsHandlesNetworkError() async {
        let mock = MockNetworkService()

        mock.result = .failure(
            NetworkError.noInternetConnection
        )

        let testViewModel = AppointmentViewModel(
            networkService: mock,
            tokenProvider: { "test-token" }
        )

        await testViewModel.fetchAppointments()

        XCTAssertEqual(mock.requestCount, 1)

        if case .error(let message) = testViewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected error state")
        }
    }

    func testFetchAppointmentsWithoutTokenDoesNotCallNetwork() async {
        let mock = MockNetworkService()

        let testViewModel = AppointmentViewModel(
            networkService: mock,
            tokenProvider: { nil }
        )

        await testViewModel.fetchAppointments()

        XCTAssertEqual(mock.requestCount, 0)

        if case .error(let message) = testViewModel.state {
            XCTAssertTrue(
                message.contains("log in again")
            )
        } else {
            XCTFail("Expected error state")
        }
    }

    func testFetchAppointmentsWithEmptyResponseSetsEmptyState() async {
        let mock = MockNetworkService()
        mock.result = .success([])

        let testViewModel = AppointmentViewModel(
            networkService: mock,
            tokenProvider: { "test-token" }
        )

        await testViewModel.fetchAppointments()

        XCTAssertEqual(mock.requestCount, 1)

        if case .empty = testViewModel.state {
            // Expected state
        } else {
            XCTFail("Expected empty state")
        }
    }

    // MARK: - Test Data
    private func makeAppointment(doctorName: String = "Dr. Test",consultationFee: Double = 50.0,status: AppointmentStatus = .upcoming) -> Appointment {
        Appointment(
            serverID: 1,
            doctorID: 10,
            doctorName: doctorName,
            specialty: "Cardiology",
            facilityName: "Carely Clinic",
            date: Date().addingTimeInterval(86_400),
            time: "10:00 AM",
            consultationFee: consultationFee,
            status: status
        )
    }

    private func makeDTO(id: Int = 1,status: String = "upcoming") -> AppointmentDTO {
        AppointmentDTO(
            id: id,
            doctorId: 10,
            doctorName: "Dr. Test",
            specialty: "Cardiology",
            facilityName: "Carely Clinic",
            consultationFee: 50,
            startAt: "2027-01-15T10:00:00.000Z",
            endAt: "2027-01-15T10:30:00.000Z",
            status: status,
            notes: nil,
            createdAt: "2026-10-19T10:00:00.000Z",
            hasReview: false,
            myRating: nil
        )
    }
}

// MARK: - Mock Network Service
private final class MockNetworkService: NetworkService {

    var result: Result<[AppointmentDTO], Error> = .success([])
    private(set) var requestCount = 0

    func request<T: Decodable>(_ endpoint: Endpoint,token: String?) async throws -> T {
        requestCount += 1

        let response = try result.get()

        guard let typedResponse = response as? T else {
            throw NetworkError.decodingError
        }

        return typedResponse
    }
}
