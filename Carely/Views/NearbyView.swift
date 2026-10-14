//
//  NearbyView.swift
//  Carely
//
//  Created by Lala Suleymanova on 13.10.26.
//

import SwiftUI
import MapKit
import SwiftData

struct NearbyView: View {

    @Environment(AppointmentViewModel.self)
    private var appointmentViewModel

    @Environment(\.modelContext)
    private var modelContext

    @State private var viewModel = NearbyViewModel()
    @State private var selectedAppointment: Appointment?

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.secondaryText)

            Text("Search hospitals and clinics")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    // MARK: - Map
    private var map: some View {
        Map(
            position: $viewModel.cameraPosition,
            interactionModes: [.pan, .zoom, .rotate, .pitch]
        ) {
            if let location = viewModel.location {
                Annotation(
                    "Your location",
                    coordinate: location.coordinate,
                    anchor: .center
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.20))
                            .frame(width: 44, height: 44)

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                            }
                            .shadow(
                                color: .black.opacity(0.2),
                                radius: 3
                            )
                    }
                }
            }
            
            ForEach(appointmentViewModel.upcomingAppointments) { appointment in
                if let doctor = MockDoctorData.doctors.first(
                    where: { $0.id == appointment.doctorID }
                ) {
                    Annotation(
                        appointment.doctorName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: doctor.latitude,
                            longitude: doctor.longitude
                        ),
                        anchor: .bottom
                    ) {
                        Button {
                            selectedAppointment = appointment
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 25))
                                .foregroundStyle(.red)
                                .padding(3)
                                .background(.white, in: Circle())
                                .clipShape(Circle())
                                .shadow(
                                    color: .black.opacity(0.18),
                                    radius: 3,
                                    y: 2
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Appointment Details
    private var appointmentCard: some View {
        Group {
            if let appointment = selectedAppointment {
                ZStack(alignment: .topTrailing) {
                    NavigationLink {
                        AppointmentDetailView(
                            appointment: appointment,
                            viewModel: appointmentViewModel
                        )
                    } label: {
                        AppointmentCard(
                            appointment: appointment,
                            viewModel: appointmentViewModel
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        selectedAppointment = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(.black.opacity(0.65), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            map

            VStack(spacing: 16) {
                searchBar

                HStack {
                    Label(
                        "Hospitals & Clinics",
                        systemImage: "cross.case"
                    )
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(16)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let error = viewModel.locationError {
                    Text(error)
                        .font(AppTypography.body)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .allowsHitTesting(false)

            VStack {
                Spacer()
                appointmentCard
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle("Nearby")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            appointmentViewModel.configure(context: modelContext)
            appointmentViewModel.loadAppointments()

            if viewModel.location == nil {
                viewModel.requestLocation()
            }
        }
        .onChange(of: appointmentViewModel.upcomingAppointments.map(\.id)) { _, upcomingIDs in
            guard let selectedAppointment else {
                return
            }

            guard upcomingIDs.contains(selectedAppointment.id) else {
                self.selectedAppointment = nil
                viewModel.showUserLocation()
                return
            }
        }
    }
}

#Preview {
    NavigationStack {
        NearbyView()
    }
    .environment(AppointmentViewModel())
    .modelContainer(for: Appointment.self)
}
