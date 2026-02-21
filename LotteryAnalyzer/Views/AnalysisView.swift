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

    private func analysisColor(_ type: LotteryViewModel.AnalysisType) -> Color {
        switch type {
        case .frequency:   return .blue
        case .leastCommon: return .orange
        case .bonus:       return .orange
        case .pairs:       return .purple
        case .streak:      return .red
        case .evenOdd:     return .green
        case .highLow:     return .cyan
        case .sum:         return .pink
        case .gapAnalysis: return .indigo
        }
    }

    private var analysisNavigationHeader: some View {
        HStack(spacing: 20) {
            // Left - Previous Analysis (always blue)
            if let previousAnalysis = getPreviousAnalysisType() {
                Button(action: {
                    withAnimation(.easeInOut) {
                        viewModel.currentAnalysis = previousAnalysis
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text("Previous Analysis")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            } else {
                Spacer()
            }

            Spacer()

            // Right - Next Analysis (always orange)
            if let nextAnalysis = getNextAnalysisType() {
                Button(action: {
                    withAnimation(.easeInOut) {
                        viewModel.currentAnalysis = nextAnalysis
                    }
                }) {
                    HStack(spacing: 6) {
                        Text("Next Analysis")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            } else {
                Spacer()
            }
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
                .foregroundColor(Color(white: 0.9))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Selection Info
    
    private var selectionInfo: some View {
        Text("\(viewModel.selectedDraws.count) selected")
            .font(.caption)
            .foregroundColor(Color(white: 0.6))
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
        case .streak:
            HotStreakAnalysisView()
        case .evenOdd:
            EvenOddAnalysisView()
        case .highLow:
            HighLowAnalysisView()
        case .sum:
            SumAnalysisView()
        case .gapAnalysis:
            GapAnalysisView()
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
    @State private var currentPage = 0
    
    var body: some View {
        let frequencies = viewModel.analyzeFrequency()
        let grouped = groupByCount(frequencies)
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(grouped.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, grouped.count)
        let items = Array(grouped[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Number Frequency Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Tracks how often each number (1–70) has appeared across all selected draws. Numbers with higher frequency may indicate historical patterns. Use this to identify the most drawn numbers over time.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                VStack(spacing: 12) {
                    ForEach(items, id: \.count) { group in
                        FrequencyGroupRowMostCommon(count: group.count, numbers: group.numbers)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
    
    private func groupByCount(_ freqs: [NumberFrequency]) -> [(count: Int, numbers: [Int])] {
        var grouped: [Int: [Int]] = [:]
        for f in freqs { grouped[f.count, default: []].append(f.number) }
        return grouped.map { (count: $0.key, numbers: $0.value.sorted()) }.sorted { $0.count > $1.count }
    }
}

// MARK: - Least Common Analysis View

struct LeastCommonAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let frequencies = viewModel.analyzeLeastCommon()
        let grouped = groupByCount(frequencies)
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(grouped.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, grouped.count)
        let items = Array(grouped[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Least Common Numbers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("These are the coldest numbers in your selected data — appearing the fewest times historically. Unlike the Gap Analysis, low frequency here isn't about being \"due\" — these numbers have simply been drawn less overall. Cold numbers may stay cold. Treat this as a caution list rather than a pick list.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                VStack(spacing: 12) {
                    ForEach(items, id: \.count) { group in
                        FrequencyGroupRow(count: group.count, numbers: group.numbers)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
    
    private func groupByCount(_ freqs: [NumberFrequency]) -> [(count: Int, numbers: [Int])] {
        var grouped: [Int: [Int]] = [:]
        for f in freqs { grouped[f.count, default: []].append(f.number) }
        return grouped.map { (count: $0.key, numbers: $0.value.sorted()) }.sorted { $0.count < $1.count }
    }
}

// MARK: - Bonus Analysis View

struct BonusAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let frequencies = viewModel.analyzeBonusFrequency()
        let grouped = groupByCount(frequencies)
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(grouped.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, grouped.count)
        let items = Array(grouped[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bonus Ball Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Analyzes historical frequency of the Mega Ball (1–25) across selected draws. Knowing which bonus numbers appear most often can help you understand patterns in that separate pool of numbers.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                VStack(spacing: 12) {
                    ForEach(items, id: \.count) { group in
                        BonusGroupRow(count: group.count, numbers: group.numbers)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
    
    private func groupByCount(_ freqs: [NumberFrequency]) -> [(count: Int, numbers: [Int])] {
        var grouped: [Int: [Int]] = [:]
        for f in freqs { grouped[f.count, default: []].append(f.number) }
        return grouped.map { (count: $0.key, numbers: $0.value.sorted()) }.sorted { $0.count > $1.count }
    }
}

// MARK: - Pairs Analysis View

struct PairsAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let pairs = viewModel.analyzePairs()
        let grouped = groupPairsByCount(pairs)
        let itemsPerPage = 5
        let totalPages = max(1, Int(ceil(Double(grouped.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, grouped.count)
        let items = Array(grouped[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Number Pairs Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Identifies pairs of numbers that have appeared together most frequently in the same draw. Reveals historical co-occurrence patterns across your selected data range.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                VStack(spacing: 12) {
                    ForEach(items, id: \.count) { group in
                        PairGroupRow(count: group.count, pairs: group.pairs)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
    
    private func groupPairsByCount(_ pairs: [NumberPair]) -> [(count: Int, pairs: [(Int, Int)])] {
        var grouped: [Int: [(Int, Int)]] = [:]
        for p in pairs { grouped[p.count, default: []].append((p.number1, p.number2)) }
        return grouped.map { (count: $0.key, pairs: $0.value) }.sorted { $0.count > $1.count }
    }
}

// MARK: - Even/Odd Analysis View

struct EvenOddAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let draws = viewModel.getSelectedDraws()
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(draws.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, draws.count)
        let items = Array(draws[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Even / Odd Distribution Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Shows the balance of even vs odd numbers in each draw. Historically, draws tend to mix both. A 3/2 or 2/3 even/odd split is most common — this view helps you spot those trends across your selected draws.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            let avgEven = Double(draws.reduce(0) { $0 + $1.evenCount }) / Double(max(1, draws.count))
            HStack(spacing: 15) {
                StatBox(title: "Avg Even", value: String(format: "%.1f", avgEven), color: .green)
                StatBox(title: "Avg Odd", value: String(format: "%.1f", 5.0 - avgEven), color: .orange)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                ForEach(items) { draw in
                    HStack(spacing: 12) {
                        Text(draw.dateString)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color(white: 0.7))
                            .frame(width: 90, alignment: .leading)
                        Text(draw.evenOddRatio)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(Color(white: 0.9))
                            .frame(width: 40)
                        HStack(spacing: 4) {
                            ForEach(0..<draw.evenCount, id: \.self) { _ in
                                Circle().fill(Color.green).frame(width: 22, height: 22)
                            }
                            ForEach(0..<draw.oddCount, id: \.self) { _ in
                                Circle().fill(Color.orange).frame(width: 22, height: 22)
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
}

// MARK: - High/Low Analysis View

struct HighLowAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let draws = viewModel.getSelectedDraws()
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(draws.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, draws.count)
        let items = Array(draws[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("High / Low Range Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Splits numbers into low (1–35) and high (36–70) ranges and tracks how each draw is distributed. Most winning draws contain a mix of both ranges — see how often that pattern holds in your selected data.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            let avgLow = Double(draws.reduce(0) { $0 + $1.lowCount }) / Double(max(1, draws.count))
            HStack(spacing: 15) {
                StatBox(title: "Avg Low", value: String(format: "%.1f", avgLow), color: .blue)
                StatBox(title: "Avg High", value: String(format: "%.1f", 5.0 - avgLow), color: .red)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                ForEach(items) { draw in
                    HStack(spacing: 12) {
                        Text(draw.dateString)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color(white: 0.7))
                            .frame(width: 90, alignment: .leading)
                        Text(draw.lowHighRatio)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(Color(white: 0.9))
                            .frame(width: 40)
                        HStack(spacing: 4) {
                            ForEach(0..<draw.lowCount, id: \.self) { _ in
                                Circle().fill(Color.blue).frame(width: 22, height: 22)
                            }
                            ForEach(0..<draw.highCount, id: \.self) { _ in
                                Circle().fill(Color.red).frame(width: 22, height: 22)
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
}

// MARK: - Sum Analysis View

struct SumAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let draws = viewModel.getSelectedDraws()
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(draws.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, draws.count)
        let items = Array(draws[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Number Sum Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Calculates the total sum of the 5 main numbers in each draw. Research shows most winning combinations fall within a mid-range sum. Use this to understand what sum ranges appear most often historically.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            let avgSum = Double(draws.reduce(0) { $0 + $1.sum }) / Double(max(1, draws.count))
            let minSum = draws.map { $0.sum }.min() ?? 0
            let maxSum = draws.map { $0.sum }.max() ?? 0
            HStack(spacing: 10) {
                StatBox(title: "Avg", value: String(format: "%.0f", avgSum), color: .purple)
                StatBox(title: "Min", value: "\(minSum)", color: .cyan)
                StatBox(title: "Max", value: "\(maxSum)", color: .pink)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                ForEach(items) { draw in
                    HStack(spacing: 10) {
                        // Date
                        Text(draw.dateString)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color(white: 0.7))
                            .frame(width: 90, alignment: .leading)
                        
                        // Main sum with label
                        VStack(spacing: 2) {
                            Text("Main Balls")
                                .font(.system(size: 9))
                                .foregroundColor(Color(white: 0.5))
                            Text("\(draw.sum)")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                        }
                        
                        // Plus
                        Text("+")
                            .font(.body)
                            .foregroundColor(Color(white: 0.5))
                            .padding(.top, 12)
                        
                        // Bonus with label
                        VStack(spacing: 2) {
                            Text("Bonus")
                                .font(.system(size: 9))
                                .foregroundColor(Color(white: 0.5))
                            Text("\(draw.bonusNumber ?? 0)")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        // Equals
                        Text("=")
                            .font(.body)
                            .foregroundColor(Color(white: 0.5))
                            .padding(.top, 12)
                        
                        // Total with label
                        VStack(spacing: 2) {
                            Text("Total")
                                .font(.system(size: 9))
                                .foregroundColor(Color(white: 0.5))
                            Text("\(draw.totalSum)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
}

// MARK: - Hot Streak Analysis View

struct HotStreakAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 0
    
    var body: some View {
        let streaks = viewModel.analyzeHotStreaks()
        let itemsPerPage = 10
        let totalPages = max(1, Int(ceil(Double(streaks.count) / Double(itemsPerPage))))
        let startIdx = currentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, streaks.count)
        let items = Array(streaks[startIdx..<endIdx])
        
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Hot Streak Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Shows which numbers have appeared most frequently in the last 20 selected draws. Hot numbers are currently on a streak — useful for spotting short-term momentum patterns in recent drawing history.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { if currentPage < totalPages - 1 { currentPage += 1 } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)
                        Button(action: { if currentPage > 0 { currentPage -= 1 } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }
                VStack(spacing: 12) {
                    ForEach(items, id: \.number) { streak in
                        HotStreakRow(streak: streak)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }
}




// MARK: - Helper Components

// MARK: - Frequency Group Row

/// Single row showing a frequency count and its numbers
struct FrequencyGroupRow: View {
    let count: Int
    let numbers: [Int]
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
                    .foregroundColor(Color(white: 0.6))
            }
            .frame(width: 70)
            
            // Numbers column (right) - wrapped balls
            FlowLayout(spacing: 8) {
                ForEach(numbers, id: \.self) { number in
                    NumberBall(
                        number: number,
                        color: ballColor
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
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
        var body: some View {
        Text("\(number)")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(color.opacity(0.8))
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

// MARK: - Frequency Group Row (Most Common)

struct FrequencyGroupRowMostCommon: View {
    let count: Int
    let numbers: [Int]
        var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(countColor)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.6))
            }
            .frame(width: 70)
            
            FlowLayout(spacing: 8) {
                ForEach(numbers, id: \.self) { number in
                    NumberBall(
                        number: number,
                        color: ballColor
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
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
        var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.6))
            }
            .frame(width: 70)
            
            FlowLayout(spacing: 8) {
                ForEach(numbers, id: \.self) { number in
                    NumberBall(
                        number: number,
                        color: .orange
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Pair Group Row

struct PairGroupRow: View {
    let count: Int
    let pairs: [(Int, Int)]
        var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Text(count == 1 ? "time" : "times")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.6))
            }
            .frame(width: 70)
            
            FlowLayout(spacing: 8) {
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: 2) {
                        NumberBall(
                            number: pair.0,
                            color: .purple
                        )
                        Text("-")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        NumberBall(
                            number: pair.1,
                            color: .purple
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct HotStreakRow: View {
    let streak: (number: Int, streak: Int, lastAppearances: [String])
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
                    .foregroundColor(Color(white: 0.6))
            }
            .frame(width: 60)
            
            NumberBall(
                number: streak.number,
                color: .red
            )
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(streak.lastAppearances.prefix(showAllDates ? streak.lastAppearances.count : 3), id: \.self) { date in
                    Text(date)
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.6))
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
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Helper Views

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
        var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color(white: 0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(10)
    }
}

// MARK: - Gap / Due Number Analysis View
//
// For each number 1–70:
//   avgGap    = totalDraws / appearances      → how often it's "expected" to appear
//   currentGap = draws since last appearance  → how long it has actually been absent
//   dueRatio  = currentGap / avgGap           → 1.0 = right on schedule, >1.0 = overdue
//
// Color scale:
//   blue   < 0.8   recently appeared, not due
//   green  0.8-1.0 approaching average cadence
//   yellow 1.0-1.5 slightly overdue
//   orange 1.5-2.0 notably overdue
//   red    > 2.0   very overdue vs own baseline

struct GapEntry: Identifiable {
    let id = UUID()
    let number: Int
    let appearances: Int
    let avgGap: Double      // draws
    let currentGap: Int     // draws
    let dueRatio: Double    // currentGap / avgGap
    let lastSeen: String    // date string or "Never"
}

struct GapAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var filter: GapFilter = .all
    @State private var currentPage = 0

    enum GapFilter: String, CaseIterable {
        case all        = "All"
        case overdue    = "Overdue"
        case veryOverdue = "Very Overdue"
    }

    var body: some View {
        let entries = computeGapEntries()
        let filtered = filteredEntries(entries)
        let itemsPerPage = 12
        let totalPages = max(1, Int(ceil(Double(filtered.count) / Double(itemsPerPage))))
        let safeCurrentPage = min(currentPage, totalPages - 1)
        let startIdx = safeCurrentPage * itemsPerPage
        let endIdx = min(startIdx + itemsPerPage, filtered.count)
        let items = filtered.isEmpty ? [] : Array(filtered[startIdx..<endIdx])

        VStack(alignment: .leading, spacing: 15) {

            // ── Description Card ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text("Gap / Due Number Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Tracks how long each number has been absent relative to its own historical average gap. A Due Ratio above 1.0 means the number is overdue vs its own baseline — not a guarantee, but a statistically anomalous absence.")
                    .font(.body)
                    .foregroundColor(Color(white: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)

            // ── Top 3 Most Overdue ────────────────────────────────────────────
            let topOverdue = entries.filter { $0.appearances > 1 }.prefix(3)
            if !topOverdue.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MOST OVERDUE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(white: 0.5))
                        .tracking(1)

                    HStack(spacing: 10) {
                        ForEach(Array(topOverdue)) { entry in
                            TopOverdueCard(entry: entry)
                        }
                    }
                }
                .padding()
                .background(Color(white: 0.1))
                .cornerRadius(12)
            }

            // ── Filter Picker ─────────────────────────────────────────────────
            HStack(spacing: 8) {
                ForEach(GapFilter.allCases, id: \.self) { f in
                    Button(action: {
                        filter = f
                        currentPage = 0
                    }) {
                        Text(f.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(filter == f ? .white : Color(white: 0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                filter == f
                                    ? AnyView(LinearGradient(
                                        gradient: Gradient(colors: [Color.indigo, Color.purple]),
                                        startPoint: .leading, endPoint: .trailing
                                      ).cornerRadius(10))
                                    : AnyView(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.15)))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // ── Legend ────────────────────────────────────────────────────────
            HStack(spacing: 6) {
                legendDot(.blue,   "< 0.8")
                legendDot(.green,  "0.8–1×")
                legendDot(.yellow, "1–1.5×")
                legendDot(.orange, "1.5–2×")
                legendDot(.red,    "> 2×")
                Spacer()
                Text("Due Ratio")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.4))
            }
            .padding(.horizontal, 4)

            // ── Paginated List ────────────────────────────────────────────────
            VStack(spacing: 10) {
                HStack {
                    Text("Page \(safeCurrentPage + 1) of \(totalPages)")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                    Spacer()
                    HStack(spacing: 15) {
                        // Left chevron = next page  (matches existing analysis views)
                        Button(action: {
                            if currentPage < totalPages - 1 { currentPage += 1 }
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage < totalPages - 1 ? .indigo : .gray)
                        }
                        .disabled(currentPage >= totalPages - 1)

                        // Right chevron = previous page (matches existing analysis views)
                        Button(action: {
                            if currentPage > 0 { currentPage -= 1 }
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(currentPage > 0 ? .indigo : .gray)
                        }
                        .disabled(currentPage <= 0)
                    }
                }

                if items.isEmpty {
                    Text("No numbers match this filter.")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                } else {
                    VStack(spacing: 8) {
                        ForEach(items) { entry in
                            GapEntryRow(entry: entry)
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.1)))
        }
    }

    // MARK: - Computation

    private func computeGapEntries() -> [GapEntry] {
        let draws = viewModel.getSelectedDraws()  // draws[0] = most recent
        guard !draws.isEmpty else { return [] }

        let totalDraws = draws.count
        var entries: [GapEntry] = []

        for number in 1...70 {
            // Count appearances and find last seen date
            var appearances = 0
            var lastSeenStr = "Never"
            var firstAppearanceIndex: Int? = nil  // index of most recent appearance in draws[]

            for (index, draw) in draws.enumerated() {
                if draw.mainNumbers.contains(number) {
                    appearances += 1
                    if firstAppearanceIndex == nil {
                        firstAppearanceIndex = index
                        lastSeenStr = draw.dateString
                    }
                }
            }

            // currentGap = how many draws have passed since last appearance
            // If never appeared, use totalDraws as gap
            let currentGap = firstAppearanceIndex ?? totalDraws

            // Need at least 2 appearances for a meaningful average gap
            guard appearances > 1 else {
                entries.append(GapEntry(
                    number: number,
                    appearances: appearances,
                    avgGap: appearances == 0 ? Double(totalDraws) : Double(totalDraws),
                    currentGap: currentGap,
                    dueRatio: appearances == 0 ? 99.0 : Double(currentGap) / Double(totalDraws),
                    lastSeen: lastSeenStr
                ))
                continue
            }

            let avgGap = Double(totalDraws) / Double(appearances)
            let dueRatio = Double(currentGap) / avgGap

            entries.append(GapEntry(
                number: number,
                appearances: appearances,
                avgGap: avgGap,
                currentGap: currentGap,
                dueRatio: dueRatio,
                lastSeen: lastSeenStr
            ))
        }

        // Sort by dueRatio descending — most overdue first
        return entries.sorted { $0.dueRatio > $1.dueRatio }
    }

    private func filteredEntries(_ entries: [GapEntry]) -> [GapEntry] {
        switch filter {
        case .all:
            return entries
        case .overdue:
            return entries.filter { $0.dueRatio > 1.0 && $0.appearances > 1 }
        case .veryOverdue:
            return entries.filter { $0.dueRatio > 2.0 && $0.appearances > 1 }
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundColor(Color(white: 0.5))
        }
    }
}

// MARK: - Top Overdue Card

struct TopOverdueCard: View {
    let entry: GapEntry

    var body: some View {
        VStack(spacing: 6) {
            NumberBall(number: entry.number, color: dueColor(entry.dueRatio))

            Text(String(format: "%.1f×", entry.dueRatio))
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(dueColor(entry.dueRatio))

            Text("overdue")
                .font(.caption2)
                .foregroundColor(Color(white: 0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(dueColor(entry.dueRatio).opacity(0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(dueColor(entry.dueRatio).opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Gap Entry Row

struct GapEntryRow: View {
    let entry: GapEntry

    var body: some View {
        HStack(spacing: 12) {

            // Number ball
            NumberBall(number: entry.number, color: dueColor(entry.dueRatio))
                .frame(width: 36)

            // Due ratio bar + ratio label
            VStack(alignment: .leading, spacing: 4) {
                // Bar: 1.0 = full width of the "normal" zone; cap visual at 3×
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(white: 0.2))
                            .frame(height: 8)

                        // 1× marker line
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 1.5, height: 12)
                            .offset(x: geo.size.width / 3)  // 1× is at 1/3 of the 3× scale

                        // Fill bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(dueColor(entry.dueRatio))
                            .frame(
                                width: min(geo.size.width, geo.size.width * CGFloat(entry.dueRatio / 3.0)),
                                height: 8
                            )
                    }
                }
                .frame(height: 12)

                HStack(spacing: 6) {
                    Text(String(format: "%.2f×", entry.dueRatio))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(dueColor(entry.dueRatio))

                    Text("avg \(String(format: "%.0f", entry.avgGap)) draws")
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.45))

                    Text("·")
                        .foregroundColor(Color(white: 0.3))

                    Text("absent \(entry.currentGap)")
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.45))
                }
            }

            Spacer(minLength: 0)

            // Last seen
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.lastSeen == "Never" ? "Never" : "Last:")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.4))
                Text(entry.lastSeen == "Never" ? "" : entry.lastSeen)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(Color(white: 0.65))
                Text("\(entry.appearances)×")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.4))
            }
            .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(dueColor(entry.dueRatio).opacity(0.07))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(dueColor(entry.dueRatio).opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Shared due-ratio color helper (file-scoped)

private func dueColor(_ ratio: Double) -> Color {
    switch ratio {
    case ..<0.8:  return .blue
    case 0.8..<1.0: return .green
    case 1.0..<1.5: return .yellow
    case 1.5..<2.0: return .orange
    default:        return .red
    }
}

// MARK: - Preview

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView()
            .environmentObject(LotteryViewModel())
    }
}
