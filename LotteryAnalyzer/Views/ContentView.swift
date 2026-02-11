//
//  ContentView.swift
//  LotteryAnalyzer
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = LotteryViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
                .environmentObject(viewModel)
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(1)
                .environmentObject(viewModel)
            
            DataView()
                .tabItem {
                    Label("Data", systemImage: "list.bullet")
                }
                .tag(2)
                .environmentObject(viewModel)
        }
        .accentColor(.blue)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToAnalysisTab"))) { _ in
            selectedTab = 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
