import SwiftUI

struct DataView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @State private var currentPage = 1
    let itemsPerPage = 20

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    statsCard
                    drawingsSection
                    if totalPages > 1 {
                        paginationControls
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Data Statistics")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.9))
                Spacer()
            }
            .padding()
            .background(Color(white: 0.15))

            VStack(spacing: 20) {
                statRow(icon: "calendar", title: "Total Drawings  (2002 to present)", value: "\(viewModel.draws.count)", color: .blue)
                Divider().background(Color(white: 0.2))
                statRow(icon: "calendar.badge.clock", title: "Currently Analyzing", value: "\(viewModel.selectedDraws.count) drawings", color: .green)
            }
            .padding(20)
        }
        .background(Color(white: 0.1))
        .cornerRadius(20)
    }

    private func statRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 50)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(white: 0.7))
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.95))
            }
            Spacer()
        }
    }

    // MARK: - Drawings Section

    private var drawingsSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Recent Drawings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.9))
                Spacer()

                // Single toggle button
                Button(action: {
                    if viewModel.selectedDraws.count == viewModel.draws.count {
                        viewModel.deselectAll()
                    } else {
                        viewModel.selectAll()
                    }
                }) {
                    let allSelected = viewModel.selectedDraws.count == viewModel.draws.count
                    Text(allSelected ? "Deselect All" : "Select All")
                        .font(.caption)
                        .foregroundColor(allSelected ? .orange : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(allSelected ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(white: 0.15))

            // Rows
            VStack(spacing: 1) {
                ForEach(paginatedDraws) { draw in
                    drawRow(draw: draw)
                }

                if viewModel.draws.isEmpty {
                    Text("No data available")
                        .foregroundColor(Color(white: 0.5))
                        .padding(40)
                }
            }
        }
        .background(Color(white: 0.1))
        .cornerRadius(20)
    }

    private func drawRow(draw: LotteryDraw) -> some View {
        HStack(spacing: 8) {
            // Checkbox
            Button(action: { viewModel.toggleSelection(draw.id) }) {
                Image(systemName: viewModel.selectedDraws.contains(draw.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.selectedDraws.contains(draw.id) ? .blue : .gray)
                    .font(.body)
            }
            .buttonStyle(.plain)

            // Date
            Text(draw.dateString)
                .font(.caption)
                .foregroundColor(Color(white: 0.7))
                .frame(width: 75, alignment: .leading)

            Spacer()

            // Numbers
            HStack(spacing: 5) {
                ForEach(draw.mainNumbers, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(white: 0.9))
                        .frame(width: 28, height: 28)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(14)
                }

                if let bonus = draw.bonusNumber {
                    Text("+")
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.6))

                    Text("\(bonus)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.orange)
                        .frame(width: 28, height: 28)
                        .background(Color.orange.opacity(0.3))
                        .cornerRadius(14)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(white: 0.08))
    }

    // MARK: - Pagination

    private var totalPages: Int {
        max(1, Int(ceil(Double(viewModel.draws.count) / Double(itemsPerPage))))
    }

    private var paginatedDraws: [LotteryDraw] {
        let start = (currentPage - 1) * itemsPerPage
        let end = min(start + itemsPerPage, viewModel.draws.count)
        guard start < viewModel.draws.count else { return [] }
        return Array(viewModel.draws[start..<end])
    }

    private var paginationControls: some View {
        HStack(spacing: 20) {
            Button(action: {
                if currentPage > 1 {
                    SoundManager.shared.playSound("page_turn")
                    currentPage -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentPage > 1 ? .blue : Color(white: 0.3))
                    .frame(width: 44, height: 44)
                    .background(Color(white: 0.1))
                    .clipShape(Circle())
            }
            .disabled(currentPage <= 1)
            .buttonStyle(.plain)

            Text("Page \(currentPage) of \(totalPages)")
                .font(.headline)
                .foregroundColor(Color(white: 0.9))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(white: 0.1))
                .cornerRadius(20)

            Button(action: {
                if currentPage < totalPages {
                    SoundManager.shared.playSound("page_turn")
                    currentPage += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(currentPage < totalPages ? .blue : Color(white: 0.3))
                    .frame(width: 44, height: 44)
                    .background(Color(white: 0.1))
                    .clipShape(Circle())
            }
            .disabled(currentPage >= totalPages)
            .buttonStyle(.plain)
        }
        .padding(.vertical, 20)
    }
}
