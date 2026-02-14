//
//  DisclaimerView.swift
//  LotteryAnalyzer
//
//  CRITICAL: This disclaimer is REQUIRED for App Store approval
//  Shows on first launch and must be acknowledged
//

import SwiftUI

struct DisclaimerView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .padding(.top, 40)
                    
                    Text("Important Notice")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Please read carefully")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.6))
                }
                .padding(.bottom, 30)
                
                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        DisclaimerSection(
                            icon: "book.fill",
                            color: .blue,
                            title: "Educational Purpose Only",
                            text: "Lucky Stats is designed for entertainment and educational purposes. It provides statistical analysis of historical lottery data to help users understand number patterns and trends."
                        )
                        
                        DisclaimerSection(
                            icon: "xmark.circle.fill",
                            color: .red,
                            title: "No Predictions or Guarantees",
                            text: "This app CANNOT and DOES NOT predict future lottery outcomes. Past results do not indicate future drawings. All lottery drawings are random and independent events."
                        )
                        
                        DisclaimerSection(
                            icon: "chart.bar.fill",
                            color: .green,
                            title: "Statistical Analysis Only",
                            text: "The app analyzes historical data and shows statistical patterns. These patterns do not improve your odds of winning. Each number has an equal probability in every drawing."
                        )
                        
                        DisclaimerSection(
                            icon: "hand.raised.fill",
                            color: .orange,
                            title: "Play Responsibly",
                            text: "If you choose to play the lottery, please do so responsibly and within your means. Only spend what you can afford to lose. Gambling should be for entertainment only."
                        )
                        
                        DisclaimerSection(
                            icon: "18.circle.fill",
                            color: .purple,
                            title: "Age Requirement",
                            text: "You must be 18 years or older (or the legal gambling age in your jurisdiction) to purchase lottery tickets. This app does not sell tickets or facilitate gambling."
                        )
                        
                        DisclaimerSection(
                            icon: "exclamationmark.shield.fill",
                            color: .yellow,
                            title: "No Liability",
                            text: "We are not responsible for any financial losses incurred from lottery participation. Use this app at your own risk. This app provides information only."
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Accept button
                VStack(spacing: 15) {
                    Button(action: acceptDisclaimer) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("I Understand and Agree")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                    }
                    
                    Text("By continuing, you acknowledge that this app is for educational purposes and does not guarantee lottery winnings.")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color(white: 0.05))
            }
        }
    }
    
    private func acceptDisclaimer() {
        withAnimation {
            hasAcceptedDisclaimer = true
            isPresented = false
        }
    }
}

// MARK: - Disclaimer Section Component

struct DisclaimerSection: View {
    let icon: String
    let color: Color
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }
}

// MARK: - Preview

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimerView(isPresented: .constant(true))
    }
}
