//
//  PairAnalyzer.swift
//  LotteryAnalyzer
//
//  Analyzes pairs of numbers that appear together
//

import Foundation

/// Result structure for number pair analysis
struct NumberPair: Identifiable {
    let id = UUID()
    let number1: Int
    let number2: Int
    let count: Int
    
    /// String representation of the pair (e.g., "5-23")
    var pairString: String {
        "\(number1)-\(number2)"
    }
}

/// Analyzes which number pairs appear together most frequently
class PairAnalyzer {
    
    // MARK: - Pair Analysis
    
    /// Analyze all pairs of numbers that appear together
    /// - Parameter draws: Array of lottery draws to analyze
    /// - Returns: Array of NumberPair sorted by frequency (descending)
    func analyzeNumberPairs(_ draws: [LotteryDraw]) -> [NumberPair] {
        // Dictionary to store pair occurrences
        // Key format: "num1-num2" where num1 < num2
        var pairMap: [String: (Int, Int, Int)] = [:]
        
        // Analyze each draw
        for draw in draws {
            let numbers = draw.mainNumbers.sorted()
            
            // Check all possible pairs in this draw
            for i in 0..<numbers.count {
                for j in (i+1)..<numbers.count {
                    let num1 = numbers[i]
                    let num2 = numbers[j]
                    let key = "\(num1)-\(num2)"
                    
                    // Update count for this pair
                    if let existing = pairMap[key] {
                        pairMap[key] = (num1, num2, existing.2 + 1)
                    } else {
                        pairMap[key] = (num1, num2, 1)
                    }
                }
            }
        }
        
        // Convert to array of NumberPair
        let pairs = pairMap.map { _, value in
            NumberPair(number1: value.0, number2: value.1, count: value.2)
        }
        
        // Sort by count (highest first)
        return pairs.sorted { $0.count > $1.count }
    }
    
    // MARK: - Top Pairs
    
    /// Get the top N most frequent pairs
    /// - Parameters:
    ///   - pairs: Array of NumberPair
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of top pairs
    func getTopPairs(_ pairs: [NumberPair], limit: Int) -> [NumberPair] {
        return Array(pairs.prefix(limit))
    }
    
    // MARK: - Pair Statistics
    
    /// Find all pairs containing a specific number
    /// - Parameters:
    ///   - number: The number to search for
    ///   - pairs: Array of all pairs
    /// - Returns: Array of pairs containing the number
    func findPairsContaining(_ number: Int, in pairs: [NumberPair]) -> [NumberPair] {
        return pairs.filter { $0.number1 == number || $0.number2 == number }
    }
}
