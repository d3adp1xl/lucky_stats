//
//  HeatmapView.swift
//  LotteryAnalyzer
//
//  Interactive number frequency heatmap with beautiful design
//

import SwiftUI

struct HeatmapView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var selectedTimeRange: TimeRange = .thirtyDays
    @State private var numberType: NumberType = .mainNumbers
    @State private var selectedNumber: Int?
    @State private var showingNumberDetail = false
    @State private var animateGrid = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with controls
                    controlsSection
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(white: 0.15),
                                    Color(white: 0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Heatmap Grid
                    ScrollView {
                        VStack(spacing: 24) {
                            heatmapGrid
                                .padding(.top, 20)
                            
                            legend
                                .padding(.vertical, 20)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNumberDetail) {
                if let number = selectedNumber {
                    NumberDetailSheet(
                        number: number,
                        numberType: numberType,
                        timeRange: selectedTimeRange
                    )
                    .environmentObject(viewModel)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    animateGrid = true
                }
            }
        }
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 20) {
            // Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "map.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Text("Number Heatmap")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.95))
                
                Spacer()
            }
            
            // Time Range Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("TIME RANGE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.5))
                    .tracking(1)
                
                HStack(spacing: 8) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        timeRangeButton(range)
                    }
                }
            }
            
            // Number Type Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("NUMBER TYPE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.5))
                    .tracking(1)
                
                HStack(spacing: 12) {
                    ForEach(NumberType.allCases, id: \.self) { type in
                        numberTypeButton(type)
                    }
                }
            }
        }
    }
    
    private func timeRangeButton(_ range: TimeRange) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTimeRange = range
                animateGrid = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        animateGrid = true
                    }
                }
            }
        }) {
            Text(range.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(selectedTimeRange == range ? .white : Color(white: 0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if selectedTimeRange == range {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(white: 0.15))
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
    
    private func numberTypeButton(_ type: NumberType) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                numberType = type
                animateGrid = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        animateGrid = true
                    }
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: type == .mainNumbers ? "circle.grid.3x3.fill" : "star.fill")
                    .font(.caption)
                
                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(numberType == type ? .white : Color(white: 0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if numberType == type {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(white: 0.15))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Heatmap Grid
    
    private var heatmapGrid: some View {
        let frequencies = calculateFrequencies()
        let maxNumber = numberType == .mainNumbers ? 70 : 25
        let columns = numberType == .mainNumbers ? 10 : 5
        let rows = Int(ceil(Double(maxNumber) / Double(columns)))
        let maxFreq = frequencies.values.max() ?? 1
        
        return VStack(spacing: 10) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<columns, id: \.self) { col in
                        let number = row * columns + col + 1
                        if number <= maxNumber {
                            numberCell(
                                number: number,
                                frequency: frequencies[number] ?? 0,
                                maxFrequency: maxFreq,
                                index: row * columns + col
                            )
                        } else {
                            Color.clear
                                .frame(height: cellSize)
                        }
                    }
                }
            }
        }
    }
    
    private var cellSize: CGFloat {
        numberType == .mainNumbers ? 50 : 65
    }
    
    private func numberCell(number: Int, frequency: Int, maxFrequency: Int, index: Int) -> some View {
        let color = heatColor(frequency: frequency, maxFrequency: maxFrequency)
        let intensity = Double(frequency) / Double(max(maxFrequency, 1))
        
        return Button(action: {
            selectedNumber = number
            showingNumberDetail = true
            SoundManager.shared.playSound("page_turn")
        }) {
            ZStack {
                // Glow effect only for very hot numbers
                if intensity > 0.7 {
                    Circle()
                        .fill(color)
                        .blur(radius: 6)
                        .opacity(0.3)
                }
                
                // Main cell
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color,
                                color.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(intensity > 0.5 ? 0.3 : 0.1),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: intensity > 0.6 ? color.opacity(0.3) : Color.black.opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                
                // Number text
                VStack(spacing: 2) {
                    Text("\(number)")
                        .font(.system(size: numberType == .mainNumbers ? 18 : 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if frequency > 0 {
                        Text("\(frequency)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .frame(height: cellSize)
        .buttonStyle(.plain)
        .scaleEffect(animateGrid ? 1 : 0.8)
        .opacity(animateGrid ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
            .delay(Double(index) * 0.01),
            value: animateGrid
        )
    }
    
    // MARK: - Legend
    
    private var legend: some View {
        VStack(spacing: 16) {
            Text("FREQUENCY LEGEND")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(white: 0.5))
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                legendRow(color: .red, label: "Very Hot", range: "8+ times")
                legendRow(color: .orange, label: "Hot", range: "6-7 times")
                legendRow(color: .yellow, label: "Warm", range: "4-5 times")
                legendRow(color: .green, label: "Neutral", range: "2-3 times")
                legendRow(color: .cyan, label: "Cool", range: "1 time")
                legendRow(color: Color(white: 0.3), label: "Cold", range: "0 times")
            }
            .padding(16)
            .background(Color(white: 0.1))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private func legendRow(color: Color, label: String, range: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 40)
                .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.9))
                
                Text(range)
                    .font(.caption)
                    .foregroundColor(Color(white: 0.6))
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateFrequencies() -> [Int: Int] {
        let allDraws = viewModel.getSelectedDraws() // Use selected draws from Data tab
        let draws = selectedTimeRange.filterDraws(allDraws)
        var frequencies: [Int: Int] = [:]
        
        for draw in draws {
            if numberType == .mainNumbers {
                for number in draw.mainNumbers {
                    frequencies[number, default: 0] += 1
                }
            } else {
                if let bonus = draw.bonusNumber {
                    frequencies[bonus, default: 0] += 1
                }
            }
        }
        
        return frequencies
    }
    
    private func heatColor(frequency: Int, maxFrequency: Int) -> Color {
        let intensity = Double(frequency) / Double(Swift.max(maxFrequency, 1))
        
        if frequency == 0 {
            return Color(white: 0.2)
        } else if intensity >= 0.8 {
            return Color.red
        } else if intensity >= 0.6 {
            return Color.orange
        } else if intensity >= 0.4 {
            return Color.yellow
        } else if intensity >= 0.2 {
            return Color.green
        } else {
            return Color.cyan
        }
    }
}

// MARK: - Supporting Types

extension HeatmapView {
    enum TimeRange: String, CaseIterable {
        case sevenDays = "7 Days"
        case thirtyDays = "30 Days"
        case ninetyDays = "90 Days"
        case oneYear = "1 Year"
        case allTime = "All Time"
        
        func filterDraws(_ draws: [LotteryDraw]) -> [LotteryDraw] {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .sevenDays:
                guard let cutoff = calendar.date(byAdding: .day, value: -7, to: now) else { return draws }
                return draws.filter { $0.date >= cutoff }
            case .thirtyDays:
                guard let cutoff = calendar.date(byAdding: .day, value: -30, to: now) else { return draws }
                return draws.filter { $0.date >= cutoff }
            case .ninetyDays:
                guard let cutoff = calendar.date(byAdding: .day, value: -90, to: now) else { return draws }
                return draws.filter { $0.date >= cutoff }
            case .oneYear:
                guard let cutoff = calendar.date(byAdding: .year, value: -1, to: now) else { return draws }
                return draws.filter { $0.date >= cutoff }
            case .allTime:
                return draws
            }
        }
    }
    
    enum NumberType: String, CaseIterable {
        case mainNumbers = "main"
        case bonusBall = "bonus"
        
        var displayName: String {
            switch self {
            case .mainNumbers: return "Main Numbers (1-70)"
            case .bonusBall: return "Bonus Ball (1-25)"
            }
        }
    }
}

// MARK: - Number Detail Sheet

struct NumberDetailSheet: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.dismiss) var dismiss
    
    let number: Int
    let numberType: HeatmapView.NumberType
    let timeRange: HeatmapView.TimeRange
    
    @State private var frequency: Int = 0
    @State private var lastSeen: String = ""
    @State private var avgGap: Int = 0
    @State private var recentAppearances: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        numberHeader
                        
                        // Stats
                        statsSection
                        
                        // Recent appearances
                        recentAppearancesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Number \(number) Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .task {
                calculateAllStats()
            }
        }
    }
    
    private var numberHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            numberType == .mainNumbers ? Color.blue : Color.orange,
                            numberType == .mainNumbers ? Color.blue.opacity(0.8) : Color.orange.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: (numberType == .mainNumbers ? Color.blue : Color.orange).opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text("\(number)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(numberType == .mainNumbers ? "Main Number" : "Bonus Ball")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.vertical, 30)
        }
        .frame(height: 140)
    }
    
    private var statsSection: some View {
        VStack(spacing: 12) {
            Text("STATISTICS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(white: 0.5))
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Frequency",
                    value: "\(frequency)",
                    subtitle: "times",
                    color: .blue
                )
                
                StatCard(
                    title: "Last Seen",
                    value: lastSeen,
                    subtitle: "",
                    color: .green
                )
                
                StatCard(
                    title: "Avg Gap",
                    value: "\(avgGap)",
                    subtitle: "draws",
                    color: .orange
                )
            }
        }
    }
    
    private var recentAppearancesSection: some View {
        VStack(spacing: 12) {
            Text("RECENT APPEARANCES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(white: 0.5))
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if recentAppearances.isEmpty {
                Text("No appearances in selected time range")
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                ForEach(recentAppearances, id: \.self) { date in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        
                        Text(date)
                            .font(.subheadline)
                            .foregroundColor(Color(white: 0.9))
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(white: 0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private func calculateAllStats() {
        let allDraws = viewModel.getSelectedDraws()
        let draws = timeRange.filterDraws(allDraws)
        var appearances: [LotteryDraw] = []
        
        for draw in draws {
            if numberType == .mainNumbers {
                if draw.mainNumbers.contains(number) {
                    appearances.append(draw)
                }
            } else {
                if draw.bonusNumber == number {
                    appearances.append(draw)
                }
            }
        }
        
        frequency = appearances.count
        
        if let last = appearances.first {
            let days = Calendar.current.dateComponents([.day], from: last.date, to: Date()).day ?? 0
            if days == 0 {
                lastSeen = "Today"
            } else if days == 1 {
                lastSeen = "Yesterday"
            } else {
                lastSeen = "\(days) days ago"
            }
        } else {
            lastSeen = "Never"
        }
        
        if appearances.count > 1 {
            avgGap = draws.count / appearances.count
        } else {
            avgGap = 0
        }
        
        recentAppearances = Array(appearances.prefix(8).map { $0.dateString })
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.6))
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color(white: 0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 85)
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(white: 0.1))
        .cornerRadius(10)
    }
}

// MARK: - Preview

struct HeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        HeatmapView()
            .environmentObject(LotteryViewModel())
            .preferredColorScheme(.dark)
    }
}
