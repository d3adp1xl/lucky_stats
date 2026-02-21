//
//  HeatmapView.swift
//  LotteryAnalyzer
//

import SwiftUI

// MARK: - HeatmapView

struct HeatmapView: View {
    @EnvironmentObject var viewModel: LotteryViewModel

    @State private var selectedTimeRange: TimeRange = .thirtyDays
    @State private var numberType: NumberType = .mainNumbers
    @State private var selectedSheetItem: NumberSheetItem?
    @State private var animateGrid = false
    @State private var cachedFrequencies: [Int: Int] = [:]
    @State private var cachedMaxFreq: Int = 1

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    controlsSection
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(white: 0.15), Color(white: 0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)

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
            .sheet(item: $selectedSheetItem) { item in
                NumberDetailSheet(
                    number: item.number,
                    numberType: item.numberType,
                    timeRange: item.timeRange
                )
                .environmentObject(viewModel)
            }
            .onAppear {
                refreshFrequencies()
            }
            .onChange(of: selectedTimeRange) { _ in refreshFrequencies() }
            .onChange(of: numberType) { _ in refreshFrequencies() }
        }
    }

    // MARK: - Frequency Cache

    private func refreshFrequencies() {
        animateGrid = false
        let allDraws = viewModel.getSelectedDraws()
        let draws = selectedTimeRange.filterDraws(allDraws)
        let type = numberType

        DispatchQueue.global(qos: .userInitiated).async {
            var freq: [Int: Int] = [:]
            for draw in draws {
                if type == .mainNumbers {
                    for n in draw.mainNumbers { freq[n, default: 0] += 1 }
                } else if let bonus = draw.bonusNumber {
                    freq[bonus, default: 0] += 1
                }
            }
            let maxF = freq.values.max() ?? 1
            DispatchQueue.main.async {
                self.cachedFrequencies = freq
                self.cachedMaxFreq = maxF
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.animateGrid = true
                }
            }
        }
    }

    // MARK: - Controls Section

    private var controlsSection: some View {
        VStack(spacing: 20) {
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
        let maxNumber = numberType == .mainNumbers ? 70 : 25
        let columns = numberType == .mainNumbers ? 10 : 5
        let rows = Int(ceil(Double(maxNumber) / Double(columns)))

        return VStack(spacing: 10) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<columns, id: \.self) { col in
                        let number = row * columns + col + 1
                        if number <= maxNumber {
                            numberCell(
                                number: number,
                                frequency: cachedFrequencies[number] ?? 0,
                                maxFrequency: cachedMaxFreq
                            )
                        } else {
                            Color.clear.frame(height: cellSize)
                        }
                    }
                }
            }
        }
        .drawingGroup()
        .scaleEffect(animateGrid ? 1 : 0.95)
        .opacity(animateGrid ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: animateGrid)
    }

    private var cellSize: CGFloat {
        numberType == .mainNumbers ? 50 : 65
    }

    private func numberCell(number: Int, frequency: Int, maxFrequency: Int) -> some View {
        let color = heatColor(frequency: frequency, maxFrequency: maxFrequency)
        let intensity = Double(frequency) / Double(max(maxFrequency, 1))

        return Button(action: {
            selectedSheetItem = NumberSheetItem(
                number: number,
                numberType: numberType,
                timeRange: selectedTimeRange
            )
            SoundManager.shared.playSound("page_turn")
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                intensity > 0.7 ? color.opacity(0.6) : Color.white.opacity(0.1),
                                lineWidth: intensity > 0.7 ? 2 : 1
                            )
                    )
                    .shadow(color: color.opacity(intensity * 0.35), radius: 3, x: 0, y: 2)

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
                legendRow(color: .red,             label: "Very Hot", range: "8+ times")
                legendRow(color: .orange,           label: "Hot",      range: "6-7 times")
                legendRow(color: .yellow,           label: "Warm",     range: "4-5 times")
                legendRow(color: .green,            label: "Neutral",  range: "2-3 times")
                legendRow(color: .cyan,             label: "Cool",     range: "1 time")
                legendRow(color: Color(white: 0.3), label: "Cold",     range: "0 times")
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

    // MARK: - Helpers

    private func heatColor(frequency: Int, maxFrequency: Int) -> Color {
        let intensity = Double(frequency) / Double(Swift.max(maxFrequency, 1))
        if frequency == 0   { return Color(white: 0.2) }
        if intensity >= 0.8 { return .red }
        if intensity >= 0.6 { return .orange }
        if intensity >= 0.4 { return .yellow }
        if intensity >= 0.2 { return .green }
        return .cyan
    }
}

