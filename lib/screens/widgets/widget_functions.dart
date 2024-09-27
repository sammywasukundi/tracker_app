// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tracker_app/screens/home/pages/forms/expense.dart';

void _navigateToExpenseScreen(BuildContext context) {
  try {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseScreen(),
      ),
    );
  } catch (e) {
    print('Error navigating to ExpenseScreen: $e');
    // Optionally, show a message to the user or log the error
  }
}
