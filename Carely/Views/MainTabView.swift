//
//  MainTabView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }.tabItem {
                Label("Home", systemImage: "house.fill")
            }
            NavigationStack {
                SearchView()
                
            } .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            NavigationStack {
                AppointmentsView()
            }
            .tabItem {
                Label("Appointments", systemImage: "calendar")
            }
            NavigationStack {
                Text("Favorites")
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            NavigationStack {
                Text("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        .tint(AppColors.primary)
        
    }
}

#Preview {
    MainTabView()
        .environment(AppointmentViewModel())
}