// MARK: - Supporting Enums

extension HeatmapView {
    enum TimeRange: String, CaseIterable {
        case sevenDays  = "7 Days"
        case thirtyDays = "30 Days"
        case ninetyDays = "90 Days"
        case oneYear    = "1 Year"
        case allTime    = "All Time"

        func filterDraws(_ draws: [LotteryDraw]) -> [LotteryDraw] {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .sevenDays:
                guard let c = calendar.date(byAdding: .day, value: -7, to: now) else { return draws }
                return draws.filter { $0.date >= c }
            case .thirtyDays:
                guard let c = calendar.date(byAdding: .day, value: -30, to: now) else { return draws }
                return draws.filter { $0.date >= c }
            case .ninetyDays:
                guard let c = calendar.date(byAdding: .day, value: -90, to: now) else { return draws }
                return draws.filter { $0.date >= c }
            case .oneYear:
                guard let c = calendar.date(byAdding: .year, value: -1, to: now) else { return draws }
                return draws.filter { $0.date >= c }
            case .allTime:
                return draws
            }
        }
    }

    enum NumberType: String, CaseIterable {
        case mainNumbers = "main"
        case bonusBall   = "bonus"

        var displayName: String {
            switch self {
            case .mainNumbers: return "Main Numbers (1-70)"
            case .bonusBall:   return "Bonus Ball (1-25)"
            }
        }
    }
}

// MARK: - NumberSheetItem
// Declared AFTER the HeatmapView extension so HeatmapView.NumberType
// and HeatmapView.TimeRange are fully resolved before this type is compiled.

struct NumberSheetItem: Identifiable {
    let id = UUID()
    let number: Int
    let numberType: HeatmapView.NumberType
    let timeRange: HeatmapView.TimeRange
}

// MARK: - NumberDetailSheet

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
                        numberHeader
                        statsSection
                        recentAppearancesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Number \(number) Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
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
                .shadow(
                    color: (numberType == .mainNumbers ? Color.blue : Color.orange).opacity(0.3),
                    radius: 8, x: 0, y: 4
                )

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
                StatCard(title: "Frequency", value: "\(frequency)",                    subtitle: "times",  color: .blue)
                StatCard(title: "Last Seen", value: lastSeen.isEmpty ? "—" : lastSeen, subtitle: "",       color: .green)
                StatCard(title: "Avg Gap",   value: "\(avgGap)",                       subtitle: "draws",  color: .orange)
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
                        Image(systemName: "calendar").foregroundColor(.blue)
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
                if draw.mainNumbers.contains(number) { appearances.append(draw) }
            } else {
                if draw.bonusNumber == number { appearances.append(draw) }
            }
        }

        frequency = appearances.count

        if let last = appearances.first {
            let days = Calendar.current.dateComponents([.day], from: last.date, to: Date()).day ?? 0
            lastSeen = days == 0 ? "Today" : days == 1 ? "Yesterday" : "\(days) days ago"
        } else {
            lastSeen = "Never"
        }

        avgGap = appearances.count > 1 ? draws.count / appearances.count : 0
        recentAppearances = Array(appearances.prefix(8).map { $0.dateString })
    }
}

// MARK: - StatCard

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
