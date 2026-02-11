//
//  DashboardView.swift
//  LotteryAnalyzer
//
//  Complete Dashboard with:
//  1. Lucky Number Generator
//  2. Clickable Shortcuts
//  3. Sound effects
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var generatedNumbers: [Int] = []
    @State private var generatedBonus: Int = 0
    @State private var isAnimating = false
    @State private var showNumbers = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    luckyNumberGeneratorSection
                    shortcutsSection
                    recentDrawsSection
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Lucky Number Generator Section
    
    private var luckyNumberGeneratorSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                    .symbolEffect(.pulse, options: .repeating, value: isAnimating)
                
                Text("Your Lucky Numbers")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.9))
                
                Text("Based on smart analysis")
                    .font(.caption)
                    .foregroundColor(Color(white: 0.6))
            }
            .padding(.top, 10)
            
            if showNumbers && !generatedNumbers.isEmpty {
                VStack(spacing: 15) {
                    HStack(spacing: 6) {
                        ForEach(generatedNumbers, id: \.self) { number in
                            LotteryBall(number: number, isBonus: false)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Text("+")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(white: 0.6))
                            .frame(width: 20)
                        
                        LotteryBall(number: generatedBonus, isBonus: true)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, 15)
            } else {
                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { _ in
                        PlaceholderBall()
                    }
                    
                    Text("+")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(white: 0.6))
                        .frame(width: 20)
                    
                    PlaceholderBall(isBonus: true)
                }
                .padding(.vertical, 15)
            }
            
            Button(action: generateLuckyNumbers) {
                HStack(spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .font(.title3)
                    
                    Text(showNumbers ? "Generate New Numbers" : "Generate Your Lucky Numbers")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.draws.isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.1))
                .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Shortcuts Section
    
    private var shortcutsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Shortcuts")
                    .font(.headline)
                    .foregroundColor(Color(white: 0.9))
                Spacer()
                Image(systemName: "hand.tap")
                    .font(.caption)
                    .foregroundColor(Color(white: 0.5))
            }
            .padding()
            .background(Color(white: 0.15))
            
            // Shortcuts Grid
            VStack(spacing: 0) {
                let stats = calculateInterestingStats()
                
                ForEach(0..<2) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<2) { col in
                            let index = row * 2 + col
                            shortcutCard(for: index, stats: stats)
                        }
                    }
                }
            }
        }
        .background(Color(white: 0.1))
        .cornerRadius(15)
        .shadow(color: Color.white.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func shortcutCard(for index: Int, stats: (mostFrequentNumber: String, mostFrequentCount: Int, mostFrequentBonus: String, bonusCount: Int, hotStreakNumber: String, hotStreakCount: Int, luckyPair: String)) -> some View {
        let cards: [(icon: String, title: String, value: String, subtitle: String, color: Color, analysis: LotteryViewModel.AnalysisType)] = [
            ("number.circle.fill", "Most Frequent Number", stats.mostFrequentNumber, "(\(stats.mostFrequentCount)x)", .blue, .frequency),
            ("star.circle.fill", "Top Bonus Number", stats.mostFrequentBonus, "(\(stats.bonusCount)x)", .orange, .bonus),
            ("flame.fill", "Hot Streak", stats.hotStreakNumber, "(\(stats.hotStreakCount)x)", .red, .streak),
            ("link.circle.fill", "Lucky Pair", stats.luckyPair, "", .green, .pairs)
        ]
        
        if index < cards.count {
            let card = cards[index]
            
            Button(action: {
                viewModel.currentAnalysis = card.analysis
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToAnalysisTab"), object: nil)
            }) {
                VStack(spacing: 8) {
                    Image(systemName: card.icon)
                        .font(.system(size: 28))
                        .foregroundColor(card.color)
                    
                    HStack(spacing: 4) {
                        Text(card.value)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(white: 0.9))
                        
                        if !card.subtitle.isEmpty {
                            Text(card.subtitle)
                                .font(.caption)
                                .foregroundColor(Color(white: 0.6))
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    
                    Text(card.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(white: 0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color(white: 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - Recent Draws Section
    
    private var recentDrawsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Recent Draws")
                    .font(.headline)
                    .foregroundColor(Color(white: 0.9))
                Spacer()
            }
            .padding()
            .background(Color(white: 0.15))
            
            // Draws List
            VStack(spacing: 1) {
                ForEach(viewModel.draws.prefix(5)) { draw in
                    DrawRowView(draw: draw)
                }
            }
        }
        .background(Color(white: 0.1))
        .cornerRadius(15)
        .shadow(color: Color.white.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Number Generation Logic
    
    private func generateLuckyNumbers() {
        // ✅ PLAY SOUND
        SoundManager.shared.playSound("lucky_generate")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAnimating = true
            showNumbers = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let frequencyData = viewModel.analyzeFrequency()
            let pairData = viewModel.analyzePairs()
            let hotStreaks = viewModel.analyzeHotStreaks()
            let bonusFrequency = viewModel.analyzeBonusFrequency()
            
            var selectedNumbers: Set<Int> = []
            var attempts = 0
            let maxAttempts = 100
            
            let topFrequent = Array(frequencyData.prefix(15))
            let numFromFrequent = Int.random(in: 1...2)
            for _ in 0..<numFromFrequent {
                if let num = weightedRandomFromTop(topFrequent.map { $0.number }, topCount: 10) {
                    selectedNumbers.insert(num)
                }
            }
            
            if !hotStreaks.isEmpty {
                let hotTop = Array(hotStreaks.prefix(8))
                if let hotNum = hotTop.randomElement()?.number {
                    selectedNumbers.insert(hotNum)
                }
            }
            
            if !pairData.isEmpty {
                let topPairs = Array(pairData.prefix(10))
                if let randomPair = topPairs.randomElement() {
                    let pairNums = [randomPair.number1, randomPair.number2]
                    if let num = pairNums.randomElement() {
                        selectedNumbers.insert(num)
                    }
                }
            }
            
            let midFrequent = Array(frequencyData.dropFirst(10).prefix(25))
            let leastFrequent = Array(frequencyData.suffix(20))
            
            while selectedNumbers.count < 5 && attempts < maxAttempts {
                let strategy = Int.random(in: 0...2)
                
                switch strategy {
                case 0:
                    if let num = midFrequent.randomElement()?.number {
                        selectedNumbers.insert(num)
                    }
                case 1:
                    if let num = leastFrequent.randomElement()?.number {
                        selectedNumbers.insert(num)
                    }
                default:
                    let randomNum = Int.random(in: 1...70)
                    selectedNumbers.insert(randomNum)
                }
                
                attempts += 1
            }
            
            while selectedNumbers.count < 5 {
                selectedNumbers.insert(Int.random(in: 1...70))
            }
            
            let sortedNumbers = Array(selectedNumbers.prefix(5)).sorted()
            
            var bonusNum = 0
            let reasonableBonuses = bonusFrequency.filter { $0.count >= 3 }
            
            if !reasonableBonuses.isEmpty {
                let weights = reasonableBonuses.map { Double($0.count) }
                let totalWeight = weights.reduce(0, +)
                let random = Double.random(in: 0..<totalWeight)
                
                var currentWeight = 0.0
                for (index, weight) in weights.enumerated() {
                    currentWeight += weight
                    if random < currentWeight {
                        bonusNum = reasonableBonuses[index].number
                        break
                    }
                }
            }
            
            if bonusNum == 0 {
                if bonusFrequency.count > 10 {
                    let topHalf = Array(bonusFrequency.prefix(bonusFrequency.count / 2))
                    bonusNum = topHalf.randomElement()?.number ?? Int.random(in: 1...25)
                } else {
                    bonusNum = Int.random(in: 1...25)
                }
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                generatedNumbers = sortedNumbers
                generatedBonus = bonusNum
                showNumbers = true
                isAnimating = false
            }
        }
    }
    
    private func weightedRandomFromTop(_ numbers: [Int], topCount: Int) -> Int? {
        guard !numbers.isEmpty else { return nil }
        
        let topNumbers = Array(numbers.prefix(topCount))
        
        if Double.random(in: 0...1) < 0.7 {
            return topNumbers.randomElement()
        } else {
            return numbers.randomElement()
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateInterestingStats() -> (mostFrequentNumber: String, mostFrequentCount: Int, mostFrequentBonus: String, bonusCount: Int, hotStreakNumber: String, hotStreakCount: Int, luckyPair: String) {
        let selected = viewModel.draws
        
        let frequencyAnalyzer = FrequencyAnalyzer()
        let mainFreqs = frequencyAnalyzer.analyzeMainNumbers(selected)
        let mostFrequent = mainFreqs.first?.number ?? 0
        let mostFrequentCount = mainFreqs.first?.count ?? 0
        
        let bonusFreqs = frequencyAnalyzer.analyzeBonusNumbers(selected)
        let mostBonus = bonusFreqs.first?.number ?? 0
        let bonusCount = bonusFreqs.first?.count ?? 0
        
        let hotStreaks = viewModel.analyzeHotStreaks()
        let hotNumber = hotStreaks.first?.number ?? 0
        let hotCount = hotStreaks.first?.streak ?? 0
        
        let pairAnalyzer = PairAnalyzer()
        let pairs = pairAnalyzer.analyzeNumberPairs(selected)
        let topPair = pairs.first
        let luckyPairStr = topPair != nil ? "\(topPair!.number1)-\(topPair!.number2)" : "N/A"
        
        return (
            mostFrequentNumber: "\(mostFrequent)",
            mostFrequentCount: mostFrequentCount,
            mostFrequentBonus: "\(mostBonus)",
            bonusCount: bonusCount,
            hotStreakNumber: "\(hotNumber)",
            hotStreakCount: hotCount,
            luckyPair: luckyPairStr
        )
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Lottery Ball View

struct LotteryBall: View {
    let number: Int
    let isBonus: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            (isBonus ? Color.orange : Color.blue).opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 30
                    )
                )
                .frame(width: 50, height: 50)
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isBonus ? [
                            Color.orange.opacity(0.8),
                            Color.yellow.opacity(0.6)
                        ] : [
                            Color.blue.opacity(0.8),
                            Color.cyan.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: (isBonus ? Color.orange : Color.blue).opacity(0.4), radius: 6, x: 0, y: 3)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 44, height: 44)
            
            Text("\(number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Placeholder Ball View

struct PlaceholderBall: View {
    let isBonus: Bool
    
    init(isBonus: Bool = false) {
        self.isBonus = isBonus
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                )
            
            Text("?")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Draw Row View

struct DrawRowView: View {
    let draw: LotteryDraw
    
    var body: some View {
        HStack(spacing: 10) {
            Text(draw.dateString)
                .font(.caption)
                .foregroundColor(Color(white: 0.7))
                .frame(width: 70, alignment: .leading)
            
            HStack(spacing: 4) {
                ForEach(draw.mainNumbers, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(white: 0.9))
                        .frame(width: 26, height: 26)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(13)
                }
            }
            
            if let bonus = draw.bonusNumber {
                Text("+")
                    .font(.caption)
                    .foregroundColor(Color(white: 0.6))
                
                Text("\(bonus)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.orange)
                    .frame(width: 26, height: 26)
                    .background(Color.orange.opacity(0.3))
                    .cornerRadius(13)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(white: 0.08))
    }
}
