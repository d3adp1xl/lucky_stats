//
//  ContentView.swift - UPDATED
//  LotteryAnalyzer
//
//  Add this to show disclaimer on first launch
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LotteryViewModel()
    @State private var selectedTab = 0
    
    // ✅ ADD THESE TWO LINES
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @State private var showDisclaimer = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            AnalysisView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            HeatmapView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Heatmap", systemImage: "map.fill")
                }
            
            DataView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Data", systemImage: "square.and.arrow.down.fill")
                }
                .tag(2)
        }
        .preferredColorScheme(.dark)
    
        .onAppear {
            if !hasAcceptedDisclaimer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showDisclaimer = true
                }
            }
            
            // Listen for tab switches from shortcuts
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("SwitchToAnalysisTab"),
                object: nil,
                queue: .main
            ) { _ in
                selectedTab = 1
            }
        }
        // ✅ ADD THIS FULL SCREEN COVER
        .fullScreenCover(isPresented: $showDisclaimer) {
            DisclaimerView(isPresented: $showDisclaimer)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
