/*
PAGINA DE LOGIN - Biblioteca App

Nesta página um usuário existente pode fazer login no aplicativo com:
- Email
- Senha

Once the user successfully logs in, they will be redirected to the home page.
If user doesn't have an account, they can navigate to the registration page.
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../component/teste_ab.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: pwController.text.trim(),
      );

      // se login ok -> escolhe variante A ou B
      String variant = await TesteAB.getVariant();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        variant == "A" ? '/home_a' : '/home_b',
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
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
              onPressed: login,
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
