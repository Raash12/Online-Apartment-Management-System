import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Apartment System',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
