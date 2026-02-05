//
//  DataParser.swift
//  LotteryAnalyzer
//
//  Utility to parse lottery data from text format
//

import Foundation

/// Handles parsing of lottery data from various text formats
class DataParser {
    
    // MARK: - Properties
    
    /// Date formatter for parsing dates in format M/d/yyyy
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter
    }()
    
    // MARK: - Public Methods
    
    /// Parse lottery data from a multi-line string
    /// - Parameter text: Text containing lottery draws, one per line
    /// - Returns: Array of parsed LotteryDraw objects
    func parseText(_ text: String) -> [LotteryDraw] {
        // Split text into individual lines
        let lines = text.components(separatedBy: .newlines)
        
        // Parse each line and filter out any nil results
        return lines.compactMap { line in
            parseLine(line.trimmingCharacters(in: .whitespaces))
        }
    }
    
    /// Parse a single line of lottery data
    /// Format: "10/28/2025, 2 19 33 53 61 + 14"
    /// - Parameter line: Single line of text
    /// - Returns: LotteryDraw object or nil if parsing fails
    func parseLine(_ line: String) -> LotteryDraw? {
        // Skip empty lines
        guard !line.isEmpty else { return nil }
        
        // Split by comma to separate date and numbers
        let parts = line.components(separatedBy: ",")
        guard parts.count == 2 else {
            print("Error: Invalid format - expected comma separator: \(line)")
            return nil
        }
        
        // Parse date
        let dateString = parts[0].trimmingCharacters(in: .whitespaces)
        guard let date = dateFormatter.date(from: dateString) else {
            print("Error: Could not parse date: \(dateString)")
            return nil
        }
        
        // Parse numbers
        let numbersString = parts[1].trimmingCharacters(in: .whitespaces)
        let numberParts = numbersString.components(separatedBy: "+")
        
        // Parse main numbers (before the +)
        let mainNumbersString = numberParts[0].trimmingCharacters(in: .whitespaces)
        let mainNumbers = mainNumbersString
            .components(separatedBy: .whitespaces)
            .compactMap { Int($0) }
        
        // Validate main numbers
        guard mainNumbers.count == 5 else {
            print("Error: Expected 5 main numbers, got \(mainNumbers.count): \(line)")
            return nil
        }
        
        // Parse bonus number (after the +)
        var bonusNumber: Int? = nil
        if numberParts.count > 1 {
            let bonusString = numberParts[1].trimmingCharacters(in: .whitespaces)
            bonusNumber = Int(bonusString)
        }
        
        // Create and return LotteryDraw
        return LotteryDraw(
            date: date,
            mainNumbers: mainNumbers,
            bonusNumber: bonusNumber,
            originalString: numbersString
        )
    }
    
    // MARK: - Default Data
    
    /// Returns default sample lottery data as a string
    static var defaultData: String {
        """
        10/28/2025, 2 19 33 53 61 + 14
        10/24/2025, 11 18 31 51 56 + 24
        10/21/2025, 2 18 27 34 59 + 18
        10/17/2025, 9 21 27 48 56 + 10
        10/14/2025, 12 22 49 57 58 + 19
        10/10/2025, 3 18 23 32 56 + 8
        10/7/2025, 17 26 33 45 56 + 19
        10/3/2025, 18 19 38 54 57 + 19
        9/30/2025, 4 8 27 37 63 + 14
        9/26/2025, 4 21 27 33 49 + 21
        9/23/2025, 13 24 41 42 70 + 18
        9/19/2025, 2 22 27 42 58 + 8
        9/16/2025, 10 14 34 40 43 + 5
        9/12/2025, 17 18 21 42 64 + 7
        9/9/2025, 6 43 52 64 65 + 22
        9/5/2025, 6 14 36 58 62 + 24
        9/2/2025, 7 17 35 40 64 + 23
        8/29/2025, 13 31 32 44 45 + 21
        8/26/2025, 7 12 30 40 69 + 17
        8/22/2025, 18 30 44 48 50 + 12
        8/19/2025, 10 19 24 49 68 + 10
        8/15/2025, 4 17 27 34 69 + 16
        8/12/2025, 1 8 31 56 67 + 23
        8/8/2025, 2 6 8 14 49 + 12
        8/5/2025, 12 27 42 59 65 + 2
        8/1/2025, 18 27 29 33 70 + 22
        7/29/2025, 17 30 34 63 67 + 11
        7/25/2025, 14 21 25 49 52 + 7
        7/22/2025, 22 41 42 59 69 + 17
        7/18/2025, 11 43 54 55 63 + 3
        """
    }
}
