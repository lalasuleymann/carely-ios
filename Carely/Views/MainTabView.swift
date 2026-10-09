//
//  MainTabView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        NavigationStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                Text("Appointments")
                    .tabItem {
                        Label("Appointments", systemImage: "calendar")
                    }

                Text("Favorites")
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }

                Text("Profile")
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .tint(AppColors.primary)
            .navigationDestination(for: Doctor.self) { doctor in
                DoctorDetailView(doctor: doctor)
            }
        }
    }
}

#Preview {
    MainTabView()
}
