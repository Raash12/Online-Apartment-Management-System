import 'package:flutter/material.dart';
import 'supabase_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await SupabaseService.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (response.session != null) {
        print("✅ Logged in: ${response.user!.email}");
        // Navigate to home/dashboard if needed
      } else {
        setState(() => _error = "Login failed. Check credentials.");
      }
    } catch (e) {
      setState(() => _error = "Error: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? CircularProgressIndicator() : Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
