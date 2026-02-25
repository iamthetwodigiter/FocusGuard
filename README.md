# FocusGuard — The Ultimate Focus Shield

**"A premium, high-performance focus shield built with Flutter, featuring advanced app/web blocking and a sleek midnight aesthetic for deep productivity."**

FocusGuard is a sophisticated productivity tool designed to help you reclaim your time and achieve peak flow state. It combines robust system-level blocking with a stunning, glassmorphic UI.

## Architecture: MVVM
This project follows a strict **MVVM (Model-View-ViewModel)** architecture using **Riverpod** for state management. 
- **Models**: Plain data classes and Hive objects for persistence.
- **Views**: Declarative UI components that react to state changes.
- **ViewModels (Notifiers)**: Business logic and state management, isolated from the UI.
- **Repositories**: Abstracted data access layers for both local (Hive) and native bridge interactions.

## Features

### Core Productivity
- **🛡️ Elite App Blocking**: System-level interruption of distracting applications.
- **🌐 Web Shield**: Block specific websites across all major Android browsers.
- **⏱️ Deep Work Sessions**: Configurable focus periods with real-time countdowns.
- **🎯 Session Presets**: Rapid-start presets for 15, 25, 45, or 90-minute sprints.

### Dashboard
- Main focus screen with session control
- Real-time blocked apps counter
- Quick preset duration selector
- Service status indicator

### Statistics Screen
- Weekly focus time visualization
- Most blocked apps statistics
- Achievement tracking
- Productivity graphs

### Advanced Settings
- Drawer menu with additional features
- Quick access to whitelist management
- Scheduled focus session editor
- Help and about sections

## Getting Started

### Prerequisites
- Flutter 3.11.0 or higher
- Android device or emulator
- Android SDK 21 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/iamthetwodigiter/FocusGuard.git
   cd FocusGuard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Build and run**
   ```bash
   flutter run
   ```

## Configuration

### Required Permissions
The app requires the following permissions:
- **Accessibility Service**: For app monitoring and blocking
- **Overlay Permission**: To display blocking overlays
- **Settings Access**: To manage device settings

### Setup Steps

1. **Enable Accessibility Service**
   - Go to Settings > Accessibility
   - Find "FocusGuard" and enable it
   - Grant all requested permissions

2. **Grant Overlay Permission**
   - Go to Settings > Apps > Special app access > Display over other apps
   - Enable "FocusGuard"

3. **Select Apps to Block**
   - Open FocusGuard
   - Go to "Block Apps" tab
   - Toggle apps you want to block

4. **Create Focus Sessions**
   - Select focus duration (15, 25, 45, or 90 minutes)
   - Tap "Start Focus Session"
   - Selected apps will be blocked until session ends

## UI/UX Improvements

### Design System
- **Color Palette**: Modern purple, green, and blue accents
- **Typography**: Clear hierarchy with bold headers
- **Spacing**: Generous padding for readability
- **Shadows**: Subtle depth with consistent elevation

### Components
- **Gradient Cards**: Eye-catching gradient backgrounds
- **Status Indicators**: Clear visual feedback
- **Animated Buttons**: Smooth press feedback
- **Info Banners**: Clear instructional messages

### Navigation
- **Bottom Navigation**: Quick access to main features
- **Drawer Menu**: Advanced features and settings
- **Smooth Transitions**: Elegant screen transitions

## Advanced Features Guide

### Using Trusted Apps
1. Open the drawer menu
2. Select "Trusted Apps"
3. Toggle apps to allow during focus
4. These apps won't be blocked even in focus sessions

### Setting Up Schedules
1. Open the drawer menu
2. Select "Scheduled Focus"
3. Create a new rule by setting:
   - Rule name
   - Start and end times
   - Days of the week
4. Enable the rule to activate automatic focus sessions

### Reading Statistics
- **Weekly Chart**: Shows daily focus time trends
- **App Blocking Stats**: Displays most-blocked apps
- **Achievements**: Earn badges for focus streaks
- **Total Stats**: Overall focus statistics

## Development

### Project Structure
```
focusguard/
├── lib/
│   ├── core/
│   │   ├── router/          # Navigation routing
│   │   ├── theme/           # App theming
│   │   ├── constants/       # App constants
│   │   └── widgets/         # Reusable widgets
│   ├── features/
│   │   ├── dashboard/       # Main dashboard
│   │   ├── focus_session/   # Focus feature
│   │   ├── app_selection/   # App blocking
│   │   ├── website_blocking/# Website blocking
│   │   ├── statistics/      # Analytics
│   │   ├── whitelist/       # Trusted apps
│   │   └── scheduling/      # Time-based rules
│   ├── services/            # Native services
│   └── main.dart           # App entry
├── android/                 # Android native code
├── pubspec.yaml            # Dependencies
└── README.md              # This file
```

### Dependencies
- **flutter_riverpod**: State management
- **go_router**: Navigation
- **hive_flutter**: Local storage
- **shared_preferences**: Settings storage
- **flutter_background_service**: Background tasks
- **installed_apps**: Installed apps listing

### Building for Production

```bash
# Build APK
flutter build apk

# Build AAB (for Play Store)
flutter build appbundle

# Release build
flutter build apk --release
```

## Troubleshooting

### Common Issues

**App blocking not working?**
- Ensure accessibility service is enabled
- Grant overlay permission
- Add apps to the blocklist
- Check device battery optimization settings

**Focus session won't start?**
- Verify at least one app is blocked
- Check service status in main screen
- Ensure permissions are granted
- Try restarting the app

**Statistics not showing?**
- Statistics are mock data for now
- Real stats will be collected in future versions
- Check your focus session history

---

## Developer

Developed with passion by **thetwodigiter**. 

Check out more of my work and projects at my portfolio:
👉 **[thetwodigiter.app](https://www.thetwodigiter.app)**

---

**Made with ❤️ to help you stay focused and productive.**
