# 🚀 Hackathon Improvements - Integration Guide

## Quick Start

All improvements have been implemented! Here's how to integrate and use them.

---

## 📦 Dependencies Added

The following packages were automatically added:
```yaml
dependencies:
  flutter_animate: ^4.3.0  # For animations
  shimmer: ^3.0.0          # For shimmer effects  
  share_plus: ^12.0.1      # For sharing
  confetti: ^0.7.0         # For celebrations
```

---

## 🔧 Integration Steps

### Step 1: Generate Freezed Files

Run this command to generate required files for the achievement model:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: Update Main App (Optional - For Splash Screen)

To add the splash screen, modify `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/app.dart';

void main() async {
  // ... existing initialization ...
  
  runApp(const SplashWrapper());
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        home: SplashScreen(
          onComplete: () {
            setState(() => _showSplash = false);
          },
        ),
      );
    }
    return const ProviderScope(child: AqiApp());
  }
}
```

### Step 3: Add Achievements to Habits Screen

In `lib/src/features/habits/presentation/habits_screen.dart`, add achievements section:

```dart
import '../../achievements/presentation/widgets/achievement_badge.dart';
import '../../achievements/data/achievements_repository.dart';

// In build method, add:
FutureBuilder(
  future: AchievementsRepository().getAllAchievements(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox.shrink();
    
    final achievements = snapshot.data!;
    return Column(
      children: achievements.map((a) => 
        AchievementBadge(achievement: a)
      ).toList(),
    );
  },
)
```

### Step 4: Add Share Button to Home Screen

In `lib/src/features/aqi/presentation/home_screen.dart`:

```dart
import '../../share/share_service.dart';

// Add share button in AppBar:
IconButton(
  icon: Icon(Icons.share),
  onPressed: () async {
    await ShareService.shareAqiText(
      aqi: state.aqi,
      status: state.status,
      location: state.location,
    );
  },
)
```

### Step 5: Replace Loading Indicators

Replace all `CircularProgressIndicator` with skeleton loaders:

```dart
import '../../../core/widgets/skeleton_loader.dart';

// Instead of:
CircularProgressIndicator()

// Use:
SkeletonCard(height: 150)
```

### Step 6: Use Animated AQI Circle

In `home_screen.dart`, replace static AQI display:

```dart
import '../../../core/widgets/animated_widgets.dart';

// Instead of static Text widget:
AnimatedAqiCircle(
  targetAqi: state.aqi,
  status: state.status,
  color: aqiColor,
  size: 320,
)
```

### Step 7: Add Empty States

Replace empty screens with `EmptyState` widget:

```dart
import '../../../core/widgets/empty_state.dart';

// In chat screen when no messages:
EmptyState(
  icon: Icons.chat_bubble_outline,
  title: 'No conversations yet',
  message: 'Ask me anything about air quality!',
  actionText: 'Get Started',
  onAction: () {
    // Focus on input
  },
  isDarkMode: isDarkMode,
)
```

### Step 8: Enable Demo Mode (Optional)

For demonstrations, enable demo mode:

```dart
import '../../../core/demo/demo_mode_provider.dart';
import '../../chat/data/demo_chat_history.dart';

// In chat screen initState:
final demoMode = ref.read(demoModeProvider);
if (demoMode) {
  setState(() {
    _messages.addAll(DemoChatHistory.demoMessages);
  });
}
```

---

## 🎨 Using New Widgets

### Agent Activity Monitor

Already integrated in `chat_screen.dart`. Shows automatically during query processing.

### Confidence Badges

Already integrated in `chat_screen.dart`. Shows for predictions with confidence scores.

### Achievement Badges

```dart
import 'package:aqi_app/src/features/achievements/presentation/widgets/achievement_badge.dart';
import 'package:aqi_app/src/features/achievements/domain/achievement_model.dart';

AchievementBadge(
  achievement: achievement,
  showProgress: true,
)
```

### Shareable Cards

```dart
import 'package:aqi_app/src/features/share/share_service.dart';

// Create card with GlobalKey
final cardKey = GlobalKey();

RepaintBoundary(
  key: cardKey,
  child: ShareableAqiCard(
    aqi: 87,
    status: 'Moderate',
    location: 'Cracow, Poland',
    color: Colors.orange,
    insight: 'Air quality is moderate today',
  ),
)

// Share the card
await ShareService.shareAqiCard(
  cardKey: cardKey,
  filename: 'my_aqi_card',
);
```

### Skeleton Loaders

```dart
import 'package:aqi_app/src/core/widgets/skeleton_loader.dart';

// Basic loader
SkeletonLoader(
  width: 200,
  height: 20,
  borderRadius: BorderRadius.circular(8),
)

// Card loader
SkeletonCard(
  height: 150,
  padding: EdgeInsets.all(16),
)

// List loader
SkeletonList(
  itemCount: 5,
  itemHeight: 80,
)
```

### Animated Widgets

```dart
import 'package:aqi_app/src/core/widgets/animated_widgets.dart';

// Animated AQI circle
AnimatedAqiCircle(
  targetAqi: 87,
  status: 'Moderate',
  color: Colors.orange,
  size: 320,
)

// Animated counter
AnimatedCounter(
  target: 42,
  style: TextStyle(fontSize: 48),
  duration: Duration(milliseconds: 1500),
)
```

### Empty States

```dart
import 'package:aqi_app/src/core/widgets/empty_state.dart';

EmptyState(
  icon: Icons.inbox,
  title: 'No data yet',
  message: 'Start tracking your air quality to see insights here',
  actionText: 'Get Started',
  onAction: () {
    // Handle action
  },
  isDarkMode: true,
)
```

