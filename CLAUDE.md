# Signal NCO EW - Development Guide

## ⚠️ IMPORTANT: Deployment Separation

**This is a SEPARATE app from ew-signalschool!**

| Property | Value |
|----------|-------|
| **App Name** | Signal NCO EW |
| **Repo** | `saisansan11/signal-nco-ew` |
| **Deploy URL** | https://saisansan11.github.io/signal-nco-ew/ |
| **Base Href** | `/signal-nco-ew/` |

### DO NOT:
- ❌ Change base-href to `/ew-signalschool/`
- ❌ Push this code to `ew-signalschool` repo
- ❌ Modify workflow to deploy elsewhere

### Related Apps (DO NOT OVERLAP):
| App | Repo | URL |
|-----|------|-----|
| EW Simulator | ew-signalschool | /ew-signalschool/ |
| **Signal NCO EW** | **signal-nco-ew** | **/signal-nco-ew/** |

---

## Project Overview

แอพฝึกอบรม EW สำหรับนายสิบเหล่าทหารสื่อสาร พร้อมระบบ Gamification

### Features:
- 📚 บทเรียน EW (ESM, ECM, ECCM, Radar, GPS Warfare)
- 🎮 Interactive Simulations
- 🎬 Campaign Mode (5 campaigns, 20+ missions)
- 🎖️ Achievement System (40+ badges)
- 🔊 Sound & Haptic Feedback
- ✨ Celebration Effects

### Tech Stack:
- Flutter Web
- Provider for State Management
- SharedPreferences for Local Storage
- GitHub Pages for Deployment

---

## Development Commands

```bash
# Run locally
cd signal_nco_ew
flutter run -d chrome

# Build for web
flutter build web --release --base-href "/signal-nco-ew/"

# Analyze
flutter analyze

# Push to deploy
git add . && git commit -m "feat: description" && git push origin main
```

---

## File Structure

```
signal_nco_ew/
├── lib/
│   ├── app/           # Theme, constants
│   ├── data/          # Curriculum, quiz, achievement, campaign data
│   ├── models/        # Data models
│   ├── screens/       # UI screens
│   │   ├── home/
│   │   ├── learning/
│   │   ├── interactive/
│   │   ├── quiz/
│   │   ├── campaign/  # Campaign mode
│   │   └── profile/
│   ├── services/      # Business logic
│   │   ├── achievement_service.dart
│   │   ├── campaign_service.dart
│   │   ├── feedback_service.dart
│   │   ├── sound_service.dart
│   │   └── haptic_service.dart
│   └── widgets/
│       ├── achievement_badge_widget.dart
│       ├── effects/   # Celebration widgets
│       └── educational/
├── .github/workflows/deploy.yml
└── .app-identity      # App identification file
```
