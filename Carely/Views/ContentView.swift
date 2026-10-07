//
//  ContentView.swift
//  Carely
//
//  Created by Lala Suleymanova on 05.10.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Carely")
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.primaryText)
            
            PrimaryButton(title: "Book Appointment") {
                print("Button tapped")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    ContentView()
}
