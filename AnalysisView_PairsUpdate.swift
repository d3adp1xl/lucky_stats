//
//  AnalysisView_PairsUpdate.swift
//  
//  Replace the PairsAnalysisView in your AnalysisView.swift with this version
//

import SwiftUI

// MARK: - Pairs Analysis View (Updated with Pagination)

struct PairsAnalysisView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentGroupIndex = 0
    
    var body: some View {
        let pairs = viewModel.analyzePairs()
        let groupedByCount = groupPairsByCount(pairs)
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Shows which numbers appear together most often")
                .font(.subheadline)
                .foregroundColor(Color(white: 0.6))
                .padding(.bottom, 5)
            
            if !groupedByCount.isEmpty {
                pairNavigationView(groupedByCount: groupedByCount)
            }
        }
    }
    
    private func pairNavigationView(groupedByCount: [(count: Int, pairs: [(Int, Int)])]) -> some View {
        // Show 5 groups at a time
        let groupsPerPage = 5
        let totalPages = Int(ceil(Double(groupedByCount.count) / Double(groupsPerPage)))
        let startIndex = currentGroupIndex * groupsPerPage
        let endIndex = min(startIndex + groupsPerPage, groupedByCount.count)
        let currentGroups = Array(groupedByCount[startIndex..<endIndex])
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Page \(currentGroupIndex + 1) of \(totalPages)")
                    .font(.headline)
                    .foregroundColor(Color(white: 0.9))
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        if currentGroupIndex < totalPages - 1 {
                            withAnimation {
                                currentGroupIndex += 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title3)
                            .foregroundColor(currentGroupIndex < totalPages - 1 ? .blue : .gray)
                    }
                    .disabled(currentGroupIndex >= totalPages - 1)
                    
                    Button(action: {
                        if currentGroupIndex > 0 {
                            withAnimation {
                                currentGroupIndex -= 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title3)
                            .foregroundColor(currentGroupIndex > 0 ? .blue : .gray)
                    }
                    .disabled(currentGroupIndex <= 0)
                }
            }
            
            ForEach(currentGroups, id: \.count) { group in
                PairGroupRow(
                    count: group.count,
                    pairs: group.pairs
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
                .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
        )
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

// MARK: - Pair Group Row (Updated for black background)

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
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Number Ball Component (Updated for black background)

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
