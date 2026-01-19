# Flutter Master Blueprint

A professional, "Vanilla" Flutter starter kit designed for scalability and practicality. This blueprint implements a Feature-First MVVM architecture, allowing you to build modular features that depend on a central shared module, without the boilerplate of strict Clean Architecture.

## Key Features

* **Feature-First MVVM:** Code is organized by feature (e.g., features/shared, features/admin). Each feature is self-contained with its own Views and ViewModels.
* **Shared Dependency Module:** A dedicated shared feature handles common logic like Authentication, Profiles, and UI components that other features can depend on.
* **Robust Networking:**
    * **ApiManager:** A centralized HTTP wrapper with standardized error handling.
    * **RepositoryErrorHandler:** Wraps your repository calls to automatically handle socket errors, timeouts, and server exceptions, returning a generic DataState.
* **Scalable Theming:** A dependency-free AppTheme engine using Material 3. Easily expandable for Dark Mode and custom fonts via TextStyles.
* **Standard Routing:** Uses Flutter's native Navigator API via a centralized AppRouter—no 3rd party routing packages required.
* **Asset Management:** Centralized AppAssets class with SVG support and image pre-caching utilities.

## Project Structure

The lib directory is organized to maximize modularity.

* **Core:** Static utilities and constants used everywhere.
* **Features:** The actual app screens and logic.
* **Services:** Global singletons (API, Storage).

```text
lib/
├── core/                   # The backbone (Generic & Static)
│   ├── constants/          # Enums, AppConstants, AppAssets
│   ├── network/            # DataState, RepositoryErrorHandler
│   ├── theme/              # AppTheme, TextStyles
│   └── utils/              # Validators, Extensions
├── features/               # Feature-specific code
│   ├── shared/             # The Core Feature (Auth, Profile, Common Widgets)
│   │   ├── views/
│   │   ├── view_models/
│   │   └── repositories/
│   └── [feature_name]/     # Specific features (e.g. Dashboard, Settings)
├── services/               # Global Singletons (ApiManager)
├── app.dart                # MaterialApp configuration
└── main.dart               # Entry point

```

## Getting Started

### 1. Clone & Rename

Use this blueprint to start a new project. After copying the files, perform a global find-and-replace for the package name:

* Find: package:blueprint
* Replace: package:your_project_name

### 2. Setup Dependencies

This project keeps dependencies minimal. Ensure your pubspec.yaml includes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0          # For networking
  flutter_svg: ^2.0.10  # For scalable vector icons

```

### 3. Run the App

```bash
flutter pub get
flutter run

```

## How to Use

### Architecture Flow

1. **Shared Feature:** Place logic used by multiple roles here (e.g., features/shared/view_models/auth_view_model.dart).
2. **Specific Features:** Create independent modules for specific user roles or major flows. These can import from shared but should not import from each other.

### Networking

Make API calls using the RepositoryErrorHandler to automatically catch errors.

```dart
// Example in features/shared/repositories/auth_repository.dart
Future<DataState<User>> login(Map<String, dynamic> body) {
  return RepositoryErrorHandler.call(
    network: () async {
      final response = await _apiSource.fetchProfile();
      return User.fromJson(response);
    },
    proxyMessage: "Login Failed",
  );
}

```

### Theming & Fonts

To change the font family or colors, simply edit lib/core/theme/text_styles.dart and app_theme.dart.

* **Fonts:** Add your font to assets/fonts/ and pubspec.yaml, then update TextStyles.fontFamily.
* **Colors:** Update the AppTheme static colors. All widgets (Buttons, Inputs, Cards) will automatically reflect the changes.

## License

This project is open-source and free to use for personal and commercial projects.