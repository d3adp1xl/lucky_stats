//
//  LotteryViewModel.swift
//  LotteryAnalyzer
//

import Foundation
import Combine

class LotteryViewModel: ObservableObject {
    
    @Published var draws: [LotteryDraw] = []
    @Published var selectedDraws: Set<UUID> = []
    @Published var currentAnalysis: AnalysisType = .frequency
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let frequencyAnalyzer = FrequencyAnalyzer()
    private let pairAnalyzer = PairAnalyzer()
    private let dataFetcher = LotteryDataFetcher()
    
    // MARK: - Cache for Performance
    private var cachedFrequency: [NumberFrequency]?
    private var cachedLeastCommon: [NumberFrequency]?
    private var cachedBonusFrequency: [NumberFrequency]?
    private var cachedPairs: [NumberPair]?
    private var cacheKey: String = ""
    
    enum AnalysisType: String, CaseIterable {
        case frequency = "Number Frequency"
        case leastCommon = "Least Common"
        case bonus = "Bonus Frequency"
        case pairs = "Number Pairs"
        case streak = "Hot Streaks"
        case evenOdd = "Even/Odd"
        case highLow = "High/Low"
        case sum = "Number Sum"
        
        var icon: String {
            switch self {
            case .frequency: return "chart.bar.fill"
            case .leastCommon: return "chart.bar.xaxis"
            case .bonus: return "star.fill"
            case .pairs: return "link"
            case .streak: return "flame.fill"
            case .evenOdd: return "circle.lefthalf.filled"
            case .highLow: return "arrow.up.arrow.down"
            case .sum: return "plus.forwardslash.minus"
            }
        }
    }
    
    init() {
        loadDefaultData()
        Task {
            await autoFetchData()
        }
    }
    
    private func autoFetchData() async {
        if shouldFetchNewData() {
            print("🔄 Auto-fetching lottery data...")
            await dataFetcher.fetchAllMegaMillionsData()
            
            await MainActor.run {
                if !dataFetcher.fetchedData.isEmpty {
                    loadData(from: dataFetcher.fetchedData)
                    print("✅ Auto-downloaded \(draws.count) lottery draws")
                } else {
                    print("⚠️ No data fetched, using default data")
                }
            }
        } else {
            print("ℹ️ Using existing data (\(draws.count) draws)")
        }
    }
    
    private func shouldFetchNewData() -> Bool {
        return draws.count < 100
    }
    
    func loadDefaultData() {
        isLoading = true
        errorMessage = nil
        
        let parser = DataParser()
        draws = parser.parseText(DataParser.defaultData)
        selectedDraws = Set(draws.map { $0.id })
        
        isLoading = false
    }
    
    func loadData(from text: String) {
        isLoading = true
        errorMessage = nil
        
        let parser = DataParser()
        let newDraws = parser.parseText(text)
        
        if newDraws.isEmpty {
            errorMessage = "No valid lottery data found"
        } else {
            draws = newDraws
            selectedDraws = Set(draws.map { $0.id })
            clearCache() // Clear cache when data changes
        }
        
        isLoading = false
    }
    
    func toggleSelection(_ id: UUID) {
        if selectedDraws.contains(id) {
            selectedDraws.remove(id)
        } else {
            selectedDraws.insert(id)
        }
        clearCache() // Clear cache when selection changes
    }
    
    func selectAll() {
        selectedDraws = Set(draws.map { $0.id })
        clearCache()
    }
    
    func deselectAll() {
        selectedDraws.removeAll()
        clearCache()
    }
    
    func getSelectedDraws() -> [LotteryDraw] {
        return draws.filter { selectedDraws.contains($0.id) }
    }
    
    // MARK: - Cache Management
    
    private func clearCache() {
        cachedFrequency = nil
        cachedLeastCommon = nil
        cachedBonusFrequency = nil
        cachedPairs = nil
        cacheKey = ""
    }
    
    private func getCurrentCacheKey() -> String {
        return selectedDraws.sorted().map { $0.uuidString }.joined()
    }
    
    // MARK: - Cached Analysis Methods
    
    func analyzeFrequency() -> [NumberFrequency] {
        let currentKey = getCurrentCacheKey()
        if let cached = cachedFrequency, cacheKey == currentKey {
            return cached
        }
        
        let selected = getSelectedDraws()
        let result = frequencyAnalyzer.analyzeMainNumbers(selected)
        
        cachedFrequency = result
        cacheKey = currentKey
        return result
    }
    
    func analyzeLeastCommon() -> [NumberFrequency] {
        let currentKey = getCurrentCacheKey()
        if let cached = cachedLeastCommon, cacheKey == currentKey {
            return cached
        }
        
        let selected = getSelectedDraws()
        let allFreqs = frequencyAnalyzer.analyzeMainNumbers(selected)
        let result = allFreqs.sorted { $0.count < $1.count }
        
        cachedLeastCommon = result
        cacheKey = currentKey
        return result
    }
    
    func analyzeBonusFrequency() -> [NumberFrequency] {
        let currentKey = getCurrentCacheKey()
        if let cached = cachedBonusFrequency, cacheKey == currentKey {
            return cached
        }
        
        let selected = getSelectedDraws()
        let result = frequencyAnalyzer.analyzeBonusNumbers(selected)
        
        cachedBonusFrequency = result
        cacheKey = currentKey
        return result
    }
    
    func analyzePairs() -> [NumberPair] {
        let currentKey = getCurrentCacheKey()
        if let cached = cachedPairs, cacheKey == currentKey {
            return cached
        }
        
        let selected = getSelectedDraws()
        let result = pairAnalyzer.analyzeNumberPairs(selected)
        
        cachedPairs = result
        cacheKey = currentKey
        return result
    }
    
    // MARK: - New Hot Streak Analysis
    
    func analyzeHotStreaks() -> [(number: Int, streak: Int, lastAppearances: [String])] {
        let selected = getSelectedDraws().prefix(20) // Last 20 draws
        var numberAppearances: [Int: [String]] = [:]
        
        for draw in selected {
            for number in draw.mainNumbers {
                if numberAppearances[number] == nil {
                    numberAppearances[number] = []
                }
                numberAppearances[number]?.append(draw.dateString)
            }
        }
        
        let streaks = numberAppearances.map { (number: $0.key, streak: $0.value.count, lastAppearances: $0.value) }
        return streaks.sorted { $0.streak > $1.streak }
    }
    
    func calculateStatistics() -> [String: String] {
        let selected = getSelectedDraws()
        guard !selected.isEmpty else { return [:] }
        
        let avgSum = Double(selected.reduce(0) { $0 + $1.sum }) / Double(selected.count)
        let avgEven = Double(selected.reduce(0) { $0 + $1.evenCount }) / Double(selected.count)
        let avgHigh = Double(selected.reduce(0) { $0 + $1.highCount }) / Double(selected.count)
        
        return [
            "Total Draws": "\(selected.count)",
            "Avg Sum": String(format: "%.1f", avgSum),
            "Avg Even": String(format: "%.1f", avgEven),
            "Avg High": String(format: "%.1f", avgHigh)
        ]
    }
}
