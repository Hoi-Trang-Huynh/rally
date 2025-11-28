# rally

A new Flutter project.

## Development Setup

### Prerequisites
1.  **Flutter SDK**: Ensure you have the Flutter SDK installed and configured.
2.  **VS Code**: Recommended IDE with the official Dart and Flutter extensions.

### Initial Configuration
1.  **Firebase Login**:
    Run the following command to log in to Firebase:
    ```bash
    flutterfire login
    ```
    *Note: This is required to access the Firebase project.*

2.  **Configure Firebase**:
    Run the following command to configure the app with Firebase:
    ```bash
    flutterfire configure
    ```
    *Important: When prompted "The project has already configured with a firebase.json...", select **Yes** to use the existing configuration.*

3.  **Generate Localization**:
    Run the VS Code task: **Terminal -> Run Task -> flutter gen-l10n**
    Or manually:
    ```bash
    flutter gen-l10n
    ```

### Running the App
- Open `lib/main.dart` and press **F5** (or go to Run and Debug) to start the app.
- Use the **VS Code Tasks** for common operations like `flutter pub get` or `flutter gen-l10n`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