---

## 🎮 Achievement System

### Initialize Repository

```dart
import 'package:aqi_app/src/features/achievements/data/achievements_repository.dart';

final repo = AchievementsRepository();
await repo.init();
```

### Track Progress

```dart
// When user asks a question
final unlockedAchievement = await repo.updateProgress('first_query', 1);

if (unlockedAchievement != null) {
  // Show celebration dialog
  showDialog(
    context: context,
    builder: (context) => AchievementUnlockDialog(
      achievement: unlockedAchievement,
    ),
  );
}
```

### Get All Achievements

```dart
final achievements = repo.getAllAchievements();
final unlockedCount = repo.getUnlockedCount();
```

---

## 📱 Share Functionality

### Share as Text

```dart
import 'package:aqi_app/src/features/share/share_service.dart';

await ShareService.shareAqiText(
  aqi: 87,
  status: 'Moderate',
  location: 'Cracow, Poland',
);
```

### Share as Image

```dart
// 1. Create card with GlobalKey
final cardKey = GlobalKey();

// 2. Wrap card in RepaintBoundary
RepaintBoundary(
  key: cardKey,
  child: ShareableAqiCard(...),
)

// 3. Share
await ShareService.shareAqiCard(
  cardKey: cardKey,
  filename: 'aqi_card',
);
```

---

## 🎪 Demo Mode

### Enable Demo Mode

```dart
import 'package:aqi_app/src/core/demo/demo_mode_provider.dart';

// In a ConsumerWidget:
ref.read(demoModeProvider.notifier).setDemoMode(true);
```

### Use Demo Data

```dart
import 'package:aqi_app/src/features/chat/data/demo_chat_history.dart';
import 'package:aqi_app/src/features/habits/data/demo_habits.dart';

// Get demo chat messages
final demoMessages = DemoChatHistory.demoMessages;

// Get demo habits
final demoHabits = DemoHabits.demoHabits;
```

### Toggle Demo Mode

```dart
// Add to settings screen
SwitchListTile(
  title: Text('Demo Mode'),
  subtitle: Text('Show pre-populated demo data'),
  value: ref.watch(demoModeProvider),
  onChanged: (_) {
    ref.read(demoModeProvider.notifier).toggleDemoMode();
  },
)
```

---

## 🧪 Testing

### Test Agent Visibility

1. Open chat screen
2. Ask a question
3. Verify agent activity monitor appears
4. Verify agent name shows in response
5. Tap bug icon to see debug screen

### Test Animations

1. Navigate to home screen
2. Verify AQI number counts up
3. Verify pulsing glow effect
4. Refresh and verify skeleton loaders

### Test Achievements

1. Perform actions (ask questions, etc.)
2. Verify progress updates
3. Verify unlock dialog shows
4. Verify confetti animation

### Test Sharing

1. Tap share button
2. Verify card generates
3. Verify share dialog opens
4. Share to any app

### Test Demo Mode

1. Enable demo mode
2. Verify chat history pre-populates
3. Verify habits pre-populate
4. Disable and verify data clears

---

## 🐛 Troubleshooting

### Build Runner Fails

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Freezed Files Missing

Make sure `achievement_model.dart` has:
```dart
part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';
```

Then run build_runner.

### Share Not Working

Ensure `share_plus` is added to `pubspec.yaml` and run:
```bash
flutter pub get
```

### Confetti Not Showing

Ensure `confetti` package is added and imported:
```dart
import 'package:confetti/confetti.dart';
```

### Skeleton Loaders Not Animating

Verify the widget is in the widget tree and has a parent with constraints.

---

## 📚 Additional Resources

### Key Files Reference

**Agent Visibility**:
- `agent_activity_monitor.dart` - Monitor widget
- `agent_debug_screen.dart` - Debug screen
- `chat_screen.dart` - Integration

**Visual Polish**:
- `skeleton_loader.dart` - Loading states
- `animated_widgets.dart` - Animations
- `splash_screen.dart` - Splash screen
- `empty_state.dart` - Empty states

**Gamification**:
- `achievement_model.dart` - Data model
- `achievement_badge.dart` - UI widgets
- `achievements_repository.dart` - Data layer

**Social**:
- `share_service.dart` - Sharing logic

**Demo**:
- `demo_chat_history.dart` - Chat data
- `demo_habits.dart` - Habits data
- `demo_mode_provider.dart` - State management

---

## 🎯 Quick Wins for Demo

### 1. Enable Demo Mode
Pre-populate impressive data for your presentation.

### 2. Show Agent Visibility
Tap bug icon to show judges the multi-agent system.

### 3. Demonstrate Sharing
Generate and share a beautiful AQI card.

### 4. Show Achievements
Display unlocked achievements to show engagement.

### 5. Highlight Animations
Refresh home screen to show counting animation.

---

## ✅ Final Checklist

Before the hackathon:

- [ ] Run `dart run build_runner build`
- [ ] Test all features
- [ ] Enable demo mode
- [ ] Practice demo script
- [ ] Charge devices
- [ ] Take screenshots as backup
- [ ] Test on multiple devices
- [ ] Verify sharing works
- [ ] Check achievement unlocks
- [ ] Test agent visibility

---

## 🏆 You're Ready!

All features are implemented and ready to impress. Follow this guide to integrate them into your app, test thoroughly, and you'll have a hackathon-winning application!

**Good luck! 🚀**
