/*
PAGINA DE LOGIN - Biblioteca App

Nesta página um usuário existente pode fazer login no aplicativo com:
- Email
- Senha

Once the user successfully logs in, they will be redirected to the home page.
If user doesn't have an account, they can navigate to the registration page.
*/

import 'package:flutter/material.dart';

import '../component/teste_ab.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  // login button pressed
  void login() async {
    final String email = emailController.text;
    final String pw = pwController.text;

    if (email.isNotEmpty && pw.isNotEmpty) {
      String variant = await TesteAB.getVariant();
      if (!mounted) return;
      debugPrint(variant);
      Navigator.pushReplacementNamed(
        context,
        variant == "A" ? '/home_a' : '/home_b',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pwController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: const Text("Entrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}
