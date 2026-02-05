//
//  DashboardView.swift
//  LotteryAnalyzer
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    statsSection
                    recentDrawsSection
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color.black : Color(UIColor.systemGroupedBackground))
            .navigationTitle("Lottery Analyzer")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Next Possible Numbers")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .padding()
    }
    
    private var statsSection: some View {
        VStack(spacing: 15) {
            Text("Quick Statistics")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let stats = calculateInterestingStats()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                DashboardStatCard(
                    icon: "number.circle.fill",
                    title: "Most Frequent Number",
                    value: stats.mostFrequentNumber,
                    color: .blue
                )
                
                DashboardStatCard(
                    icon: "star.circle.fill",
                    title: "Frequent Bonus Number",
                    value: stats.mostFrequentBonus,
                    color: .orange
                )
                
                DashboardStatCard(
                    icon: "flame.fill",
                    title: stats.hotStreakTitle,
                    value: stats.hotStreakNumber,
                    color: .red
                )
                
                DashboardStatCard(
                    icon: "link.circle.fill",
                    title: "Lucky Pair",
                    value: stats.luckyPair,
                    color: .green
                )
            }
        }
    }
    private var recentDrawsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Draws")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            ForEach(viewModel.draws.prefix(5)) { draw in
                DrawRowView(draw: draw)
            }
        }
    }
    
    private func calculateInterestingStats() -> (mostFrequentNumber: String, mostFrequentBonus: String, hotStreakNumber: String, hotStreakTitle: String, luckyPair: String) {
        let selected = viewModel.draws
        
        let frequencyAnalyzer = FrequencyAnalyzer()
        let mainFreqs = frequencyAnalyzer.analyzeMainNumbers(selected)
        let mostFrequent = mainFreqs.first?.number ?? 0
        let mostFrequentCount = mainFreqs.first?.count ?? 0
        
        let bonusFreqs = frequencyAnalyzer.analyzeBonusNumbers(selected)
        let mostBonus = bonusFreqs.first?.number ?? 0
        let mostBonusCount = bonusFreqs.first?.count ?? 0
        
        let recentDraws = Array(selected.prefix(10))
        let recentFreqs = frequencyAnalyzer.analyzeMainNumbers(recentDraws)
        let hotNumber = recentFreqs.first?.number ?? 0
        let hotCount = recentFreqs.first?.count ?? 0
        
        let pairAnalyzer = PairAnalyzer()
        let pairs = pairAnalyzer.analyzeNumberPairs(selected)
        let topPair = pairs.first
        let luckyPairStr = topPair != nil ? "\(topPair!.number1)-\(topPair!.number2) (\(topPair!.count) times)" : "N/A"
        
        return (
            mostFrequentNumber: "\(mostFrequent) (\(mostFrequentCount) times)",
            mostFrequentBonus: "\(mostBonus) (\(mostBonusCount) times)",
            hotStreakNumber: "\(hotNumber)",
            hotStreakTitle: "Hot Streak (\(hotCount) times)",
            luckyPair: luckyPairStr
        )
    }
    
    struct DashboardStatCard: View {
        let icon: String
        let title: String
        let value: String
        let color: Color
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    struct DrawRowView: View {
        let draw: LotteryDraw
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            HStack {
                Text(draw.dateString)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(width: 80, alignment: .leading)
                
                HStack(spacing: 4) {
                    ForEach(draw.mainNumbers, id: \.self) { number in
                        Text("\(number)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 28, height: 28)
                            .background(colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2))
                            .cornerRadius(14)
                    }
                }
                
                if let bonus = draw.bonusNumber {
                    Text("+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(bonus)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.orange.opacity(0.9))
                        .frame(width: 28, height: 28)
                        .background(colorScheme == .dark ? Color.orange.opacity(0.3) : Color.orange.opacity(0.2))
                        .cornerRadius(14)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2, x: 0, y: 1)
        }
    }
    
    struct DashboardView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                DashboardView()
                    .environmentObject(LotteryViewModel())
                    .preferredColorScheme(.light)
                
                DashboardView()
                    .environmentObject(LotteryViewModel())
                    .preferredColorScheme(.dark)
            }
        }
    }
}
