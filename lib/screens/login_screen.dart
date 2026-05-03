import 'package:flutter/material.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // void _submit() async {
  //   setState(() => _isLoading = true);
  //   final authProvider = AuthProvider();

  //   final success = await authProvider.login(
  //     _emailController.text,
  //     _passwordController.text
  //   );

  //   if (!success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Login failed. Please check credentials.')),
  //     );
  //   }
  //   setState(() => _isLoading = false);
  // }

  void _submit() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
        _emailController.text, _passwordController.text);

    // CRITICAL FIX: Check if the screen is still active before continuing.
    // If login was successful, the AuthProvider has already switched us to the Dashboard.
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login failed. Please check credentials.')),
      );
      // Only turn off the loading spinner if the login FAILED.
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          // color: Colors.white,
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Card(
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Task Manager Login',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                         style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // This is where the background color goes
  ),
                          onPressed: _submit,
                          
                          child: const Text('Login',style: TextStyle(color: Colors.white),),
                        ),
                  const SizedBox(height: 10), // Add this spacing

                  // ADD THIS NEW BUTTON:
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text("Don't have an account? Sign up",style: TextStyle(color: Colors.blue),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
