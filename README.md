# Carely 🩺

**Carely — Your Personal Healthcare Companion**

Carely is an iOS healthcare application built with SwiftUI. It helps users discover doctors, explore medical specialties, search and filter healthcare professionals, manage appointments, and find nearby healthcare facilities.

## Features

### Home
- Personalized home screen.
- Upcoming appointment overview.
- Top doctors ranked by rating.
- Medical specialties.
- Personal health statistics.

### Doctor Search
- Search doctors by name or specialty.
- Filter doctors by medical specialty.
- Filter by minimum rating.
- Filter by minimum consultation fee.
- Filter by availability.
- Loading, empty, and error states.

### Doctor Profiles
- Doctor information and profile images.
- Specialty, ratings, and consultation details.
- Detailed doctor profile navigation.

### Appointments
- View appointment information.
- Filter appointments by status.
- View upcoming, completed, and cancelled appointments.
- Access appointment details.
- Appointment rating and review-related flows.
- Loading, empty, and error states.

### Nearby Healthcare Facilities
- Interactive map powered by MapKit.
- Nearby healthcare locations.
- Appointment-related map markers.
- Category-based location filtering.
- Nearby appointment information panels.

### User Profile and Authentication
- Login and registration screens.
- Authentication flows, including Apple and Google sign-in request models.
- Profile information and editing.
- Password change and password setup flows.
- Local profile photo storage.
- Keychain-backed secure storage utilities.

### Localization and UI Design
- Localization support through `LocalizationManager`.
- Shared color and typography definitions.
- Reusable buttons, cards, search bars, rating views, and state views.

## Technology Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Architecture:** Model–View–ViewModel (MVVM)
- **Concurrency:** Swift Concurrency (`async/await`)
- **State Management:** `@State`, `@Binding`, `@Observable`, and environment values
- **Networking:** `NetworkService`, `DefaultNetworkService`, and endpoint abstractions
- **Navigation:** `NavigationStack`, sheets, and tab navigation
- **Maps:** MapKit
- **Image Loading:** SwiftUI `AsyncImage`
- **Local Data:** SwiftData and local file storage
- **Secure Storage:** Keychain service
- **Localization:** `LocalizationManager`
- **Testing:** XCTest
- **Dependencies:** Swift Package Manager

## Architecture

Carely follows the MVVM architecture to separate the user interface, presentation logic, and data access.

- **Views** display the interface and forward user interactions.
- **ViewModels** manage presentation state and feature logic.
- **Services** handle authentication, nearby place data, specialties, and other external data access.
- **Networking** contains request handling, HTTP definitions, network errors, and endpoint definitions.
- **Models** represent application data.
- **DTOs** define API request and response structures.
- **View states** represent loading, success, empty, and error states.
- **Reusable components** provide consistent UI elements across the application.

## Project Structure

```text
Carely/
├── Components/
│   ├── Buttons/
│   │   └── PrimaryButton.swift
│   ├── Cards/
│   │   ├── AppointmentCard.swift
│   │   ├── DoctorCard.swift
│   │   ├── HealthStatCard.swift
│   │   ├── SpecialtyCard.swift
│   │   ├── TopDoctorCard.swift
│   │   └── UpcomingAppointmentCard.swift
│   ├── StateViews/
│   │   ├── EmptyStateView.swift
│   │   └── ErrorStateView.swift
│   ├── NearbyAppointmentPanel.swift
│   ├── NearbyAppointmentRow.swift
│   ├── RatingView.swift
│   └── SearchBar.swift
├── Config/
│   └── APIConfig.swift
├── Models/
│   ├── DTOs/
│   │   ├── Request/
│   │   └── Response/
│   ├── Networking/
│   │   └── Endpoints/
│   ├── Appointment.swift
│   ├── Doctor.swift
│   ├── MockDoctorData.swift
│   ├── NearbyLocationGroup.swift
│   ├── NearbyPlace.swift
│   └── NearbyPlaceCategory.swift
├── Screens/
│   ├── Views/
│   │   ├── AppointmentDetailView.swift
│   │   ├── AppointmentRatingView.swift
│   │   ├── ChangePasswordView.swift
│   │   ├── DoctorDetailView.swift
│   │   ├── EditProfileView.swift
│   │   ├── FacilityDoctorsView.swift
│   │   ├── FilterSheetView.swift
│   │   ├── PersonalInformationView.swift
│   │   ├── SetPasswordView.swift
│   │   └── SettingsView.swift
│   ├── AppointmentsView.swift
│   ├── AuthRootView.swift
│   ├── HomeView.swift
│   ├── LoginView.swift
│   ├── MainTabView.swift
│   ├── NearbyView.swift
│   ├── ProfileView.swift
│   ├── RegisterView.swift
│   └── SearchView.swift
├── Services/
│   ├── AuthService.swift
│   ├── NearbyPlacesService.swift
│   └── SpecialtyService.swift
├── Utilities/
│   ├── AppColors.swift
│   ├── AppTypography.swift
│   ├── KeychainService.swift
│   ├── LocalizationManager.swift
│   └── SpecialtyIconProvider.swift
├── ViewModels/
│   ├── ViewStates/
│   │   ├── AppointmentsViewState.swift
│   │   ├── NearbyPlacesViewState.swift
│   │   └── SearchViewState.swift
│   ├── AppointmentViewModel.swift
│   ├── AuthViewModel.swift
│   ├── DoctorDetailViewModel.swift
│   ├── HomeViewModel.swift
│   ├── NearbyViewModel.swift
│   ├── ProfileViewModel.swift
│   └── SearchViewModel.swift
├── CarelyTests/
│   └── CarelyTests.swift
└── CarelyUITests/
    └── CarelyUITests.swift
```

## Testing

Carely includes unit tests for `AppointmentViewModel` and UI tests for core application behavior.

### Unit Tests

The `AppointmentViewModelTests` suite covers:

- Initial appointment status.
- Selecting completed and cancelled statuses.
- Filtering appointments by selected status.
- Appointment cancellation rules.
- Appointment status titles.
- Consultation fee formatting.
- Successful appointment loading using a mock network service.
- Network error handling.
- Missing authentication token handling.
- Empty API response handling.

`MockNetworkService` supplies controlled responses for network-related unit tests, avoiding live API requests in those tests.

### UI Tests

The `CarelyUITests` suite covers:

- Successful app launch.
- Visibility and selection of the Appointments tab.

### Running Tests

1. Open `Carely.xcodeproj` in Xcode.
2. Select an iOS Simulator.
3. Run **Product → Test** (`⌘U`).

## Getting Started

### Requirements

- macOS.
- A compatible version of Xcode.
- An iOS Simulator or a compatible iPhone.
- Access to the Carely backend API.

### Run the App

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Open `Carely.xcodeproj` in Xcode.
3. Configure the API base URL and any required local settings.
4. Select an iOS Simulator or connected device.
5. Build and run the app.

Carely uses a backend API to retrieve application data. The backend must be available and the API configuration must be valid for network-dependent features to work.

Do not commit API credentials, access tokens, passwords, or other secrets to source control.

## Continuous Integration

GitHub Actions can build and test Carely automatically on every push and pull request. Workflow results are available in the repository's **Actions** tab.

## Author

**Lala Suleymanova**

iOS Development · Swift · SwiftUI
