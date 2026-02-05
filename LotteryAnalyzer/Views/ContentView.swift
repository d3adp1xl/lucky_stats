//
//  ContentView.swift
//  LotteryAnalyzer
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = LotteryViewModel()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .environmentObject(viewModel)
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .environmentObject(viewModel)
            
            DataView()
                .tabItem {
                    Label("Data", systemImage: "list.bullet")
                }
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    ContentView()
} 
