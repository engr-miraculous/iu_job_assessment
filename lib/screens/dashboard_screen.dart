import 'package:flutter/material.dart';

/// Placeholder screens for other tabs
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'), centerTitle: true),
      body: Center(child: Text('Dashboard Screen')),
    );
  }
}
