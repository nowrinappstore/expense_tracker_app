import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Transaction types stored in the `type` column.
class TxType {
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const List<String> all = [income, expense];
}

/// Categories shown in the Category dropdown.
const List<String> kIncomeCategories = [
  'Salary',
  'Business',
  'Freelance',
  'Gift',
  'Investment',
  'Other',
];

const List<String> kExpenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Education',
  'Entertainment',
  'Rent',
  'Other',
];

List<String> categoriesFor(String? type) {
  if (type == TxType.income) return kIncomeCategories;
  if (type == TxType.expense) return kExpenseCategories;
  return const [];
}

/// Colors used to tell income and expenses apart.
const Color kIncomeColor = Color(0xFF2E7D32); // green
const Color kExpenseColor = Color(0xFFC62828); // red
const Color kBalanceColor = Color(0xFF283593); // indigo

Color colorForType(String type) =>
    type == TxType.income ? kIncomeColor : kExpenseColor;

IconData iconForCategory(String category) {
  switch (category) {
    case 'Salary':
      return Icons.work_outline;
    case 'Business':
      return Icons.storefront_outlined;
    case 'Freelance':
      return Icons.laptop_mac;
    case 'Gift':
      return Icons.card_giftcard;
    case 'Investment':
      return Icons.trending_up;
    case 'Food':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_bus;
    case 'Shopping':
      return Icons.shopping_bag_outlined;
    case 'Bills':
      return Icons.receipt_long;
    case 'Health':
      return Icons.local_hospital_outlined;
    case 'Education':
      return Icons.school_outlined;
    case 'Entertainment':
      return Icons.movie_outlined;
    case 'Rent':
      return Icons.home_outlined;
    default:
      return Icons.category_outlined;
  }
}

/// Formatting helpers.
const String kCurrency = '৳';

String formatAmount(double amount) =>
    '$kCurrency ${NumberFormat('#,##0.00').format(amount)}';

String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
