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
            
            .disabled(viewModel.selectedDraws.isEmpty)
            
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
            .disabled(viewModel.selectedDraws.isEmpty)

            // Hint text AFTER the button is closed
            if viewModel.selectedDraws.isEmpty {
                Text("⚠️ No data selected")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
            }
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
    //
    // Strategy blend (in priority order):
    //   Slot 1-2 → Recency-weighted hot:  ranks 2–7 by exponential-decay score
    //              (skip rank 1 — the single hottest number rarely sustains)
    //   Slot 3-4 → Due number analysis:   numbers whose current gap > their historical avg gap
    //   Slot 5   → Pair anchor:           one number from a top-frequency pair not yet selected
    //   Fill     → Mid-frequency pool if any slot is still empty after 50 attempts
    //   Balance  → Attempt to spread picks across low/mid/high decades (1-23, 24-46, 47-70)
    //   Bonus    → Recency-weighted bonus frequency (same decay model)

    private func generateLuckyNumbers() {
        SoundManager.shared.playSound("lucky_generate")

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAnimating = true
            showNumbers = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let draws          = viewModel.getSelectedDraws()
            let frequencyData  = viewModel.analyzeFrequency()
            let pairData       = viewModel.analyzePairs()
            let bonusFrequency = viewModel.analyzeBonusFrequency()

            guard !draws.isEmpty, !frequencyData.isEmpty else {
                withAnimation { isAnimating = false }
                return
            }

            // ── 1. Recency-weighted scores ────────────────────────────────────
            // Score each number using exponential decay: more recent = higher score.
            // Half-life of 60 draws — an appearance 60 draws ago is worth half
            // as much as one in the most recent draw.
            let halfLifeDraws = 60.0
            var recencyScores: [Int: Double] = [:]

            for (drawIndex, draw) in draws.enumerated() {
                let recency = Double(draws.count - drawIndex)          // 1 = oldest, draws.count = newest
                let decayWeight = pow(2.0, recency / halfLifeDraws)    // exponential: newest draws score highest
                for number in draw.mainNumbers {
                    recencyScores[number, default: 0] += decayWeight
                }
            }

            // Sort by recency score descending
            let recencySorted = recencyScores.sorted { $0.value > $1.value }.map { $0.key }

            // ── 2. Gap / due-number analysis ──────────────────────────────────
            // For each number compute:
            //   avgGap      = total draws / appearance count  (expected draws between hits)
            //   currentGap  = draws since last appearance
            //   dueRatio    = currentGap / avgGap  (>1.0 means overdue vs its own baseline)
            var dueScores: [Int: Double] = [:]

            for entry in frequencyData {
                let num = entry.number
                guard entry.count > 1 else { continue }   // need at least 2 appearances for a meaningful gap

                let avgGap = Double(draws.count) / Double(entry.count)

                // Find how many draws ago this number last appeared
                var currentGap = 0
                for draw in draws {                        // draws[0] = most recent
                    if draw.mainNumbers.contains(num) { break }
                    currentGap += 1
                }

                // Only score numbers that are actually overdue (ratio > 1)
                let dueRatio = Double(currentGap) / avgGap
                if dueRatio > 1.0 {
                    dueScores[num] = dueRatio
                }
            }

            // Sort by due ratio descending — most overdue first
            let dueSorted = dueScores.sorted { $0.value > $1.value }.map { $0.key }

            // ── 3. Build the pick list ────────────────────────────────────────
            var selected: [Int] = []

            // Helper: add a number only if not already picked
            func tryAdd(_ num: Int) -> Bool {
                guard !selected.contains(num) else { return false }
                selected.append(num)
                return true
            }

            // Slot 1: rank-2 recency hot (skip rank-0 = single hottest)
            let hotPool = Array(recencySorted.dropFirst(1).prefix(8))   // ranks 1-8 (0-indexed)
            if let pick = hotPool.randomElement() { _ = tryAdd(pick) }

            // Slot 2: another from ranks 2-12 recency, weighted toward top
            let widerHotPool = Array(recencySorted.dropFirst(1).prefix(12))
            var slot2Attempts = 0
            while selected.count < 2 && slot2Attempts < 30 {
                if let pick = weightedRandom(from: widerHotPool, topBias: 6) { _ = tryAdd(pick) }
                slot2Attempts += 1
            }

            // Slot 3: most overdue number (top due ratio)
            if let dueTop = dueSorted.first(where: { !selected.contains($0) }) {
                _ = tryAdd(dueTop)
            }

            // Slot 4: second-most overdue, from a different decade than slot 3 if possible
            let slot3Decade = selected.last.map { decadeOf($0) }
            let dueSecond = dueSorted.first(where: { n in
                !selected.contains(n) && decadeOf(n) != slot3Decade
            }) ?? dueSorted.first(where: { !selected.contains($0) })
            if let pick = dueSecond { _ = tryAdd(pick) }

            // Slot 5: pair anchor — one number from a top pair not already represented
            let topPairs = Array(pairData.prefix(15))
            var pairAdded = false
            for pair in topPairs.shuffled() {
                let pairNums = [pair.number1, pair.number2]
                // Prefer the pair member NOT already selected (adds a new number)
                let candidates = pairNums.filter { !selected.contains($0) }
                if let pick = candidates.randomElement() {
                    _ = tryAdd(pick)
                    pairAdded = true
                    break
                }
            }
            // Fallback if all top-pair numbers already selected
            if !pairAdded, let pick = topPairs.randomElement() {
                _ = tryAdd(pick.number1)
            }

            // ── 4. Fill remaining slots with mid-frequency pool ───────────────
            // Mid = ranks 8-35 by raw frequency — avoids both "always hot" and genuinely cold
            let midPool = Array(frequencyData.dropFirst(8).prefix(28)).map { $0.number }
            var fillAttempts = 0
            while selected.count < 5 && fillAttempts < 50 {
                if let pick = midPool.randomElement(), !selected.contains(pick) {
                    selected.append(pick)
                }
                fillAttempts += 1
            }
            // Hard fallback (extremely rare)
            while selected.count < 5 {
                let r = Int.random(in: 1...70)
                if !selected.contains(r) { selected.append(r) }
            }

            // ── 5. Decade balance nudge ───────────────────────────────────────
            // If all 5 picks land in ≤ 2 decades, swap one for a mid-pool number
            // from an unrepresented decade. One attempt only — don't over-engineer.
            let decades = Set(selected.map { decadeOf($0) })
            if decades.count <= 2 {
                let missingDecade = [1,2,3,4,5,6,7].first { !decades.contains($0) }
                if let md = missingDecade {
                    let decadePool = midPool.filter { decadeOf($0) == md }
                    if let replacement = decadePool.randomElement(),
                       let swapIndex = selected.indices.randomElement() {
                        selected[swapIndex] = replacement
                        // De-duplicate after swap
                        if Set(selected).count < 5 {
                            selected = Array(Set(selected))
                            while selected.count < 5 {
                                let r = Int.random(in: 1...70)
                                if !selected.contains(r) { selected.append(r) }
                            }
                        }
                    }
                }
            }

            let sortedNumbers = Array(selected.prefix(5)).sorted()

            // ── 6. Bonus ball: recency-weighted ───────────────────────────────
            var bonusRecencyScores: [Int: Double] = [:]
            for (drawIndex, draw) in draws.enumerated() {
                guard let bonus = draw.bonusNumber else { continue }
                let recency = Double(draws.count - drawIndex)
                let decayWeight = pow(2.0, recency / halfLifeDraws)
                bonusRecencyScores[bonus, default: 0] += decayWeight
            }

            // Weighted random from bonus scores — not just top pick
            let bonusSorted = bonusRecencyScores.sorted { $0.value > $1.value }
            let bonusNum: Int

            if bonusSorted.isEmpty {
                bonusNum = Int.random(in: 1...25)
            } else {
                // Use top 10 bonus candidates, weighted by recency score
                let bonusCandidates = Array(bonusSorted.prefix(10))
                let totalWeight = bonusCandidates.reduce(0.0) { $0 + $1.value }
                let roll = Double.random(in: 0..<totalWeight)
                var cumulative = 0.0
                var picked = bonusCandidates.first!.key
                for candidate in bonusCandidates {
                    cumulative += candidate.value
                    if roll < cumulative { picked = candidate.key; break }
                }
                bonusNum = picked
            }

            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                generatedNumbers = sortedNumbers
                generatedBonus = bonusNum
                showNumbers = true
                isAnimating = false
            }
        }
    }

    // MARK: - Generation Helpers

    /// Weighted random that biases toward the first `topBias` elements but can still
    /// return any element — mimics your original 70/30 split but generalises cleanly.
    private func weightedRandom(from numbers: [Int], topBias: Int) -> Int? {
        guard !numbers.isEmpty else { return nil }
        let top = Array(numbers.prefix(topBias))
        return Double.random(in: 0...1) < 0.70 ? top.randomElement() : numbers.randomElement()
    }

    /// Maps a number (1-70) to one of 7 decades for balance checking.
    private func decadeOf(_ n: Int) -> Int {
        return ((n - 1) / 10) + 1   // 1-10 → 1, 11-20 → 2, … 61-70 → 7
    }

    // Keep original helper for any other call sites
    private func weightedRandomFromTop(_ numbers: [Int], topCount: Int) -> Int? {
        weightedRandom(from: numbers, topBias: topCount)
    }
    
    // MARK: - Helper Functions
    
    private func calculateInterestingStats() -> (mostFrequentNumber: String, mostFrequentCount: Int, mostFrequentBonus: String, bonusCount: Int, hotStreakNumber: String, hotStreakCount: Int, luckyPair: String) {
        
        // Use viewModel methods that respect selection/filters
        let mainFreqs = viewModel.analyzeFrequency()
        let bonusFreqs = viewModel.analyzeBonusFrequency()
        let hotStreaks = viewModel.analyzeHotStreaks()
        let pairs = viewModel.analyzePairs()
        
        // Check if data is empty
        guard !mainFreqs.isEmpty else {
            return (
                mostFrequentNumber: "0",
                mostFrequentCount: 0,
                mostFrequentBonus: "0",
                bonusCount: 0,
                hotStreakNumber: "0",
                hotStreakCount: 0,
                luckyPair: "N/A"
            )
        }
        
        let mostFrequent = mainFreqs.first?.number ?? 0
        let mostFrequentCount = mainFreqs.first?.count ?? 0
        
        let mostBonus = bonusFreqs.first?.number ?? 0
        let bonusCount = bonusFreqs.first?.count ?? 0
        
        let hotNumber = hotStreaks.first?.number ?? 0
        let hotCount = hotStreaks.first?.streak ?? 0
        
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
                .font(.subheadline)
                .foregroundColor(Color(white: 0.7))
                .frame(width: 80, height: 32, alignment: .leading)
            
            HStack(spacing: 5) {
                ForEach(draw.mainNumbers, id: \.self) { number in
                    Text("\(number)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(white: 0.9))
                        .frame(width: 32, height: 32)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(16)
                }
            }
            
            if let bonus = draw.bonusNumber {
                Text("+")
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.6))
                    .frame(height: 32)
                
                Text("\(bonus)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.orange)
                    .frame(width: 32, height: 32)
                    .background(Color.orange.opacity(0.3))
                    .cornerRadius(16)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(white: 0.08))
    }
}
