//
//  SplashScreenView.swift
//  LotteryAnalyzer
//

import SwiftUI

struct SplashScreenView: View {
    @State private var showCompanyName = false
    @State private var showPresents = false
    @State private var showQuote = false
    
    let quotes = [
        ("why numbers matter?", "Declare the past, diagnose the present,\nforetell the future.", "— Hippocrates"),
        ("why numbers matter?", "In God we trust.\nAll others must bring data.", "— W. Edwards Deming"),
        ("why numbers matter?", "Without data, you're just another person\nwith an opinion.", "— W. Edwards Deming"),
        ("why numbers matter?", "The plural of anecdote is not data.", "— Roger Brinner"),
        ("why numbers matter?", "Data is the new oil.", "— Clive Humby"),
        ("why numbers matter?", "Statistics are like bikinis.\nWhat they reveal is suggestive,\nbut what they conceal is vital.", "— Aaron Levenstein"),
        ("why numbers matter?", "Facts are stubborn things,\nbut statistics are pliable.", "— Mark Twain"),
        ("why numbers matter?", "The best thing about being a statistician\nis that you get to play in everyone's backyard.", "— John Tukey"),
        ("why numbers matter?", "Not everything that counts can be counted,\nand not everything that can be counted counts.", "— Albert Einstein"),
        ("why numbers matter?", "Correlation doesn't imply causation,\nbut it does waggle its eyebrows suggestively.", "— Randall Munroe")
    ]
    
    @State private var selectedQuote: (String, String, String)?
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if showCompanyName {
                    VStack(spacing: 8) {
                        Text("DEADPIXL")
                            .font(.system(size: 34, weight: .heavy, design: .default))
                            .tracking(4)
                            .foregroundColor(Color(white: 0.85))
                        
                        if showPresents {
                            Text("P R E S E N T S")
                                .font(.system(size: 11, weight: .medium, design: .default))
                                .tracking(6)
                                .foregroundColor(Color(white: 0.5))
                                .opacity(showPresents ? 1 : 0)
                                .onAppear {
                                    // ✅ PLAY SOUND WHEN "PRESENTS" APPEARS
                                    SoundManager.shared.playSound("deadpixl_intro")
                                }
                        }
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                
                if showQuote, let quote = selectedQuote {
                    VStack(alignment: .leading, spacing: 25) {
                        Text(quote.0)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(quote.1)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(white: 0.7))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(quote.2)
                            .font(.system(size: 14, weight: .light, design: .rounded))
                            .foregroundColor(Color(white: 0.5))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            selectedQuote = quotes.randomElement()
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeIn(duration: 0.8)) {
            showCompanyName = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.6)) {
                showPresents = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                showCompanyName = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 1.2)) {
                    showQuote = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            withAnimation(.easeOut(duration: 1.5)) {
                showQuote = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}
