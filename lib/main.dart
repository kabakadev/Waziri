import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/database_helper.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  await DatabaseHelper.instance.database;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const WaziriApp(),
    ),
  );
}

class WaziriApp extends StatelessWidget {
  const WaziriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waziri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: Text('Waziri: Know your habits. Own your money.')),
      ),
    );
  }
}
