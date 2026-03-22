# MindChime

A mindful iOS app that awakens your day with meaningful thoughts and helps you build positive habits.

## Features

### Thoughts Feed
- Curated quotes across 8 categories: Motivation, Stoicism, Mindfulness, Gratitude, Courage, Wisdom, Happiness, and Discipline
- Filter by category, search, and save favorites
- Listen to quotes read aloud with a gentle chime sound first
- Share quotes with friends

### Chime Alarms
- Set alarm-style chimes that play a sound then read you a thought
- Choose which thought categories to wake up to
- Configure repeat days (weekdays, weekends, or custom)
- Preview your chime before saving

### Habit Tracker
- Create daily habits with custom icons and colors
- Track streaks and 30-day completion rates
- Visual daily progress ring
- 7-day mini streak visualization per habit
- Archive completed habit programs

## Tech Stack

- **SwiftUI** — Declarative UI framework
- **SwiftData** — Apple's modern persistence framework
- **MVVM Architecture** — Clean separation of concerns
- **AVFoundation** — Audio playback for chime sounds
- **AVSpeechSynthesizer** — Text-to-speech for reading quotes
- **UserNotifications** — Scheduled alarm notifications
- **iOS 17+** — Latest Apple platform APIs

## Requirements

- Xcode 16+
- iOS 17.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
2. Open `MindChime.xcodeproj` in Xcode
3. Select your target device/simulator
4. Build and run (Cmd + R)

## Architecture

The app follows the **MVVM** (Model-View-ViewModel) pattern:

```
MindChime/
├── App/           — App entry point and configuration
├── Models/        — SwiftData models (Quote, Habit, ChimeAlarm)
├── ViewModels/    — Business logic and state management
├── Views/         — SwiftUI views organized by feature
├── Services/      — Audio, Speech, and Notification services
└── Resources/     — Assets and configuration
```

## License

MIT License
