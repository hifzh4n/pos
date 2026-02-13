import 'package:flutter/material.dart';
import 'package:pos/screens/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pos/screens/login_screen.dart';
import 'package:pos/theme/app_theme.dart';

const String supabaseUrl = 'https://pvjtymlmuujfscwijcmy.supabase.co';
const String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2anR5bWxtdXVqZnNjd2lqY215Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MDE5ODEsImV4cCI6MjA4NjQ3Nzk4MX0.rIbbBQytAS5XR22N-aD5wPI1BTCfZgNrRFzL-g61jOo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
