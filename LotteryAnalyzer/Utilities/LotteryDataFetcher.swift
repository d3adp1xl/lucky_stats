//
//  LotteryDataFetcher.swift
//  LotteryAnalyzer
//

import Foundation

class LotteryDataFetcher: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0
    @Published var statusMessage: String = ""
    @Published var errorMessage: String?
    @Published var fetchedData: String = ""
    
    private let baseURL = "https://data.ny.gov/resource/5xaw-6ayf.json"
    private let pageSize = 1000
    
    func fetchAllMegaMillionsData() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            fetchedData = ""
            progress = 0.0
            statusMessage = "Starting download..."
        }
        
        print("🌐 Starting Mega Millions data fetch...")
        
        var allResults: [MegaMillionsResult] = []
        var offset = 0
        var hasMore = true
        
        let startDate = "2015-01-01"
        let currentDate = getCurrentDate()
        
        print("📅 Date range: \(startDate) to \(currentDate)")
        
        do {
            await MainActor.run {
                statusMessage = "Downloading data..."
            }
            
            // Simplified approach - just fetch without count first
            while hasMore && offset < 5000 { // Safety limit
                let url = buildSimpleURL(limit: pageSize, offset: offset)
                print("🔗 Fetching: \(url)")
                
                guard let requestURL = URL(string: url) else {
                    print("❌ Invalid URL")
                    await MainActor.run {
                        errorMessage = "Invalid URL"
                        isLoading = false
                    }
                    return
                }
                
                await MainActor.run {
                    statusMessage = "Downloaded \(allResults.count) records..."
                    progress = Double(offset) / 2000.0
                }
                
                let (data, response) = try await URLSession.shared.data(from: requestURL)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No HTTP response")
                    await MainActor.run {
                        errorMessage = "No response from server"
                        isLoading = false
                    }
                    return
                }
                
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 400 {
                    // Try simpler URL without date filter
                    print("⚠️ HTTP 400 - trying simpler query")
                    let simpleURL = "\(baseURL)?$limit=\(pageSize)&$offset=\(offset)&$order=draw_date DESC"
                    print("🔗 Retry URL: \(simpleURL)")
                    
                    guard let retryURL = URL(string: simpleURL) else {
                        await MainActor.run {
                            errorMessage = "Could not create retry URL"
                            isLoading = false
                        }
                        return
                    }
                    
                    let (retryData, retryResponse) = try await URLSession.shared.data(from: retryURL)
                    guard let retryHTTP = retryResponse as? HTTPURLResponse, retryHTTP.statusCode == 200 else {
                        await MainActor.run {
                            errorMessage = "Server error: HTTP 400 - Bad Request"
                            isLoading = false
                        }
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([MegaMillionsResult].self, from: retryData)
                    print("✅ Decoded \(results.count) results (retry)")
                    
                    if results.isEmpty {
                        hasMore = false
                    } else {
                        allResults.append(contentsOf: results)
                        offset += pageSize
                        if results.count < pageSize {
                            hasMore = false
                        }
                    }
                    
                } else if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([MegaMillionsResult].self, from: data)
                    print("✅ Decoded \(results.count) results")
                    
                    if results.isEmpty {
                        hasMore = false
                    } else {
                        allResults.append(contentsOf: results)
                        offset += pageSize
                        if results.count < pageSize {
                            hasMore = false
                        }
                    }
                } else {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    if let responseText = String(data: data, encoding: .utf8) {
                        print("📄 Response: \(responseText.prefix(200))")
                    }
                    await MainActor.run {
                        errorMessage = "Server error: HTTP \(httpResponse.statusCode)"
                        isLoading = false
                    }
                    return
                }
                
                try await Task.sleep(nanoseconds: 500_000_000)
            }
            
            print("🎉 Total fetched: \(allResults.count)")
            
            await MainActor.run {
                statusMessage = "Processing \(allResults.count) records..."
                progress = 0.9
            }
            
            let parsedData = parseAllResults(allResults)
            print("📝 Parsed: \(parsedData.components(separatedBy: "\n").count) lines")
            
            await MainActor.run {
                fetchedData = parsedData
                statusMessage = "Complete! Loaded \(allResults.count) draws"
                progress = 1.0
                isLoading = false
            }
            
        } catch {
            print("❌ Error: \(error)")
            await MainActor.run {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
                progress = 0.0
            }
        }
    }
    
    private func buildSimpleURL(limit: Int, offset: Int) -> String {
        // Simplest possible URL - no date filtering to avoid encoding issues
        return "\(baseURL)?$limit=\(limit)&$offset=\(offset)&$order=draw_date DESC"
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func parseAllResults(_ results: [MegaMillionsResult]) -> String {
        var output = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        // Also try alternate date format
        let alternateDateFormatter = DateFormatter()
        alternateDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M/d/yyyy"
        
        let sortedResults = results.sorted { result1, result2 in
            let date1 = dateFormatter.date(from: result1.draw_date) ?? alternateDateFormatter.date(from: result1.draw_date)
            let date2 = dateFormatter.date(from: result2.draw_date) ?? alternateDateFormatter.date(from: result2.draw_date)
            
            guard let d1 = date1, let d2 = date2 else { return false }
            return d1 > d2
        }
        
        var successCount = 0
        var failCount = 0
        
        for result in sortedResults {
            // Try both date formats
            var date = dateFormatter.date(from: result.draw_date)
            if date == nil {
                date = alternateDateFormatter.date(from: result.draw_date)
            }
            
            guard let validDate = date else {
                print("⚠️ Could not parse date: \(result.draw_date)")
                failCount += 1
                continue
            }
            
            let dateString = outputFormatter.string(from: validDate)
            
            let numberComponents = result.winning_numbers
                .components(separatedBy: " ")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            
            guard numberComponents.count >= 5 else {
                failCount += 1
                continue
            }
            
            let mainNumbers = numberComponents.prefix(5).map { String($0) }.joined(separator: " ")
            
            guard let megaBall = Int(result.mega_ball.trimmingCharacters(in: .whitespaces)) else {
                failCount += 1
                continue
            }
            
            output += "\(dateString), \(mainNumbers) + \(megaBall)\n"
            successCount += 1
        }
        
        print("✅ Parsed: \(successCount), ❌ Failed: \(failCount)")
        
        return output
    }
}

struct MegaMillionsResult: Codable {
    let draw_date: String
    let winning_numbers: String
    let mega_ball: String
}
