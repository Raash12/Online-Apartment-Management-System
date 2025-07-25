import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'package:frontend/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Apartment System',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // 👈 Make sure LoginScreen is set here
    );
  }
}
