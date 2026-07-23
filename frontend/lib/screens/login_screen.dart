import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  bool isRegistering = false;

  final AuthService authService = AuthService();

  Future<void> login() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submit() async {
    if (isRegistering) {
      if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your name, email, and a password of at least 6 characters.")));
        return;
      }
      setState(() => isLoading = true);
      try {
        await authService.register(nameController.text.trim(), emailController.text.trim(), passwordController.text);
        if (!mounted) return;
        setState(() => isRegistering = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created. Please sign in."), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
      }
      if (mounted) setState(() => isLoading = false);
      return;
    }
    await login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.analytics,
                    color: Colors.blue,
                    size: 80,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Misinformation Dashboard",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isRegistering ? "Create an analyst account" : "Sign in to continue",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  if (isRegistering) ...[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 20),
                  ],

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              isRegistering ? "CREATE ACCOUNT" : "LOGIN",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),

                  TextButton(
                    onPressed: isLoading ? null : () => setState(() => isRegistering = !isRegistering),
                    child: Text(isRegistering ? "Already have an account? Sign in" : "New here? Create an account"),
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
