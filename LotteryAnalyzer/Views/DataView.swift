//
//  DataView.swift
//  LotteryAnalyzer
//

import SwiftUI

struct DataView: View {
    
    @EnvironmentObject var viewModel: LotteryViewModel
    @StateObject private var fetcher = LotteryDataFetcher()
    @State private var showingDataInput = false
    @State private var showingFetchOptions = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                fetchDataButton
                
                if !viewModel.draws.isEmpty {
                    selectionControls
                }
                
                drawsList
            }
            .navigationTitle("Lottery Data")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingDataInput) {
                DataInputView()
            }
            .sheet(isPresented: $showingFetchOptions) {
                FetchOptionsView(fetcher: fetcher)
            }
            .onChange(of: fetcher.fetchedData) { _, newValue in
                if !newValue.isEmpty {
                    viewModel.loadData(from: newValue)
                    showingFetchOptions = false
                }
            }
        }
    }
    
    private var fetchDataButton: some View {
        Button(action: {
            showingFetchOptions = true
        }) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fetch from Lottery Website")
                        .font(.headline)
                    Text("Download latest Mega Millions results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var selectionControls: some View {
        HStack {
            Button("Select All") {
                viewModel.selectAll()
            }
            .buttonStyle(.bordered)
            
            Button("Deselect All") {
                viewModel.deselectAll()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Text("\(viewModel.selectedDraws.count) selected")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
    
    private var addButton: some View {
        Button(action: {
            showingDataInput = true
        }) {
            Image(systemName: "plus")
        }
    }
    
    private var drawsList: some View {
        List {
            ForEach(viewModel.draws) { draw in
                DrawSelectionRow(draw: draw)
            }
        }
        .listStyle(.plain)
    }
}

struct FetchOptionsView: View {
    @ObservedObject var fetcher: LotteryDataFetcher
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if fetcher.isLoading {
                    loadingView
                } else {
                    optionsView
                }
            }
            .padding()
            .navigationTitle("Fetch Lottery Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(fetcher.isLoading)
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView(value: fetcher.progress)
                .progressViewStyle(.linear)
                .frame(width: 250)
            
            Text(fetcher.statusMessage)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.center)
            
            Text("\(Int(fetcher.progress * 100))% complete")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Please wait, this may take 1-2 minutes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var optionsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "network")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Mega Millions")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Download all available draw results")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 15) {
                InfoCard(
                    icon: "calendar",
                    title: "Date Range",
                    value: "2002 - Present",
                    color: .blue
                )
                
                InfoCard(
                    icon: "number",
                    title: "Estimated Records",
                    value: "~1,000+ draws",
                    color: .green
                )
                
                InfoCard(
                    icon: "clock",
                    title: "Download Time",
                    value: "1-2 minutes",
                    color: .orange
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                Task {
                    await fetcher.fetchAllMegaMillionsData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title2)
                    
                    Text("Download All Data")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if let error = fetcher.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 4) {
                Text("Data source: New York State Open Data")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Official Mega Millions draw results")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 20)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct DrawSelectionRow: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    let draw: LotteryDraw
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                viewModel.toggleSelection(draw.id)
            }) {
                Image(systemName: viewModel.selectedDraws.contains(draw.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.selectedDraws.contains(draw.id) ? .blue : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(draw.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    ForEach(draw.mainNumbers, id: \.self) { number in
                        Text("\(number)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 28, height: 28)
                            .background(colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2))
                            .cornerRadius(14)
                    }
                    
                    if let bonus = draw.bonusNumber {
                        Text("+")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(bonus)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? Color.orange : Color.orange.opacity(0.9))
                            .frame(width: 28, height: 28)
                            .background(colorScheme == .dark ? Color.orange.opacity(0.3) : Color.orange.opacity(0.2))
                            .cornerRadius(14)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct DataInputView: View {
    @EnvironmentObject var viewModel: LotteryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var inputText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                instructionsSection
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                
                actionButtons
            }
            .navigationTitle("Enter Lottery Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Load Default") {
                        inputText = DataParser.defaultData
                    }
                }
            }
        }
        .onAppear {
            if !viewModel.draws.isEmpty {
                inputText = viewModel.draws.map { draw in
                    "\(draw.dateString), \(draw.originalString)"
                }.joined(separator: "\n")
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Format Instructions")
                .font(.headline)
            
            Text("Enter one draw per line:")
                .font(.caption)
            
            Text("10/28/2025, 2 19 33 53 61 + 14")
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    private var actionButtons: some View {
        HStack(spacing: 15) {
            Button("Clear") {
                inputText = ""
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button("Save Data") {
                viewModel.loadData(from: inputText)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.isEmpty)
        }
        .padding()
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
            .environmentObject(LotteryViewModel())
    }
}
