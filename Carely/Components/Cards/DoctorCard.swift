//
//  DoctorCard.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import SwiftUI

struct DoctorCard: View {
    let doctor: Doctor

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
                           .frame(width: 72, height: 72)
                           .clipShape(Circle())

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
       .frame(width: 72, height: 72)
       .clipShape(RoundedRectangle(cornerRadius: 14))
   }

    private var doctorImagePlaceholder: some View {
       Image(systemName: "person.crop.circle.fill")
           .resizable()
           .scaledToFit()
           .foregroundStyle(AppColors.primary.opacity(0.7))
           .padding(8)
           .frame(width: 72, height: 72)
           .background(AppColors.background)
           .clipShape(RoundedRectangle(cornerRadius: 14))
   }

    
    var body: some View {
        HStack(spacing: 12) {
            doctorImage

            VStack(alignment: .leading, spacing: 6) {
                Text(doctor.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(doctor.specialty)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                RatingView(rating: doctor.rating,reviewCount: doctor.reviewCount)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))

                    Text(doctor.location)
                        .lineLimit(1)
                        .font(AppTypography.caption)
                }
                .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()
        }
        .padding(12)
        .background(AppColors.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    AppColors.divider,
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    DoctorCard(doctor: MockDoctorData.doctors[0])
}
