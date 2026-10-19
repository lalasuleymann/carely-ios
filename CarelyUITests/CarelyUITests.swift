//
//  CarelyUITests.swift
//  CarelyUITests
//
//  Created by Lala Suleymanova on 19.10.26.
//

import XCTest

final class CarelyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesSuccessfully() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: 10),
            "Carely should launch and run in the foreground."
        )
    }

    @MainActor
    func testAppointmentsTabIsVisible() {
        let app = XCUIApplication()
        app.launch()

        let appointmentsTab = app.buttons["Appointments"]

        XCTAssertTrue(
            appointmentsTab.waitForExistence(timeout: 10),
            "The Appointments tab should be visible."
        )

        appointmentsTab.tap()

        XCTAssertTrue(
            appointmentsTab.exists,
            "The Appointments tab should remain available."
        )
    }
}
