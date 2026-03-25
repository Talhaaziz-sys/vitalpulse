# VitalPulse – Implementation Plan

## Overview

**VitalPulse** is a Flutter Life OS that merges daily routine scheduling, atomic habit tracking,
and fitness/bodybuilding logging into a single, cohesive application built with Clean Architecture.

---

## 1. Architecture Overview

```
Feature-First Clean Architecture
├── core/                     # Shared utilities, theme, DB, constants
├── features/
│   ├── routine/              # Routine scheduler feature
│   │   ├── data/             # Models, DAOs, repositories (impl)
│   │   ├── domain/           # Entities, repository contracts, use cases
│   │   └── presentation/     # Screens, widgets, Riverpod providers
│   ├── habits/               # Habit engine feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── fitness/              # Fitness/bodybuilding feature
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/                   # Cross-feature widgets, providers
```

---

## 2. Dependency Analysis

### State Management
| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | Core state management |
| `hooks_riverpod` | ^2.6.1 | Flutter Hooks + Riverpod |
| `flutter_hooks` | ^0.20.5 | React-style hooks |
| `riverpod_annotation` | ^2.6.1 | Code generation annotations |

### Code Generation
| Package | Version | Purpose |
|---|---|---|
| `riverpod_generator` | ^2.4.3 | Generate Riverpod providers |
| `build_runner` | ^2.4.13 | Build system for code gen |
| `freezed` | ^2.5.7 | Immutable data classes |
| `freezed_annotation` | ^2.4.4 | Freezed annotations |
| `json_serializable` | ^6.8.0 | JSON serialization |
| `json_annotation` | ^4.9.0 | JSON annotations |

### Local Storage
| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.3.3+1 | SQLite for offline data |
| `path` | ^1.9.0 | File path utilities |
| `shared_preferences` | ^2.3.3 | Simple key-value storage |

### Fitness / Health Integration
| Package | Version | Purpose |
|---|---|---|
| `health` | ^11.0.0 | Health Connect / Apple Health |

### Navigation
| Package | Version | Purpose |
|---|---|---|
| `go_router` | ^14.6.2 | Declarative routing |

### UI / Charts
| Package | Version | Purpose |
|---|---|---|
| `fl_chart` | ^0.69.0 | Weight progress charts |
| `intl` | ^0.19.0 | Date/number formatting |
| `flutter_svg` | ^2.0.10+1 | SVG icons |
| `google_fonts` | ^6.2.1 | Custom fonts |

### Notifications
| Package | Version | Purpose |
|---|---|---|
| `flutter_local_notifications` | ^17.2.4 | Local push notifications |
| `timezone` | ^0.9.4 | Timezone handling for notifications |

### Utilities
| Package | Version | Purpose |
|---|---|---|
| `uuid` | ^4.5.1 | UUID generation |
| `equatable` | ^2.0.7 | Value equality |

---

## 3. Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── database/
│   │   └── database_helper.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── utils/
│       ├── date_utils.dart
│       └── extensions.dart
├── features/
│   ├── routine/
│   │   ├── data/
│   │   │   ├── models/routine_model.dart
│   │   │   ├── datasources/routine_local_datasource.dart
│   │   │   └── repositories/routine_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/routine_entry.dart
│   │   │   ├── repositories/routine_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_routines_usecase.dart
│   │   │       ├── add_routine_usecase.dart
│   │   │       └── delete_routine_usecase.dart
│   │   └── presentation/
│   │       ├── providers/routine_providers.dart
│   │       ├── screens/routine_screen.dart
│   │       └── widgets/routine_tile.dart
│   ├── habits/
│   │   ├── data/
│   │   │   ├── models/habit_model.dart
│   │   │   ├── datasources/habit_local_datasource.dart
│   │   │   └── repositories/habit_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/habit.dart
│   │   │   ├── entities/habit_log.dart
│   │   │   ├── repositories/habit_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_habits_usecase.dart
│   │   │       ├── add_habit_usecase.dart
│   │   │       ├── complete_habit_usecase.dart
│   │   │       └── calculate_streak_usecase.dart
│   │   └── presentation/
│   │       ├── providers/habit_providers.dart
│   │       ├── screens/habits_screen.dart
│   │       └── widgets/habit_card.dart
│   └── fitness/
│       ├── data/
│       │   ├── models/workout_model.dart
│       │   ├── models/weight_entry_model.dart
│       │   ├── datasources/fitness_local_datasource.dart
│       │   └── repositories/fitness_repository_impl.dart
│       ├── domain/
│       │   ├── entities/workout.dart
│       │   ├── entities/weight_entry.dart
│       │   ├── repositories/fitness_repository.dart
│       │   └── usecases/
│       │       ├── get_workouts_usecase.dart
│       │       ├── log_workout_usecase.dart
│       │       ├── get_weight_entries_usecase.dart
│       │       └── log_weight_usecase.dart
│       └── presentation/
│           ├── providers/fitness_providers.dart
│           ├── screens/fitness_screen.dart
│           └── widgets/
│               ├── workout_log_card.dart
│               └── weight_chart.dart
└── shared/
    ├── widgets/
    │   ├── glass_card.dart
    │   └── app_bottom_nav.dart
    └── providers/
        └── health_provider.dart
