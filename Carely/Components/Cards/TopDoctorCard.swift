//
//  TopDoctorCard.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct TopDoctorCard: View {
    let doctor: Doctor

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            doctorImage

            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(doctor.specialty)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primary)
                    .lineLimit(1)
            }

            HStack {
                RatingView(
                    rating: doctor.rating,
                    reviewCount: doctor.reviewCount
                )

                Spacer()

                Text("$\(Int(doctor.consultationFee))")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
            }
        }
        .padding(12)
        .frame(width: 180)
        .background(AppColors.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .shadow(
            color: .black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    private var doctorImage: some View {
        Group {
            if let url = URL(string: doctor.imageURL),
               !doctor.imageURL.isEmpty,
               let scheme = url.scheme,
               scheme == "https" || scheme == "http" {

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 135)
                            .clipped()

                    case .empty:
                        doctorImagePlaceholder
                            .overlay {
                                ProgressView()
                                    .tint(AppColors.primary)
                            }

                    case .failure:
                        doctorImagePlaceholder

                    @unknown default:
                        doctorImagePlaceholder
                    }
                }
            } else {
                doctorImagePlaceholder
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 135)
        .clipped()
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    private var doctorImagePlaceholder : some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(AppColors.primary.opacity(0.7))
            .frame(maxWidth: .infinity)
            .frame(height: 135)
            .background(AppColors.background)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
    }
}

#Preview {
    TopDoctorCard(doctor: MockDoctorData.doctors[0])
}
