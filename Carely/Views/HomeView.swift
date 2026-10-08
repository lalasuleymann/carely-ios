//
//  HomeView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                SearchBar(
                    text: $viewModel.searchText,
                    placeholder: "Search doctors, specialties..."
                )

                specialtiesSection

                doctorsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AppColors.background)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good morning 👋")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)

            Text("Find your doctor")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
        }
    }

    private var specialtiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specialties")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    SpecialtyCard(
                        title: "Cardiology",
                        icon: "heart.text.square"
                    )

                    SpecialtyCard(
                        title: "Neurology",
                        icon: "brain.head.profile"
                    )

                    SpecialtyCard(
                        title: "Dermatology",
                        icon: "person.crop.circle"
                    )

                    SpecialtyCard(
                        title: "Dentistry",
                        icon: "mouth"
                    )
                }
            }
        }
    }

    private var doctorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Doctors")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Text("See all")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primary)
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredDoctors) { doctor in
                    DoctorCard(doctor: doctor)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
