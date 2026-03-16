# 🤖 Smart Assistant App

A production-quality Flutter application that simulates a real-world AI assistant experience — featuring paginated suggestions, an animated chat interface, persistent history, and full dark mode support.

---

## 📱 Screens

| Home (Suggestions) | Chat | History |
|---|---|---|
| Paginated suggestion cards with infinite scroll | Animated chat bubbles, typing indicator | Grouped by date, offline-persisted |

---

## 🚀 Setup

### Prerequisites
- Flutter SDK **≥ 3.0.0** ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK **≥ 3.0.0** (bundled with Flutter)
- Android Studio / VS Code with Flutter extension

### Run Locally

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/smart_assistant_app.git
cd smart_assistant_app

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run

# 4. Run tests
flutter test
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/         # App-wide constants (keys, limits, durations)
│   └── theme/             # ThemeData for light & dark modes
│
├── data/
│   ├── models/            # Pure Dart models: Suggestion, ChatMessage, Pagination
│   ├── repositories/      # Business logic layer (SuggestionsRepo, ChatRepo)
│   └── services/          # ApiService (mock/real HTTP), LocalStorageService
│
└── presentation/
    ├── providers/          # ChangeNotifiers: ThemeProvider, SuggestionsProvider, ChatProvider
    ├── screens/            # HomeScreen, ChatScreen, HistoryScreen, MainShell
    └── widgets/            # Reusable: SuggestionCard, ChatBubble, TypingIndicator, skeletons
```

### Design Patterns
- **Repository pattern** — screens never touch services directly
- **Cubit (flutter_bloc)** — lightweight BLoC variant; each feature owns a Cubit + sealed State hierarchy
- **Separation of concerns** — models, repos, services, UI are fully decoupled
- **Dependency injection** — Cubits and repositories accept optional overrides (testable)
- **Equatable states** — all State classes extend `Equatable` so BlocBuilder rebuilds only on real changes

---

## 🔌 API Integration

The app ships with a **real HTTP client** (`ApiService`) that calls all three documented endpoints, plus a **`MockApiService`** subclass for offline development.

### Switch between real and mock

Open `lib/main.dart` and change one line:

```dart
const bool useMock = true;   // ← mock (no backend needed)
const bool useMock = false;  // ← real HTTP calls
```

### Set your base URL

Open `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://YOUR_API_BASE_URL_HERE';
// Android emulator local dev: 'http://10.0.2.2:3000'
// iOS simulator local dev:    'http://localhost:3000'
```

### Endpoints called

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/suggestions?page={page}&limit={limit}` | Paginated suggestions |
| `POST` | `/chat` | Send a message, receive a reply |
| `GET` | `/chat/history` | Fetch remote chat history |

### Error handling

`ApiService` throws typed exceptions — never raw strings:

| Exception | When thrown |
|---|---|
| `NetworkException` | No internet / `SocketException` |
| `ServerException` | HTTP 4xx / 5xx response |
| `ParseException` | Response is not valid JSON or missing fields |
| `ApiException` | Catch-all for unexpected errors |

Cubits catch these and map them to user-friendly state messages.

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc ^8.1.5` | Cubit + BlocBuilder / BlocConsumer / MultiBlocProvider |
| `equatable ^2.0.5` | Value equality for Cubit states (prevents unnecessary rebuilds) |
| `http ^1.2.0` | HTTP client for real API calls |
| `shared_preferences ^2.2.2` | Offline chat history persistence |
| `google_fonts ^6.1.0` | DM Sans + Space Grotesk typography |
| `shimmer ^3.0.0` | Loading skeleton animation |
| `intl ^0.19.0` | Date/time formatting |
| `flutter_animate ^4.5.0` | Declarative animations |

---

## ✅ Feature Checklist

### Core Requirements
- [x] **Home Screen** — paginated suggestions with infinite scroll
- [x] **Chat Screen** — message bubbles, input field, loading indicator
- [x] **History Screen** — previous messages grouped by date
- [x] **State Management** — Provider with ChangeNotifier
- [x] **Pagination** — infinite scroll, load-more indicator, end-of-list state
- [x] **Error Handling** — error states with retry, async/await throughout
- [x] **Navigation** — Bottom navigation bar with IndexedStack (no rebuild)
- [x] **ThemeData** — consistent light theme with reusable styles
- [x] **Widget lifecycle** — proper initState / dispose for controllers

### Bonus Features
- [x] **Dark mode** — full dark theme, toggle persisted via SharedPreferences
- [x] **Offline persistence** — chat history saved to SharedPreferences
- [x] **Typing indicator animation** — bouncing dots when assistant is responding
- [x] **Shimmer skeleton** — loading placeholders for suggestions
- [x] **Unit + Widget tests** — models, providers, and widget rendering

---

## 🧪 Tests

```bash
flutter test
```

Covers:
- `ChatMessage` model serialization / deserialization
- `Suggestion` and `PaginationMeta` parsing
- `SuggestionsProvider` state transitions (initial → loading → success)
- `ChatProvider` send, clear, isSending flag
- `ChatBubble` rendering and timestamp display
- `SuggestionCard` render and tap callback
- `EmptyState` widget render

---

## 📐 Evaluation Criteria Mapping

| Criteria | Implementation |
|---|---|
| Flutter Basics | Stateful/Stateless widgets, CustomScrollView, SliverAppBar, IndexedStack |
| Code Quality | Feature-based folder structure, named constructors, single-responsibility |
| API Handling | async/await in providers, try/catch with error states, loading states |
| State Management | Provider + ChangeNotifier, no business logic in widgets |
| Navigation | Bottom nav with IndexedStack; push navigation for Chat from Home |
| Theming | `AppTheme` class with light/dark `ThemeData`, `GoogleFonts`, CSS-like constants |
| Pagination | Infinite scroll via ScrollController listener, `loadNextPage()` guard |
| UI/UX | Shimmer skeletons, animated typing dots, gradient accents, responsive layout |

---

## 📄 License

MIT
