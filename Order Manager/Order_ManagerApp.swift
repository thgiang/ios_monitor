//
//  Order_ManagerApp.swift
//  ZangTee Monitor
//
//  Created by Vũ Thị Hà Giang on 24/2/26.
//

import SwiftUI

@main
struct Order_ManagerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.refreshData()
                    LiveActivityManager.shared.restartActivity(stores: viewModel.stores)
                }
            }
        }
    }
}
