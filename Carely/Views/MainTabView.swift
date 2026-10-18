//
//  MainTabView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)

            NavigationStack {
                AppointmentsView()
            }
            .tabItem {
                Label("Appointments", systemImage: "calendar")
            }
            .tag(2)

            NavigationStack {
                NearbyView()
            }
            .tabItem {
                Label("Nearby", systemImage: "map")
            }
            .tag(3)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(4)
        }
        .tint(AppColors.primary)
        .environment(\.selectedTab, $selectedTab)
    }
}

private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

#Preview {
    MainTabView()
        .environment(AppointmentViewModel())
}
