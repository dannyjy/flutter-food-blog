import 'package:flutter/material.dart';
import 'package:blogfood/screens/login_screen.dart';
import 'package:blogfood/screens/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLogin
        ? LoginScreen(
            onSwitchToSignUp: _toggleAuthMode,
          )
        : SignupScreen(
            onSwitchToLogin: _toggleAuthMode,
          );
  }
}
