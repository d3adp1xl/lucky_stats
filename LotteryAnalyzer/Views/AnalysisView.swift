//
//  AnalysisView.swift
//  LotteryAnalyzer
//
//  View for displaying various types of analysis
//

import SwiftUI

/// Main analysis view with different analysis options
struct AnalysisView: View {
    
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Analysis navigation header
                analysisNavigationHeader
                    .padding()
                    .background(Color(UIColor.systemGray6))
                
                // Analysis content
                ScrollView {
                    analysisContent
                        .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        handleSwipe(value: value)
                    }
            )
        }
    }
    
    // MARK: - Analysis Navigation Header
    
    private var analysisNavigationHeader: some View {
        VStack(spacing: 8) {
            // Top row - Navigation arrows and names
            HStack(spacing: 12) {
                // Left - Previous Analysis
                if let previousAnalysis = getPreviousAnalysisType() {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.currentAnalysis = previousAnalysis
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                            
                            Text(previousAnalysis.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
                // Right - Next Analysis
                if let nextAnalysis = getNextAnalysisType() {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.currentAnalysis = nextAnalysis
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(nextAnalysis.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Bottom row - Current Analysis (centered, full width)
            Text(viewModel.currentAnalysis.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // MARK: - Analysis Header

    private var analysisHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Navigation arrows on the left
                HStack(spacing: 15) {
                    // Back arrow (red)
                    if let previousAnalysis = getPreviousAnalysisType() {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                viewModel.currentAnalysis = previousAnalysis
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    } else {
                        // Placeholder to keep spacing consistent
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                    
                    // Next arrow (green)
                    if let nextAnalysis = getNextAnalysisType() {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                viewModel.currentAnalysis = nextAnalysis
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    } else {
                        // Placeholder
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                }
                
                Spacer()
            }
            
            // Current analysis name (large)
            Text(viewModel.currentAnalysis.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Selection Info
    
    private var selectionInfo: some View {
        Text("\(viewModel.selectedDraws.count) selected")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    // MARK: - Analysis Content
    
    @ViewBuilder
    private var analysisContent: some View {
        switch viewModel.currentAnalysis {
        case .frequency:
            FrequencyAnalysisView()
        case .leastCommon:
            LeastCommonAnalysisView()
        case .bonus:
            BonusAnalysisView()
        case .pairs:
            PairsAnalysisView()
        case .streak:  // ADD THIS CASE
            HotStreakAnalysisView()  // ADD THIS
        case .evenOdd:
            EvenOddAnalysisView()
        case .highLow:
            HighLowAnalysisView()
        case .sum:
            SumAnalysisView()
        }
    }
    
    // MARK: - Helper Functions
    
    private func getNextAnalysisType() -> LotteryViewModel.AnalysisType? {
        let allTypes = LotteryViewModel.AnalysisType.allCases
        guard let currentIndex = allTypes.firstIndex(of: viewModel.currentAnalysis) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        return nextIndex < allTypes.count ? allTypes[nextIndex] : nil
    }
    
    private func getPreviousAnalysisType() -> LotteryViewModel.AnalysisType? {
        let allTypes = LotteryViewModel.AnalysisType.allCases
        guard let currentIndex = allTypes.firstIndex(of: viewModel.currentAnalysis) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? allTypes[previousIndex] : nil
    }
    
    private func handleSwipe(value: DragGesture.Value) {
        let horizontalDistance = value.translation.width
        let verticalDistance = value.translation.height
        
        if abs(horizontalDistance) > abs(verticalDistance) {
            if horizontalDistance < -50 {
                if let nextType = getNextAnalysisType() {
                    withAnimation(.easeInOut) {
                        viewModel.currentAnalysis = nextType
                    }
                }
            } else if horizontalDistance > 50 {
                if let previousType = getPreviousAnalysisType() {
                    withAnimation(.easeInOut) {
                        viewModel.currentAnalysis = previousType
                    }
                }
            }
        }
    }
}

// MARK: - Expandable Section Component

struct ExpandableSection<Content: View>: View {
    let totalCount: Int
    let showingLimit: Int
    @State private var isExpanded: Bool = false
    let content: (Bool) -> Content
    
    var body: some View {
        VStack(spacing: 10) {
            content(isExpanded)
            
            if totalCount > showingLimit {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        Text(isExpanded ? "Show Less" : "Show More (\(totalCount - showingLimit) more)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// MARK: - Frequency Analysis View

struct FrequencyAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let frequencies = viewModel.analyzeFrequency()
        let groupedByCount = groupNumbersByCount(frequencies)
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows which numbers appear most often in selected draws")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            HStack {
                Text("Appearances")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 90, alignment: .leading)
                
                Text("Numbers")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            ExpandableSection(totalCount: groupedByCount.count, showingLimit: 10) { isExpanded in
                VStack(spacing: 12) {
                    ForEach(Array(groupedByCount.prefix(isExpanded ? groupedByCount.count : 10)), id: \.count) { group in
                        FrequencyGroupRowMostCommon(
                            count: group.count,
                            numbers: group.numbers,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
    }
    
    private func groupNumbersByCount(_ frequencies: [NumberFrequency]) -> [(count: Int, numbers: [Int])] {
        var grouped: [Int: [Int]] = [:]
        
        for freq in frequencies {
            if grouped[freq.count] == nil {
                grouped[freq.count] = []
            }
            grouped[freq.count]?.append(freq.number)
        }
        
        let result = grouped.map { (count: $0.key, numbers: $0.value.sorted()) }
        return result.sorted { $0.count > $1.count }
    }
}
// MARK: - Least Common Analysis View

/// View showing least common numbers analysis in table format
struct LeastCommonAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let leastCommon = viewModel.analyzeLeastCommon()
        let groupedByCount = groupNumbersByCount(leastCommon)
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows numbers that appear least often in selected draws")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            HStack {
                Text("Appearances")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 90, alignment: .leading)
                
                Text("Numbers")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            ExpandableSection(totalCount: groupedByCount.count, showingLimit: 10) { isExpanded in
                VStack(spacing: 12) {
                    ForEach(Array(groupedByCount.prefix(isExpanded ? groupedByCount.count : 10)), id: \.count) { group in
                        FrequencyGroupRow(
                            count: group.count,
                            numbers: group.numbers,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
    }
    
    private func groupNumbersByCount(_ frequencies: [NumberFrequency]) -> [(count: Int, numbers: [Int])] {
        var grouped: [Int: [Int]] = [:]
        
        for freq in frequencies {
            if grouped[freq.count] == nil {
                grouped[freq.count] = []
            }
            grouped[freq.count]?.append(freq.number)
        }
        
        let result = grouped.map { (count: $0.key, numbers: $0.value.sorted()) }
        return result.sorted { $0.count < $1.count }
    }
}

// MARK: - Frequency Group Row

/// Single row showing a frequency count and its numbers
struct FrequencyGroupRow: View {
    let count: Int
    let numbers: [Int]
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Count column (left)
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(countColor)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            // Numbers column (right) - wrapped balls
            FlowLayout(spacing: 8) {
                ForEach(numbers, id: \.self) { number in
                    NumberBall(
                        number: number,
                        color: ballColor,
                        colorScheme: colorScheme
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 4, x: 0, y: 2)
    }
    
    /// Color based on count (red for 0-1, orange for 2-3, yellow for 4+)
    private var countColor: Color {
        switch count {
        case 0:
            return .red
        case 1:
            return .orange
        case 2...3:
            return Color.orange.opacity(0.8)
        default:
            return .blue
        }
    }
    
    /// Ball background color based on count
    private var ballColor: Color {
        switch count {
        case 0:
            return .red
        case 1:
            return .orange
        case 2...3:
            return Color.yellow.opacity(0.7)
        default:
            return .blue
        }
    }
}

// MARK: - Number Ball Component

/// Circular ball displaying a lottery number
struct NumberBall: View {
    let number: Int
    let color: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(colorScheme == .dark ? color.opacity(0.8) : color)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Flow Layout

/// Custom layout that wraps items horizontally
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Bonus Analysis View

struct BonusAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let bonusFreqs = viewModel.analyzeBonusFrequency()
        let groupedByCount = groupNumbersByCount(bonusFreqs)
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows how often each bonus number appears")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            HStack {
                Text("Appearances")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 90, alignment: .leading)
                
                Text("Bonus Numbers")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            ExpandableSection(totalCount: groupedByCount.count, showingLimit: 10) { isExpanded in
                VStack(spacing: 12) {
                    ForEach(Array(groupedByCount.prefix(isExpanded ? groupedByCount.count : 10)), id: \.count) { group in
                        BonusGroupRow(
                            count: group.count,
                            numbers: group.numbers,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
    }
    
    private func groupNumbersByCount(_ frequencies: [NumberFrequency]) -> [(count: Int, numbers: [Int])] {
        var grouped: [Int: [Int]] = [:]
        
        for freq in frequencies {
            if grouped[freq.count] == nil {
                grouped[freq.count] = []
            }
            grouped[freq.count]?.append(freq.number)
        }
        
        let result = grouped.map { (count: $0.key, numbers: $0.value.sorted()) }
        return result.sorted { $0.count > $1.count }
    }
}

// MARK: - Pairs Analysis View

struct PairsAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let pairs = viewModel.analyzePairs()
        let groupedByCount = groupPairsByCount(pairs)
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows which numbers appear together most often")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            HStack {
                Text("Appearances")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 90, alignment: .leading)
                
                Text("Number Pairs")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            ExpandableSection(totalCount: groupedByCount.count, showingLimit: 5) { isExpanded in
                VStack(spacing: 12) {
                    ForEach(Array(groupedByCount.prefix(isExpanded ? groupedByCount.count : 5)), id: \.count) { group in
                        PairGroupRow(
                            count: group.count,
                            pairs: group.pairs,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
    }
    
    private func groupPairsByCount(_ pairs: [NumberPair]) -> [(count: Int, pairs: [(Int, Int)])] {
        var grouped: [Int: [(Int, Int)]] = [:]
        
        for pair in pairs {
            if grouped[pair.count] == nil {
                grouped[pair.count] = []
            }
            grouped[pair.count]?.append((pair.number1, pair.number2))
        }
        
        let result = grouped.map { (count: $0.key, pairs: $0.value) }
        return result.sorted { $0.count > $1.count }
    }
}

// MARK: - Even/Odd Analysis View

struct EvenOddAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var currentMonthIndex = 0
    
    var body: some View {
        let draws = viewModel.getSelectedDraws()
        let groupedByMonth = groupDrawsByMonth(draws)
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows the balance between even and odd numbers")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            summaryStats(draws: draws)
            
            if !groupedByMonth.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(groupedByMonth[currentMonthIndex].monthName)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                if currentMonthIndex < groupedByMonth.count - 1 {
                                    withAnimation {
                                        currentMonthIndex += 1
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(currentMonthIndex < groupedByMonth.count - 1 ? .blue : .gray)
                            }
                            .disabled(currentMonthIndex >= groupedByMonth.count - 1)
                            
                            Button(action: {
                                if currentMonthIndex > 0 {
                                    withAnimation {
                                        currentMonthIndex -= 1
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(currentMonthIndex > 0 ? .blue : .gray)
                            }
                            .disabled(currentMonthIndex <= 0)
                        }
                    }
                    
                    ForEach(groupedByMonth[currentMonthIndex].draws) { draw in
                        HStack {
                            Text(draw.dateString)
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(draw.evenOddRatio)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 60)
                            
                            HStack(spacing: 2) {
                                ForEach(0..<draw.evenCount, id: \.self) { _ in
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 20, height: 20)
                                }
                                ForEach(0..<draw.oddCount, id: \.self) { _ in
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.top)
            }
        }
    }
    
    private func groupDrawsByMonth(_ draws: [LotteryDraw]) -> [(monthName: String, draws: [LotteryDraw])] {
        let calendar = Calendar.current
        var grouped: [String: [LotteryDraw]] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        for draw in draws {
            let monthYear = dateFormatter.string(from: draw.date)
            if grouped[monthYear] == nil {
                grouped[monthYear] = []
            }
            grouped[monthYear]?.append(draw)
        }
        
        return grouped.map { (monthName: $0.key, draws: $0.value.sorted { $0.date > $1.date }) }
            .sorted { month1, month2 in
                guard let date1 = dateFormatter.date(from: month1.monthName),
                      let date2 = dateFormatter.date(from: month2.monthName) else {
                    return false
                }
                return date1 > date2
            }
    }
    
    private func summaryStats(draws: [LotteryDraw]) -> some View {
        let avgEven = Double(draws.reduce(0) { $0 + $1.evenCount }) / Double(draws.count)
        let avgOdd = 5.0 - avgEven
        
        return VStack(spacing: 10) {
            HStack(spacing: 20) {
                StatBox(
                    title: "Avg Even",
                    value: String(format: "%.1f", avgEven),
                    color: .green
                )
                
                StatBox(
                    title: "Avg Odd",
                    value: String(format: "%.1f", avgOdd),
                    color: .orange
                )
            }
        }
        .padding(.vertical)
    }
}

// MARK: - High/Low Analysis View

struct HighLowAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let draws = viewModel.getSelectedDraws()
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Low: 1-35, High: 36-70")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            summaryStats(draws: draws)
            
            ExpandableSection(totalCount: draws.count, showingLimit: 10) { isExpanded in
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(draws.prefix(isExpanded ? draws.count : 10))) { draw in
                        HStack {
                            Text(draw.dateString)
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(draw.lowHighRatio)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 60)
                            
                            HStack(spacing: 2) {
                                ForEach(0..<draw.lowCount, id: \.self) { _ in
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 20, height: 20)
                                }
                                ForEach(0..<draw.highCount, id: \.self) { _ in
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    private func summaryStats(draws: [LotteryDraw]) -> some View {
        let avgLow = Double(draws.reduce(0) { $0 + $1.lowCount }) / Double(draws.count)
        let avgHigh = 5.0 - avgLow
        
        return VStack(spacing: 10) {
            HStack(spacing: 20) {
                StatBox(
                    title: "Avg Low",
                    value: String(format: "%.1f", avgLow),
                    color: .blue
                )
                
                StatBox(
                    title: "Avg High",
                    value: String(format: "%.1f", avgHigh),
                    color: .red
                )
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Sum Analysis View

struct SumAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let draws = viewModel.getSelectedDraws()
        
        VStack(alignment: .leading, spacing: 15) {
            // REMOVED: Text("Number Sum Analysis")
            
            Text("Total of all numbers in each draw")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            summaryStats(draws: draws)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("By Draw")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                ForEach(draws) { draw in
                    HStack {
                        Text(draw.dateString)
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 80, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Main: \(draw.sum)")
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            if let bonus = draw.bonusNumber {
                                Text("+ Bonus: \(bonus)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .frame(width: 100, alignment: .leading)
                        
                        Text("\(draw.totalSum)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.top)
        }
    }
    
    private func summaryStats(draws: [LotteryDraw]) -> some View {
        let avgSum = Double(draws.reduce(0) { $0 + $1.sum }) / Double(draws.count)
        let minSum = draws.map { $0.sum }.min() ?? 0
        let maxSum = draws.map { $0.sum }.max() ?? 0
        
        return VStack(spacing: 10) {
            HStack(spacing: 15) {
                StatBox(
                    title: "Avg Sum",
                    value: String(format: "%.0f", avgSum),
                    color: .blue
                )
                
                StatBox(
                    title: "Min Sum",
                    value: "\(minSum)",
                    color: .green
                )
                
                StatBox(
                    title: "Max Sum",
                    value: "\(maxSum)",
                    color: .red
                )
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Frequency Group Row (Most Common)

struct FrequencyGroupRowMostCommon: View {
    let count: Int
    let numbers: [Int]
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(countColor)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            FlowLayout(spacing: 8) {
                ForEach(numbers, id: \.self) { number in
                    NumberBall(
                        number: number,
                        color: ballColor,
                        colorScheme: colorScheme
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 4, x: 0, y: 2)
    }
    
    private var countColor: Color {
        switch count {
        case 0...3:
            return .orange
        case 4...6:
            return .blue
        default:
            return .green
        }
    }
    
    private var ballColor: Color {
        switch count {
        case 0...3:
            return .orange
        case 4...6:
            return .blue
        default:
            return .green
        }
    }
}

// MARK: - Bonus Group Row

struct BonusGroupRow: View {
    let count: Int
    let numbers: [Int]
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            FlowLayout(spacing: 8) {
                ForEach(numbers, id: \.self) { number in
                    NumberBall(
                        number: number,
                        color: .orange,
                        colorScheme: colorScheme
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Pair Group Row

struct PairGroupRow: View {
    let count: Int
    let pairs: [(Int, Int)]
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            FlowLayout(spacing: 8) {
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: 2) {
                        NumberBall(
                            number: pair.0,
                            color: .purple,
                            colorScheme: colorScheme
                        )
                        Text("-")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        NumberBall(
                            number: pair.1,
                            color: .purple,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Hot Streak Analysis View

struct HotStreakAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let streaks = viewModel.analyzeHotStreaks()
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows numbers with most appearances in recent 20 draws")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            HStack {
                Text("Streak")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                
                Text("Number")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                
                Text("Recent Appearances")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            ExpandableSection(totalCount: streaks.count, showingLimit: 10) { isExpanded in
                VStack(spacing: 12) {
                    ForEach(Array(streaks.prefix(isExpanded ? streaks.count : 10)), id: \.number) { streak in
                        HotStreakRow(streak: streak, colorScheme: colorScheme)
                    }
                }
            }
        }
    }
}

struct HotStreakRow: View {
    let streak: (number: Int, streak: Int, lastAppearances: [String])
    let colorScheme: ColorScheme
    @State private var showAllDates = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(streak.streak)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text(streak.streak == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            NumberBall(
                number: streak.number,
                color: .red,
                colorScheme: colorScheme
            )
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(streak.lastAppearances.prefix(showAllDates ? streak.lastAppearances.count : 3), id: \.self) { date in
                    Text(date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if streak.lastAppearances.count > 3 {
                    Button(action: {
                        withAnimation {
                            showAllDates.toggle()
                        }
                    }) {
                        Text(showAllDates ? "Show less" : "+\(streak.lastAppearances.count - 3) more")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Helper Views

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colorScheme == .dark ? color.opacity(0.2) : color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Preview

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnalysisView()
                .environmentObject(LotteryViewModel())
                .preferredColorScheme(.light)
            
            AnalysisView()
                .environmentObject(LotteryViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
