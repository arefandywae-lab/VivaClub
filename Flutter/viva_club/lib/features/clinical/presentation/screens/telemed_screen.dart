import 'package:flutter/material.dart';
import 'package:viva_club/core/theme/app_theme.dart';

class TelemedScreen extends StatelessWidget {
  const TelemedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telemed Home')),
      body: const Center(
        child: Text(
          'Telemedicine Features Coming Soon',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      ),
    );
  }
}
