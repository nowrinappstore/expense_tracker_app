# Expense Tracker (Flutter + Sqflite)

A Personal Expense Tracker built with Flutter for the **Module 20 Assignment**.
Users can add, view, update and delete income/expense transactions. Total income,
total expense and current balance are calculated from the local database and
update instantly.

## Features

| Requirement | Where |
|---|---|
| Dashboard with app name, 3 summary cards, recent transactions, FAB | `lib/screens/dashboard_screen.dart` |
| Add transaction form (Title, Amount, Category dropdown, Type, Date picker, Save) with validation | `lib/screens/add_edit_transaction_screen.dart` |
| Transaction list using `ListView.builder`, green for income / red for expense | `lib/screens/transaction_list_screen.dart`, `lib/widgets/transaction_tile.dart` |
| Update transaction (opens pre-filled form, saves to DB) | `add_edit_transaction_screen.dart` (edit mode) |
| Delete with `AlertDialog`, list + dashboard refresh afterwards | `lib/utils/dialogs.dart` |
| Transaction details with Edit and Delete | `lib/screens/transaction_details_screen.dart` |
| Sqflite local DB: `expense_tracker.db`, table `transactions` | `lib/database/database_helper.dart` |

### Validation rules
- Title cannot be empty
- Amount must be a valid positive number
- Category must be selected
- Transaction type must be selected

### Database schema

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,   -- 'Income' or 'Expense'
  date TEXT NOT NULL    -- ISO-8601
);
```

Data is stored on the device, so it stays after the app is closed and reopened.

## Project structure

```
lib/
├── main.dart
├── database/
│   └── database_helper.dart
├── models/
│   └── transaction_model.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_edit_transaction_screen.dart
│   ├── transaction_list_screen.dart
│   └── transaction_details_screen.dart
├── utils/
│   ├── constants.dart
│   └── dialogs.dart
└── widgets/
    ├── summary_card.dart
    └── transaction_tile.dart
```

## How to run

```bash
# 1. Generate the platform folders (android/, ios/, ...) for this project
flutter create . --project-name expense_tracker --platforms=android,ios

# 2. Install packages
flutter pub get

# 3. Run on an emulator or a connected device
flutter run
```

> Sqflite works on Android and iOS. It does not run on Flutter Web.

## Packages

- [sqflite](https://pub.dev/packages/sqflite) – local SQLite database
- [path](https://pub.dev/packages/path) – building the database file path
- [intl](https://pub.dev/packages/intl) – date and number formatting
