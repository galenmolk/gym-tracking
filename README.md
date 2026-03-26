# GymTracking

A personal iOS app for tracking workouts, exercises, and gym membership costs. Built with SwiftUI and SwiftData — no third-party dependencies.

## Features

### Workout Sessions
- Start/end workouts with a live elapsed time counter
- Add session-level notes (locker number, facility code, etc.)
- View past sessions with full exercise details
- Retroactively add exercises to completed workouts
- Post-workout summary screen

### Exercise Logging
- Searchable exercise library with inline creation during workouts
- Per-set tracking: reps, weight (lbs), up to 20 sets per exercise
- Optional duration tracking (minutes/seconds via wheel picker)
- "Copy Set 1 to All" for quick bulk entry
- Auto-loads previous session data when logging an exercise
- Shows previous session summary (sets, weight, duration, sentiment, notes)

### Sentiment Tracking
- Rate each exercise for next session: **Decrease** / **Maintain** / **Increase**
- Color-coded indicators (orange / blue / green) with SF Symbol icons
- Native liquid glass segmented picker on iOS 26+, custom animated picker on earlier versions
- Haptic feedback on selection

### Exercise Library
- Create exercises with optional notes (e.g., "use wide grip")
- View full history for any exercise: dates, sets, weight, sentiment
- Edit or delete exercises
- Search across all exercises

### Cost Tracking
- Create cost periods (e.g., "Winter 2026 Term", "March Monthly")
- Enter total cost paid for the period
- Auto-calculated **cost per visit** that decreases with every workout
- Sessions are matched by date range automatically
- Edit cost or end a period at any time
- View all sessions within a period

## Data Model

```
Exercise
├── name, notes, createdAt
└── logs: [ExerciseLog]

WorkoutSession
├── startedAt, endedAt, notes
└── exerciseLogs: [ExerciseLog]

ExerciseLog
├── sentiment, notes, durationSeconds, createdAt
├── exercise → Exercise
├── session → WorkoutSession
└── sets: [ExerciseSet]

ExerciseSet
├── setNumber, reps, weight, createdAt
└── exerciseLog → ExerciseLog

CostPeriod
├── name, startDate, endDate, totalCost
└── visits computed from sessions in date range
```

## Requirements

- iOS 17.0+
- Xcode 16+
- No third-party dependencies

## Project Structure

```
GymTracking/
├── GymTrackingApp.swift
├── ContentView.swift
├── Models/
│   ├── SchemaV1.swift
│   ├── SchemaV2.swift
│   ├── GymTrackingSchemaVersions.swift
│   └── Enums/
│       └── Sentiment.swift
├── Views/
│   ├── Session/
│   │   ├── SessionTabView.swift
│   │   ├── ActiveSessionView.swift
│   │   ├── ExerciseLogEntryView.swift
│   │   └── SessionSummaryView.swift
│   ├── Exercises/
│   │   ├── ExerciseLibraryView.swift
│   │   ├── ExerciseDetailView.swift
│   │   └── AddExerciseView.swift
│   ├── History/
│   │   ├── SessionHistoryView.swift
│   │   └── PastSessionDetailView.swift
│   └── Costs/
│       ├── CostPeriodsView.swift
│       ├── CostPeriodDetailView.swift
│       └── AddCostPeriodView.swift
├── Components/
│   ├── ExerciseLogCard.swift
│   ├── SentimentPicker.swift
│   └── TrendRow.swift
└── Utilities/
    └── DateFormatting.swift
```

## Tech Stack

- **SwiftUI** — declarative UI
- **SwiftData** — persistence with versioned schema migrations
- **Zero dependencies** — Apple frameworks only

## Data Persistence

All data is stored locally on-device via SwiftData. There is no cloud sync.

**Important:** Deleting the app from your device deletes all data permanently. If you need to reinstall, use **Settings > General > iPhone Storage > GymTracking > Offload App** instead — this removes the binary but preserves your data.

## Building

```bash
xcodebuild -project GymTracking.xcodeproj \
  -scheme GymTracking \
  -sdk iphonesimulator \
  build
```

Or open `GymTracking.xcodeproj` in Xcode and run.
