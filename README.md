# Silent Cache 📝

A minimalist, secure note-taking application built with Flutter, inspired by Obsidian's dark theme and functionality.

## Features

- **Dark-themed Interface**: Sleek, Obsidian-inspired design with dark mode for reduced eye strain
- **Folder Organization**: Organize your notes in customizable folders to maintain structure
- **Markdown Support**: Write notes with markdown formatting for rich text representation
- **Local Storage**: All notes stored locally on your device using SharedPreferences
- **Favorites**: Mark important notes as favorites for quick access

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/silent_cache.git
```

2. Navigate to the project folder
```bash
cd silent_cache
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart               # Entry point
├── models/
│   └── note_model.dart     # Note data model
├── providers/
│   └── note_provider.dart  # State management
├── screens/                
│   └── home_screen.dart    # Main screen
└── widgets/
    └── note_list.dart      # Note list UI component
```

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data persistence
- **uuid**: Unique ID generation
- **timeago**: Relative time formatting

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by Obsidian's design philosophy
- Built with Flutter framework
