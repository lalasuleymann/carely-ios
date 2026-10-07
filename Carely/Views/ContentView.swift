//
//  ContentView.swift
//  Carely
//
//  Created by Lala Suleymanova on 05.10.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Good morning")
                .font(AppTypography.body)
            
            Text("Lala")
                .font(AppTypography.largeTitle)
            
            Text("Upcoming Appointment")
                .font(AppTypography.headline)
        }
    }
}

#Preview {
    ContentView()
}
