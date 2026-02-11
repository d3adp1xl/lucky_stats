<div align="center">
  <img src="icon.png" alt="Lucky Stats Icon" width="120"/>
  
  # Lucky Stats
  
  **Smart Lottery Analysis for Mega Millions**
  
  [![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
  [![Platform](https://img.shields.io/badge/platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
</div>

---

## 📱 About

Lucky Stats is an innovative iOS application that helps lottery players make informed decisions through comprehensive data analysis. By analyzing historical Mega Millions data from 2002 to present, the app provides intelligent number suggestions and statistical insights.

> **Note:** This app is for entertainment and educational purposes. Past lottery results do not predict future outcomes.

## ✨ Features

### 🎯 Smart Number Generation
- AI-powered lucky number generator
- Based on frequency analysis and hot streak data
- Considers historical patterns and pair correlations

### 📊 Comprehensive Analysis
- **Number Frequency**: Track which numbers appear most/least often
- **Bonus Ball Analysis**: Analyze mega ball patterns
- **Number Pairs**: Discover numbers that appear together
- **Hot Streaks**: Identify trending numbers
- **Even/Odd Balance**: See distribution patterns
- **High/Low Analysis**: Track number range patterns
- **Sum Analysis**: Analyze total number sums

### 🎨 Modern Interface
- Sleek black theme design
- Intuitive pagination (Page X of Y)
- Clickable shortcuts for quick insights
- Animated number generation
- Sound effects for enhanced UX

### 📈 Historical Data
- 24+ years of Mega Millions data (2002-present)
- ~1,800+ drawing results
- Real-time data fetching from lottery website
- Smart caching for offline use

## 🚀 Getting Started

### Prerequisites
- macOS 14.0+ (Sonoma or later)
- Xcode 15.0+
- iOS 17.0+ (for running on device/simulator)

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
   - Wait for data to download on first launch (3-5 minutes)

## 🎮 How to Use

### First Launch
1. App shows DEADPIXL splash screen with quote
2. Navigate to **Data** tab
3. Click **"Fetch from lottery website"**
4. Wait for ~1,800 results to download
5. Data is cached for future use

### Generate Lucky Numbers
1. Go to **Dashboard** tab
2. Click **"Generate Your Lucky Numbers"**
3. Get 5 main numbers + 1 bonus number
4. Numbers are based on smart analysis, not random!

### Explore Analysis
1. Go to **Analysis** tab
2. Browse 8 different statistical views
3. Use pagination to explore all data
4. Click **Shortcuts** on Dashboard for quick access

## 🛠️ Tech Stack

- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Architecture**: MVVM
- **Data Source**: data.ny.gov API
- **Storage**: UserDefaults (local caching)
- **Audio**: AVFoundation

## 📂 Project Structure
LotteryAnalyzer/
├── Views/
│   ├── DashboardView.swift      # Main dashboard with generator
│   ├── AnalysisView.swift       # 8 analysis views with pagination
│   ├── DataView.swift           # Data management
│   ├── SplashScreenView.swift   # Startup screen
│   └── ContentView.swift        # Tab navigation
├── ViewModels/
│   └── LotteryViewModel.swift   # Business logic
├── Models/
│   ├── LotteryDraw.swift        # Draw data model
│   └── ...
├── Services/
│   ├── LotteryDataFetcher.swift # API integration
│   ├── FrequencyAnalyzer.swift  # Statistical analysis
│   ├── PairAnalyzer.swift       # Pair correlation
│   └── SoundManager.swift       # Audio playback
└── Resources/
├── Assets.xcassets          # Images and colors
└── Sounds/                  # Sound effects

## 🎵 Sound Effects

The app includes sound effects for enhanced UX:
- **Splash Screen**: Tech startup sound when "DEADPIXL presents" appears
- **Number Generation**: Lucky sound when generating numbers

Add your own MP3 files:
- `deadpixl_intro.mp3` - Splash screen sound
- `lucky_generate.mp3` - Generation sound

## 📊 Data Source

Data fetched from [New York State Open Data Portal](https://data.ny.gov):
- Dataset: Mega Millions Winning Numbers
- Range: February 2010 - Present
- Updates: After each drawing
- Format: JSON via SODA API

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

**This application is for entertainment and educational purposes only.**

- Lottery numbers are generated randomly by official lottery organizations
- Past results do not influence future drawings
- This app cannot predict winning numbers
- Please gamble responsibly
- The developer is not responsible for any financial losses

## 👨‍💻 Author

**d3adp1xl**
- GitHub: [@d3adp1xl](https://github.com/d3adp1xl)

## 🙏 Acknowledgments

- Data provided by New York State Open Data
- Inspired by lottery analysis and data visualization
- Built with SwiftUI and modern iOS development practices

## 📞 Support

If you encounter any issues or have suggestions:
- [Open an issue](https://github.com/d3adp1xl/lucky_stats/issues)
- Star ⭐ the repo if you find it useful!

---

<div align="center">
  Made with ❤️ and Swift
  
  **Good luck! 🍀**
</div>
