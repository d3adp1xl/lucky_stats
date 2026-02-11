//
//  LotteryAnalyzerApp.swift
//  LotteryAnalyzer
//

import SwiftUI

@main
struct LotteryAnalyzerApp: App {
    
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeOut(duration: 1.0)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
        }
    }
}
