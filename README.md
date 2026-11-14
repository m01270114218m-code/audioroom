# 🥷 AudioRoom Ninja - Next-Gen Social Audio Platform

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)](https://flutter.dev/docs/deployment/android)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

> **AudioRoom Ninja** is a revolutionary social audio platform that combines real-time voice communication with advanced AI features, gamification, and immersive environments. Built with Flutter for seamless cross-platform experience.

## 🌟 Features

### 🎯 Core Features
- **Real-time Audio Rooms** - High-quality voice communication powered by LiveKit
- **Smart Room Discovery** - AI-powered recommendations based on user preferences  
- **Cross-platform Support** - iOS, Android, and Web compatibility
- **Ninja-themed UI** - Sleek dark theme with modern animations

### 🚀 Advanced Features
- **🎭 Voice Effects** - 12+ real-time voice modulation effects (Robot, Echo, Demon, etc.)
- **🏆 Gamification System** - Levels, badges, achievements, and leaderboards
- **🌍 Real-time Translation** - 60+ languages with auto-detection
- **🎨 Virtual Environments** - Immersive themes with ambient soundscapes
- **📊 Advanced Analytics** - Room engagement insights and user statistics
- **🎵 Sound Board** - Interactive sound effects for enhanced conversations

## 🏗️ Architecture

```
audioroom/
├── lib/
│   ├── controllers/          # GetX controllers for state management
│   ├── models/              # Data models and entities
│   ├── screens/             # UI screens and pages
│   ├── services/            # Business logic and API services
│   ├── widgets/             # Reusable UI components
│   └── main.dart           # Application entry point
├── assets/
│   ├── images/             # App icons and graphics
│   ├── sounds/             # Audio files and effects
│   └── animations/         # Lottie animations
└── docs/                   # Project documentation
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.16.0 |
| **State Management** | GetX |
| **Real-time Audio** | LiveKit |
| **Backend Services** | Supabase (Auth, Postgres, Realtime, Storage) |
| **Audio Processing** | Flutter Sound |
| **UI Components** | Material Design 3 |
| **Fonts** | Google Fonts (Orbitron, Rajdhani) |
| **Animations** | Lottie, Custom Animations |
| **Translation** | Google Translate API |
| **Storage** | SharedPreferences |

## 🚀 Quick Start

### Supabase setup

This repository is configured to use the Supabase project URL and client anon key in `lib/config/supabase_config.dart`. This key is intended for client apps; access must be restricted with Row Level Security (RLS). User profiles and wallets are created by the existing `handle_new_auth_user` database trigger.

### Prerequisites
- Flutter SDK (≥3.16.0)
- Dart SDK (≥2.18.6)
- Android Studio / VS Code
- iOS Simulator / Android Emulator
- Supabase project (already configured in `lib/config/supabase_config.dart`)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/audioroom-ninja.git
   cd audioroom-ninja
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Enable Email authentication in Supabase Auth.
   - Keep Row Level Security enabled on all public tables.
   - The app uses the existing profile-creation trigger and `rooms` / `room_members` tables.

4. **Run the application**
   ```bash
   flutter run
   ```

LiveKit voice tokens must be issued by a server-side Edge Function. Do not add the LiveKit API secret to Flutter or commit it to Git.

## 🎮 Gamification System

### Levels & Experience
- **XP System** - Earn points for participation and engagement
- **Level Progression** - Unlock features and rewards as you advance
- **Daily Streaks** - Maintain consecutive activity for bonuses

### Badges & Achievements
| Badge | Requirement | Description |
|-------|-------------|-------------|
| 🥷 Audio Ninja | Join 100 rooms | Master of room exploration |
| 🎤 Great Orator | Speak for 10 hours | Exceptional speaker |
| 🌟 Community Builder | Host 50 rooms | Room creation expert |
| 🧠 Tech Guru | Join 20 tech rooms | Technology enthusiast |
| 🎵 Music Lover | Join 20 music rooms | Music community member |

## 🌍 Localization

AudioRoom Ninja supports 60+ languages with real-time translation:

- **Auto-Detection** - Automatically identify spoken language
- **Real-time Translation** - Instant message translation
- **Language Preferences** - Customize your preferred languages
- **Cultural Adaptation** - Localized content and features

## 🔧 API Documentation

### Room Management
```dart
// Create a new room
await RoomService.createRoom(
  roomName: 'Tech Talk',
  description: 'Discuss latest technology trends'
);

// Join existing room
await RoomService.joinRoom(
  roomName: 'Music Lounge', 
  description: 'Share your favorite music'
);
```

### Voice Effects
```dart
// Apply voice effect
VoiceEffectsService.setVoiceEffect(
  VoiceEffect.robot,
  intensity: 0.7
);

// Play sound effect
await VoiceEffectsService.playSoundEffect(SoundEffect.ninja);
```

### Gamification
```dart
// Track user activity
await GamificationService.trackRoomJoined('music');
await GamificationService.trackSpeakingTime(15);

// Get user stats
final stats = GamificationService.currentUserStats;
print('Level: ${stats.level}, XP: ${stats.experiencePoints}');
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** - Amazing cross-platform framework
- **LiveKit** - Excellent real-time communication SDK
- **Firebase** - Reliable backend services
- **Community Contributors** - Thank you for your valuable contributions!

---

<div align="center">
  <strong>Built with ❤️ by Nandu</strong><br>
  <em>Revolutionizing social audio, one conversation at a time.</em>
</div>
