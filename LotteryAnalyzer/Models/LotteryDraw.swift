//
//  LotteryDraw.swift
//  LotteryAnalyzer
//
//  Created by fredz on 11/1/25.
//

import Foundation

/// Represents a single lottery drawing with all its data
struct LotteryDraw: Identifiable, Codable {
    // MARK: - Properties
    
    /// Unique identifier for SwiftUI lists
    let id = UUID()
    
    /// Date when the lottery was drawn
    let date: Date
    
    /// Main lottery numbers (typically 5 numbers from 1-70)
    let mainNumbers: [Int]
    
    /// Bonus/Powerball number (typically 1-25)
    let bonusNumber: Int?
    
    /// Original string format for display
    let originalString: String
    
    // MARK: - Initialization
    
    /// Creates a new lottery draw
    /// - Parameters:
    ///   - date: The draw date
    ///   - mainNumbers: Array of main numbers
    ///   - bonusNumber: Optional bonus number
    ///   - originalString: Original formatted string
    init(date: Date, mainNumbers: [Int], bonusNumber: Int?, originalString: String) {
        self.date = date
        self.mainNumbers = mainNumbers
        self.bonusNumber = bonusNumber
        self.originalString = originalString
    }
    
    // MARK: - Computed Properties
    
    /// Sum of all main numbers
    var sum: Int {
        mainNumbers.reduce(0, +)
    }
    
    /// Total sum including bonus number
    var totalSum: Int {
        sum + (bonusNumber ?? 0)
    }
    
    /// Count of even numbers in main numbers
    var evenCount: Int {
        mainNumbers.filter { $0 % 2 == 0 }.count
    }
    
    /// Count of odd numbers in main numbers
    var oddCount: Int {
        mainNumbers.count - evenCount
    }
    
    /// Count of high numbers (36-70)
    var highCount: Int {
        mainNumbers.filter { $0 > 35 }.count
    }
    
    /// Count of low numbers (1-35)
    var lowCount: Int {
        mainNumbers.count - highCount
    }
    
    /// Formatted date string for display
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter.string(from: date)
    }
    
    /// Even/Odd ratio as string (e.g., "3:2")
    var evenOddRatio: String {
        "\(evenCount):\(oddCount)"
    }
    
    /// Low/High ratio as string (e.g., "2:3")
    var lowHighRatio: String {
        "\(lowCount):\(highCount)"
    }
    
    // MARK: - Codable
    
    /// Coding keys for JSON encoding/decoding
    enum CodingKeys: String, CodingKey {
        case date, mainNumbers, bonusNumber, originalString
    }
}

// MARK: - Sample Data

extension LotteryDraw {
    /// Sample lottery draws for preview and testing
    static var sampleDraws: [LotteryDraw] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        
        return [
            LotteryDraw(
                date: dateFormatter.date(from: "10/28/2025")!,
                mainNumbers: [2, 19, 33, 53, 61],
                bonusNumber: 14,
                originalString: "2 19 33 53 61 + 14"
            ),
            LotteryDraw(
                date: dateFormatter.date(from: "10/24/2025")!,
                mainNumbers: [11, 18, 31, 51, 56],
                bonusNumber: 24,
                originalString: "11 18 31 51 56 + 24"
            ),
            LotteryDraw(
                date: dateFormatter.date(from: "10/21/2025")!,
                mainNumbers: [2, 18, 27, 34, 59],
                bonusNumber: 18,
                originalString: "2 18 27 34 59 + 18"
            ),
            LotteryDraw(
                date: dateFormatter.date(from: "10/17/2025")!,
                mainNumbers: [9, 21, 27, 48, 56],
                bonusNumber: 10,
                originalString: "9 21 27 48 56 + 10"
            ),
            LotteryDraw(
                date: dateFormatter.date(from: "10/14/2025")!,
                mainNumbers: [12, 22, 49, 57, 58],
                bonusNumber: 19,
                originalString: "12 22 49 57 58 + 19"
            )
        ]
    }
}
