<div align="center">
  <img src="icon.png" alt="Lucky Stats Icon" width="120"/>
  
  # Lucky Stats
  
  **Educational Lottery Data Analysis Tool**
  
  [![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
  [![Platform](https://img.shields.io/badge/platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
</div>

---

## ⚠️ Important Disclaimer

**Lucky Stats is for entertainment and educational purposes only.** This app analyzes historical lottery data but does not predict future outcomes, guarantee winning numbers, or improve odds of winning. All lottery drawings are random and independent events.

---

## 📱 About

Lucky Stats is an educational iOS application that helps users explore and analyze historical Mega Millions lottery data. By examining 24 years of drawing history (2002-present), users can learn about statistical patterns, number frequency, and data visualization concepts.

### Educational Focus

This app teaches:
- Statistical analysis concepts
- Data visualization techniques
- Pattern recognition in large datasets
- Historical trend analysis
- Probability and randomness principles

### Not a Prediction Tool

**Important:** Past lottery results do not predict future drawings. This app:
- ❌ Does NOT predict winning numbers
- ❌ Does NOT guarantee lottery wins
- ❌ Does NOT improve odds of winning
- ❌ Does NOT sell lottery tickets
- ✅ ONLY analyzes historical public data

---

## ✨ Features

### 📊 Statistical Analysis Tools
- **Number Frequency Analysis**: Track which numbers appear most/least often in history
- **Bonus Ball Analysis**: Examine mega ball historical patterns
- **Number Pair Analysis**: Discover which numbers appeared together historically
- **Hot Streak Tracking**: Identify numbers with recent appearance clusters
- **Even/Odd Distribution**: Visualize balance patterns over time
- **High/Low Analysis**: Track number range distribution trends
- **Sum Analysis**: Analyze total sum patterns in drawings

### 🎨 User Interface
- Clean, modern dark theme design
- Intuitive pagination for browsing large datasets
- Clickable shortcuts for quick data access
- Animated transitions and visual feedback
- Sound effects for enhanced user experience

### 📈 Historical Data
- 24+ years of Mega Millions data (2002-present)
- Approximately 1,800+ historical drawings
- Real-time data fetching from public sources
- Smart caching for offline functionality
- Data refresh capability

### 🔢 Number Generation Tool
- Generate number combinations based on historical frequency patterns
- Uses statistical analysis of past data
- **Important**: Generated numbers are for educational demonstration only
- No guarantee of winning or improved odds

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0+ (Sonoma or later)
- Xcode 15.0+
- iOS 17.0+ (for device/simulator)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/d3adp1xl/lucky_stats.git
   cd lucky_stats
   ```

2. **Open in Xcode**
   ```bash
   open LotteryAnalyzer.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press ⌘R or click the Play button
   - Accept the disclaimer on first launch
   - Download data from the Data tab (3-5 minutes first time)

---

## 🎮 How to Use

### First Launch
1. App displays disclaimer - read and accept
2. Navigate to **Data** tab
3. Tap **"Fetch from lottery website"**
4. Wait for approximately 1,800 results to download
5. Data is cached locally for future use

### Explore Analysis
1. Go to **Analysis** tab
2. Select any of the 8 analysis types
3. Browse through pages of historical data
4. Use pagination controls to navigate

### Generate Numbers (Educational)
1. Go to **Dashboard** tab
2. Tap **"Generate Your Lucky Numbers"**
3. View numbers generated from historical patterns
4. **Remember**: These are for educational purposes only

### Quick Access Shortcuts
1. Dashboard shows 4 shortcut cards
2. Tap any card to jump to related analysis
3. Cards display current statistics from data

---

## 🛠️ Tech Stack

- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Source**: data.ny.gov Public API
- **Storage**: UserDefaults (local caching)
- **Audio**: AVFoundation (sound effects)

---

## 📂 Project Structure

```
LotteryAnalyzer/
├── Views/
│   ├── ContentView.swift           # Main tab navigation
│   ├── DisclaimerView.swift        # Required disclaimer screen
│   ├── DashboardView.swift         # Home with number generator
│   ├── AnalysisView.swift          # 8 statistical analysis views
│   ├── DataView.swift              # Data management
│   ├── SplashScreenView.swift      # App startup screen
│   └── Components/                 # Reusable UI components
├── ViewModels/
│   └── LotteryViewModel.swift      # Business logic
├── Models/
│   ├── LotteryDraw.swift           # Data models
│   └── AnalysisTypes.swift         # Analysis structures
├── Services/
│   ├── LotteryDataFetcher.swift    # API integration
│   ├── FrequencyAnalyzer.swift     # Statistical analysis
│   ├── PairAnalyzer.swift          # Pair correlation
│   └── SoundManager.swift          # Audio playback
└── Resources/
    ├── Assets.xcassets             # Images and colors
    └── Sounds/                     # Sound effects (if added)
```

---

## 🎵 Sound Effects

The app includes optional sound effects:
- Splash screen: Startup sound
- Number generation: Confirmation sound

To add your own sounds:
1. Add MP3 files to project
2. Name them: `deadpixl_intro.mp3` and `lucky_generate.mp3`
3. Add to Xcode target
4. Rebuild app

---

## 📊 Data Source

**New York State Open Data Portal**
- Dataset: Mega Millions Winning Numbers
- URL: https://data.ny.gov
- Coverage: October 2002 - Present
- Update Frequency: After each drawing
- Format: JSON via SODA API
- License: Public domain

---

## 📜 Legal & Compliance

### Disclaimers

**Educational Purpose:**
This app is designed for entertainment and educational purposes only. It does not predict lottery outcomes or improve odds of winning.

**No Gambling Facilitation:**
This app does not:
- Sell lottery tickets
- Process gambling transactions
- Facilitate betting
- Accept payments for gambling

**Age Requirement:**
Users must be 18+ years old (or legal age in their jurisdiction) to use this app.

**Play Responsibly:**
If you choose to play the lottery, please do so responsibly and within your means.

### Privacy

We respect your privacy:
- ✅ NO personal data collection
- ✅ NO tracking or analytics
- ✅ NO advertising
- ✅ NO account required
- ✅ All data stored locally

See our [Privacy Policy](PRIVACY_POLICY.md) for details.

### Terms of Service

By using this app, you agree to our [Terms of Service](TERMS_OF_SERVICE.md).

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/Enhancement`)
3. Commit your changes (`git commit -m 'Add enhancement'`)
4. Push to the branch (`git push origin feature/Enhancement`)
5. Open a Pull Request

### Contribution Guidelines
- Maintain educational focus
- No gambling promotion
- Keep disclaimers intact
- Follow Swift style guide
- Add tests for new features

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Important Notices

### For Users

**This app does not:**
- Predict future lottery outcomes
- Guarantee winning numbers
- Improve your odds of winning
- Provide financial advice
- Sell lottery tickets

**Lottery Facts:**
- All drawings are random
- Past results don't predict future outcomes
- Each number has equal probability
- Statistical patterns don't improve odds
- This is a game of chance

### For Developers

**App Store Compliance:**
- Disclaimer screen is required
- Age rating: 12+ minimum
- Category: Education or Utilities
- No prediction claims allowed
- Privacy policy required

---

## 👨‍💻 Author

**d3adp1xl**
- GitHub: [@d3adp1xl](https://github.com/d3adp1xl)
- Repository: [lucky_stats](https://github.com/d3adp1xl/lucky_stats)

---

## 🙏 Acknowledgments

- Data provided by New York State Open Data Portal
- Lottery data is public domain
- Built with SwiftUI and modern iOS development practices
- Inspired by statistical analysis and data visualization

---

## 📞 Support

If you encounter any issues:
- [Open an issue](https://github.com/d3adp1xl/lucky_stats/issues)
- Check existing issues for solutions
- Provide detailed bug reports

**For general questions:**
- Read the documentation
- Check the FAQ (coming soon)
- Review closed issues

---

## 🎯 Educational Value

This app demonstrates:
- **Data Analysis**: Working with large datasets
- **Statistical Methods**: Frequency analysis, trend identification
- **SwiftUI Development**: Modern iOS app architecture
- **API Integration**: Fetching and caching remote data
- **User Experience**: Intuitive interface design
- **Data Visualization**: Charts and graphs
- **Responsible Design**: Ethical considerations in app development

---

## 📈 Future Enhancements (Ideas)

Potential educational features:
- Additional lottery games (Powerball, etc.)
- More statistical analysis types
- Data export functionality (CSV, PDF)
- Comparison tools between different time periods
- Advanced visualization options
- Widget support
- Dark/light theme toggle

**Note**: All enhancements maintain educational focus only.

---

## ⚖️ Legal

**Disclaimer:** This is an independent educational project. We are not affiliated with, endorsed by, or connected to Mega Millions, any state lottery organization, or lottery vendors.

**Lottery Trademark:** "Mega Millions" is a registered trademark of the Mega Millions Group.

**App Purpose:** Educational and entertainment only. Does not predict outcomes or improve odds.

---

<div align="center">
  
  **Play Responsibly | For Educational Purposes Only | 18+ Only**
  
  Made with ❤️ and Swift
  
  [Report an Issue](https://github.com/d3adp1xl/lucky_stats/issues) • [Privacy Policy](PRIVACY_POLICY.md) • [Terms of Service](TERMS_OF_SERVICE.md)
  
</div>
