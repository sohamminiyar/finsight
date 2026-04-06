# Flow - Personal Finance Companion
 
**Platform:** Flutter (iOS & Android)

## Project Overview

Flow is a lightweight, privacy-focused, offline-first personal finance companion application. It is designed to help users track daily transactions, visualize spending patterns, and build better financial habits through a simple streak-based goal system. 

Unlike heavy corporate banking apps, Flow relies entirely on local device storage, ensuring lightning-fast performance, zero network latency, and complete data privacy.

## Core Technologies

* **Framework:** Flutter (SDK 3.35.4 / Dart 3.9.2)
* **Architecture:** Feature-First (Domain-Driven Design concepts)
* **State Management:** `flutter_riverpod` (v2.x with Code Generation)
* **Local Database:** `sqflite` (SQLite)
* **Routing:** `go_router` (using `StatefulShellRoute` for bottom navigation)
* **Data Visualization:** `fl_chart`
* **Model Generation:** `freezed` & `json_serializable`

## User Workflows & Features

* **Initialization (The Magic Seed):** On the first launch, the app bypasses empty states by injecting 30 days of realistic mock transactions into the local SQLite database.
* **Mock Auth / Secure Lock:** A simulated biometric/PIN lock screen demonstrating privacy-first access before routing to the main dashboard.
* **Home Dashboard:** Displays the current balance, total income/expenses for the month, a 7-day spending trend line chart, and recent transaction history.
* **No-Spend Streak Tracker:** A gamified feature that calculates days without logged expenses, displaying a glowing flame icon and streak count on the dashboard.
* **Transaction Management:** Full CRUD capabilities for financial entries, featuring a highly polished, touch-friendly input form and a chronologically grouped history list with swipe-to-delete functionality.
* **Insights & Analytics:** Visual breakdowns of spending habits, including a category pie chart and a week-over-week comparison metric.

## UI/UX & Theming (Airy & Dark Design System)

The app utilizes a custom `ThemeData` configuration supporting both Light and Dark modes.

* **Primary Accent:** Sky Blue (`#38BDF8`)
* **Income Color:** Soft Mint Green (`#34D399`)
* **Expense Color:** Soft Rose (`#FB7185`)
* **Typography:** Inter (via `google_fonts`)
* **Light Mode:** Slate White (`#F8FAFC`) scaffold background with Pure White (`#FFFFFF`) floating cards.
* **Dark Mode:** Deep Charcoal (`#0F172A`) scaffold background with Blue-Grey (`#1E293B`) cards.

## Complete Folder Structure

```text
lib/
├── main.dart
├── core/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── database_tables.dart
│   │   └── database_seeder.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_formatter.dart
│       └── icon_mapper.dart
├── shared/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── empty_state_widget.dart
│       ├── async_value_widget.dart
│       └── scaffold_with_nav_bar.dart
└── features/
    ├── auth/
    │   ├── presentation/
    │   │   └── lock_screen.dart
    │   └── providers/
    │       └── auth_provider.dart
    ├── dashboard/
    │   ├── presentation/
    │   │   ├── dashboard_screen.dart
    │   │   └── widgets/
    │   │       ├── balance_header_card.dart
    │   │       ├── summary_cards_row.dart
    │   │       ├── spending_line_chart.dart
    │   │       ├── recent_transactions_list.dart
    │   │       └── streak_widget.dart
    │   └── providers/
    │       └── dashboard_provider.dart
    ├── transactions/
    │   ├── domain/
    │   │   ├── models/
    │   │   │   ├── transaction_model.dart
    │   │   │   └── category_model.dart
    │   │   ├── enums/
    │   │   │   └── transaction_type.dart
    │   │   └── repositories/
    │   │       └── i_transaction_repository.dart
    │   ├── data/
    │   │   └── repositories/
    │   │       └── sqlite_transaction_repository.dart
    │   ├── providers/
    │   │   ├── transaction_providers.dart
    │   │   └── category_providers.dart
    │   └── presentation/
    │       ├── transaction_list_screen.dart
    │       ├── add_edit_transaction_screen.dart
    │       └── widgets/
    │           ├── transaction_list_item.dart
    │           └── category_chip.dart
    └── insights/
        ├── presentation/
        │   ├── insights_screen.dart
        │   └── widgets/
        │       ├── category_pie_chart.dart
        │       ├── weekly_comparison_bar.dart
        │       └── highest_category_card.dart
        └── providers/
            └── insights_provider.dart


AI Development Guidelines
During development, strictly adhere to the following rules:

Strict Directory Mapping: Do not create new folders outside of this defined architecture. All UI screens must go into their respective features/[name]/presentation/ directories. (If a particular file is missing inside a folder then you can create that & notify the user about the same)

State Management: Use modern Riverpod 2.x @riverpod annotations for all providers. Do not use legacy StateNotifier.

Database Injection: The SQLite database initialization is asynchronous. It must be awaited in main.dart and synchronously injected into a Riverpod override appDatabaseProvider.

Theming: Never hardcode colors or text styles in the UI files. Always use Theme.of(context) or the constants defined in core/theme/.

UI First, Logic Second: When generating components, build the static visual layout first to ensure it matches the design system, then attach the Riverpod providers and models.