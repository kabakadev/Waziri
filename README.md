# Waziri

**Know your habits. Own your money.**

Waziri is an offline-first, Android-focused personal finance application built with Flutter. It intervenes before the damage is done through intentional behavioral friction (like a "Regret Log" and a "Savings Shield"). Everything lives locally on the device—no backend, no cloud, no auth.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (Android-first)
- **State Management:** Riverpod (with `riverpod_generator`)
- **Database:** `sqflite` (Offline-first)
- **Charts:** `fl_chart`
- **Architecture:** Feature-driven (`lib/features/`, `lib/core/`, `lib/shared/`)

---

## 🚀 Getting Started

Because we use code generation for Riverpod, you **must** generate the `.g.dart` files before the app will run.

1. Clone the repository.
2. Run `flutter pub get`.
3. Run the build runner to generate Riverpod providers:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   _(Note: You must run step 3 every time you pull new code or modify a provider)._

---

## 🤝 Collaboration & Git Flow

We keep source control simple but disciplined to avoid overriding each other's work.

1. **The `main` branch is sacred:** Never commit directly to `main`. It must always be runnable.
2. **Branching:** Create a new branch for your feature off `main` (e.g., `feature/dashboard-ui` or `fix/db-init`).
3. **Pull Requests (PRs):** When you finish a task, open a PR to `main`.
4. **Code Reviews:** We don't merge our own PRs. We review each other's code, approve it, and then merge.
5. **Generated Code:** `*.g.dart` files are in `.gitignore`. **Do not commit them.**

---

## 🏗️ How We Split Work

We divide work by **complete vertical features** (UI + State + DB) rather than horizontal layers. This prevents us from blocking each other.

- **Bad:** Dev A does all Database tables, Dev B does all UI.
- **Good:** Dev A builds the "Add Transaction" flow end-to-end. Dev B builds the "Dashboard" end-to-end.
