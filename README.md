# 💧 Finsight - Personal Finance Companion

## 🚀 Live Demo (APK)

> **📥 Download & Install:** [https://drive.google.com/drive/folders/1PKwy-NNBk2pP8_fH0qem-ykTrj_j8l5G?usp=sharing](#)

---

## 📖 Project Overview

**Finsight** is a privacy-focused, offline-first personal finance application designed to help users track transactions, visualize spending, and build confident financial habits. Engineered without the latency, complex setup, or privacy concerns of a cloud backend, Finsight delivers an instant, highly responsive user experience by processing all data directly on the device.

---

## ✨ Core Features

*   **Offline-First Architecture:** Powered by `sqflite` for instant, network-free data access and uncompromised user privacy.
*   **The 'Magic Seed' Initialization:** Automatically injects 30 days of realistic mock data on the app's first launch, providing a seamless and immediate evaluation experience for reviewers.
*   **Stateless Smart Alert Engine:** Dynamically generates contextual alerts (e.g., Daily Limit Exceeded, 50% Milestone) based on real-time Riverpod state evaluation, accessible via an interactive notification bell.
*   **Interactive Streak Tracking:** A gamified 'No-Spend' streak system to encourage daily saving habits, complete with a contextual drop-down popover for daily budget insights.
*   **Goal Tracking:** A visual, glowing radial progress ring that elegantly tracks monthly savings targets.
*   **Dynamic Theming:** Seamless Light and Dark mode user experiences with modern aesthetics.

---

## 🛠️ Technical Stack

*   **Framework:** Flutter (Dart 3)
*   **State Management:** Riverpod 2.x (Code Generation with `riverpod_generator`)
*   **Local Database:** `sqflite`
*   **Navigation:** `go_router` (utilizing `StatefulShellRoute` for robust bottom-navigation)
*   **Visualizations:** `fl_chart` & `percent_indicator`
*   **Code Generation:** `freezed` & `json_serializable`

---

## 📂 Folder Structure

The application is built using a highly scalable and decoupled **Feature-First** architecture.

```text
lib/
├── core/                   # App-wide configurations, themes, constants, routing
│   ├── database/           # SQLite initialization and tables
│   ├── router/             # GoRouter configuration
│   ├── theme/              # AppColors, TextStyles, and Themes
│   └── utils/              # Global utilities
├── features/               # Independent feature modules
│   ├── auth/               # Biometric lock placeholder
│   ├── dashboard/          # Dashboard screen, widgets, and state
│   ├── insights/           # Analytics, charts, and financial summaries
│   ├── profile/            # User settings, preferences, CSV export
│   └── transactions/       # Transaction repository, providers, listing, and forms
└── shared/                 # Reusable, cross-feature components
    └── widgets/            # Navbars, custom inputs, bottom sheets
```

---

## Technical Perspectives

### Why Local SQLite?
I purposefully chose a local SQLite architecture over a mocked cloud backend. For an assignment focused on UX and state management, an offline-first approach removes network latency, eliminates API key setup requirements for the evaluator, and perfectly demonstrates efficient local data handling, asynchronous initialization, and robust state management.

### Seeing Smart Alerts in Action
The Smart Alert engine evaluates the financial state dynamically without storing alerts in a dedicated database table.
**How to test:**
1.  Navigate to the **Profile** tab.
2.  Set your "Daily Spending Limit" (e.g., `₹500`).
3.  Go to the **Dashboard** and add a new transaction for `₹600`.
4.  Tap the notification bell on the Dashboard—you will immediately see the newly evaluated *Daily Limit Exceeded* contextual alert!

---

## 💻 Setup & Run Instructions

To run this project locally on your machine, ensure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install).

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd finsight
    ```

2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```

3.  *(Optional but Recommended)* **Run code generation:**
    If you plan to modify Riverpod providers or Freezed models, ensure the code generator is up to date:
    ```bash
    dart run build_runner build -d
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```
