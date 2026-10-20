//
//  CompletedPatientsCountDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 20.10.26.
//

import Foundation

struct CompletedPatientsCountDTO: Decodable {
    let doctorId: Int
    let patientsCount: Int
}
