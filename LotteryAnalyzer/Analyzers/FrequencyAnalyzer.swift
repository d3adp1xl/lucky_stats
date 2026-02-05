//
//  FrequencyAnalyzer.swift
//  LotteryAnalyzer
//
//  Analyzes frequency of numbers appearing in lottery draws
//

import Foundation

/// Result structure for number frequency analysis
struct NumberFrequency: Identifiable {
    let id = UUID()
    let number: Int
    let count: Int
    
    /// Percentage of total draws this number appeared in
    var percentage: Double {
        0 // Will be calculated by analyzer
    }
}

/// Analyzes how often each number appears in lottery draws
class FrequencyAnalyzer {
    
    // MARK: - Main Number Analysis
    
    /// Analyze frequency of main numbers (1-70)
    /// - Parameter draws: Array of lottery draws to analyze
    /// - Returns: Array of NumberFrequency sorted by count (descending)
    func analyzeMainNumbers(_ draws: [LotteryDraw]) -> [NumberFrequency] {
        // Create a dictionary to count occurrences
        var frequencyMap: [Int: Int] = [:]
        
        // Count each number's occurrences
        for draw in draws {
            for number in draw.mainNumbers {
                frequencyMap[number, default: 0] += 1
            }
        }
        
        // Convert to array of NumberFrequency
        let frequencies = frequencyMap.map { number, count in
            NumberFrequency(number: number, count: count)
        }
        
        // Sort by count (highest first)
        return frequencies.sorted { $0.count > $1.count }
    }
    
    // MARK: - Bonus Number Analysis
    
    /// Analyze frequency of bonus numbers
    /// - Parameter draws: Array of lottery draws to analyze
    /// - Returns: Array of NumberFrequency sorted by count (descending)
    func analyzeBonusNumbers(_ draws: [LotteryDraw]) -> [NumberFrequency] {
        // Create a dictionary to count occurrences
        var frequencyMap: [Int: Int] = [:]
        
        // Count each bonus number's occurrences
        for draw in draws {
            if let bonus = draw.bonusNumber {
                frequencyMap[bonus, default: 0] += 1
            }
        }
        
        // Convert to array of NumberFrequency
        let frequencies = frequencyMap.map { number, count in
            NumberFrequency(number: number, count: count)
        }
        
        // Sort by count (highest first)
        return frequencies.sorted { $0.count > $1.count }
    }
    
    // MARK: - Top Numbers
    
    /// Get the top N most frequent numbers
    /// - Parameters:
    ///   - frequencies: Array of NumberFrequency
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of top frequencies
    func getTopNumbers(_ frequencies: [NumberFrequency], limit: Int) -> [NumberFrequency] {
        return Array(frequencies.prefix(limit))
    }
    
    // MARK: - Statistics
    
    /// Calculate average frequency across all numbers
    /// - Parameter frequencies: Array of NumberFrequency
    /// - Returns: Average count as Double
    func averageFrequency(_ frequencies: [NumberFrequency]) -> Double {
        guard !frequencies.isEmpty else { return 0 }
        let total = frequencies.reduce(0) { $0 + $1.count }
        return Double(total) / Double(frequencies.count)
    }
}
