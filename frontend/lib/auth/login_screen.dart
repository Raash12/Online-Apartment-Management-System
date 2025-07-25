import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/widgets/input_field.dart';
import 'package:frontend/widgets/loading_indicator.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? LoadingIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputField(
                      controller: _emailController,
                      label: "Email",
                    ),
                    SizedBox(height: 16),
                    InputField(
                      controller: _passwordController,
                      label: "Password",
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    CustomButton(
                      text: "Login",
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
