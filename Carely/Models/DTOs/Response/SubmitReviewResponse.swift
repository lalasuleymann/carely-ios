//
//  SubmitReviewResponse.swift
//  Carely
//
//  Created by Lala Suleymanova on 19.10.26.
//

struct SubmitReviewResponse: Decodable {
    let message: String
    let appointmentId: Int
    let doctorId: Int
    let rating: Double
    let averageRating: Double
    let reviewCount: Int
}
