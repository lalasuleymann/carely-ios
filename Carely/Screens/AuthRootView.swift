//
//  AuthRootView.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import SwiftUI

struct AuthRootView: View {
    @State private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .task {
            authViewModel.checkAuthentication()
        }
        .environment(authViewModel)
    }
}