```

---

## 4. Database Schema

### `routines` Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT PK | UUID |
| `title` | TEXT | Routine name |
| `description` | TEXT | Details |
| `start_time` | TEXT | ISO 8601 time |
| `end_time` | TEXT | ISO 8601 time |
| `days_of_week` | TEXT | JSON array of day indices |
| `color` | INTEGER | Color value |
| `created_at` | TEXT | ISO 8601 timestamp |

### `habits` Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT PK | UUID |
| `title` | TEXT | Habit name |
| `description` | TEXT | Details |
| `frequency` | TEXT | `daily` or `weekly` |
| `goal` | INTEGER | Target completions per period |
| `color` | INTEGER | Color value |
| `icon` | INTEGER | Icon code point |
| `created_at` | TEXT | ISO 8601 timestamp |

### `habit_logs` Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT PK | UUID |
| `habit_id` | TEXT FK | References `habits.id` |
| `completed_at` | TEXT | ISO 8601 date |
| `note` | TEXT | Optional note |

### `workouts` Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT PK | UUID |
| `exercise_name` | TEXT | Exercise name |
| `sets` | INTEGER | Number of sets |
| `reps` | INTEGER | Reps per set |
| `weight_kg` | REAL | Weight in kg |
| `notes` | TEXT | Optional notes |
| `logged_at` | TEXT | ISO 8601 timestamp |

### `weight_entries` Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT PK | UUID |
| `weight_kg` | REAL | Body weight in kg |
| `logged_at` | TEXT | ISO 8601 date |
| `note` | TEXT | Optional note |

---

## 5. Streak Algorithm

The streak algorithm for habits works as follows:

1. Fetch all `habit_logs` for a given habit, ordered by `completed_at` DESC.
2. Start from today and walk backwards day by day.
3. For each day, check if there is at least one log entry matching that date.
4. Count consecutive days with a log entry — this is the **current streak**.
5. If today has no log entry but yesterday does, the streak is considered intact (grace period).
6. The **longest streak** is computed by scanning all logs for the maximum consecutive sequence.

---

## 6. Glassmorphism Theme

- **Background**: Dark gradient (deep navy `#0D0D2B` to `#1A1A3E`)
- **Cards**: `BackdropFilter` blur + `Color.fromRGBO(255, 255, 255, 0.08)` fill + `1px` white border at 20% opacity
- **Accent**: Electric cyan (`#00D4FF`) and neon purple (`#8A2BE2`)
- **Typography**: `Google Fonts – Nunito` for body, `Raleway` for headings
- **Radius**: 20px for cards, 12px for buttons

---

## 7. Phased Execution

| Phase | Task | Status |
|---|---|---|
| 1 | Implementation Plan | ✅ Done |
| 2 | Scaffolding (pubspec, analysis, folders) | ✅ Done |
| 3 | Core layer (theme, DB, router) | ✅ Done |
| 3 | Routine feature | ✅ Done |
| 3 | Habit feature + streak logic | ✅ Done |
| 3 | Fitness feature (workout + weight) | ✅ Done |
| 4 | Unit tests for streak logic | ✅ Done |
| 4 | Flutter analyze | ✅ Done |
