<div align="center">

# P2F — Path2Fitness

**A minimal, AI-powered wellness companion built with Flutter.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-white?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-black?style=flat-square)](releases/p2f.apk)

---

### [⬇ Download APK](https://github.com/soorajsatheesan/p2f/raw/main/releases/p2f.apk)

*Android · v1.0.0 · 54 MB*

</div>

---

## About

P2F is a privacy-first, beautifully minimal fitness app that uses your own OpenAI API key to deliver a personalized AI coaching experience — no subscriptions, no cloud accounts. Everything lives on your device.

Track your weight daily, build unbroken streaks, log your nutrition through photos, and get a personalised motivational push every morning — all wrapped in a strict black-and-white aesthetic.

---

## Features

### 🔥 Streak & Weight Tracking
- Daily weight logging with a **7-day dot calendar** showing your consistency at a glance
- **Streak hero card** with escalating motivational copy — from day 1 through legendary 30+ day milestones
- Smooth line chart built with custom `CustomPainter` showing your last 14 days of progress
- Week-over-week trend badge (↑ / ↓) so you always know your direction

### 🤖 AI Nutrition Logging
- Photograph any meal and let AI identify and estimate macros instantly
- Full nutrition history with daily calorie totals
- Powered by your own OpenAI API key — no third-party data sharing

### 💬 AI Coaching
- Persistent AI coaching assistant aware of your profile, goals, and history
- Ask anything — meal suggestions, workout tips, progress analysis

### ✨ Personalised Daily Push
- Every morning, an AI-generated motivational quote tailored to your name, goal, and current stats
- Refreshable on demand — never stale, always personal

### 📊 Health Dashboard
- BMI tracking with category label
- Total days logged counter
- Streak milestones with visual badges (💪 7+ · ⭐ 14+ · 🏆 30+)

### 🔒 Privacy First
- All data stored locally on-device (SQLite + Secure Storage)
- Your API key never leaves your device
- No accounts, no cloud sync, no tracking

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 / Dart |
| State Management | Riverpod 2 |
| Local Database | SQLite via `sqflite` |
| Secure Storage | `flutter_secure_storage` |
| AI Backend | OpenAI API (user-supplied key) |
| Typography | Space Grotesk + Inter via Google Fonts |
| Image Capture | `image_picker` |

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- An [OpenAI API key](https://platform.openai.com/api-keys)

### Run locally

```bash
# Clone the repo
git clone https://github.com/soorajsatheesan/p2f.git
cd p2f

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Build release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### First launch
1. Enter your OpenAI API key on the login screen — it's stored securely in the device keystore
2. Complete your profile (name, age, height, weight, goals)
3. Start logging your daily weight to kick off your streak

---

## Design System

P2F uses a strictly **monochrome** design language — black background, white foreground, hierarchy achieved through opacity levels. No accent colors except for semantic states (streak amber, trend green/red).

- **Headings** — Space Grotesk (700)
- **Body** — Inter (400/500/600)
- **Corner radii** — 14–20px throughout
- **Motion** — `Cubic(0.16, 1, 0.3, 1)` easing, 300–500ms durations

---

## Project Structure

```
lib/
├── models/          # Data models (UserProfile, WeightEntry, ChatMessage)
├── pages/           # Screens and page-level widgets
│   ├── home/        # Home sections (streak, weight, nutrition, AI, profile)
│   └── login/       # Login flow
├── providers/       # Riverpod state notifiers
├── services/        # API clients, local storage services
├── theme/           # Colors, typography, AppTheme
└── widgets/         # Shared UI components
```

---

## Download

| Platform | Link | Version |
|---|---|---|
| Android (APK) | [p2f.apk](https://github.com/soorajsatheesan/p2f/raw/main/releases/p2f.apk) | v1.0.0 |
| iOS | Build from source | — |

> **Note:** On Android, enable *Install from unknown sources* in Settings before installing the APK.

---

## License

MIT License — Copyright (c) 2025 Sooraj Satheesan

See [LICENSE](LICENSE) for the full text.

---

<div align="center">
Built with focus. No noise.
</div>
