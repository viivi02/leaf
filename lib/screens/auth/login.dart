import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaf/component/teste_ab.dart';
import 'package:leaf/component/event_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      // 1️⃣ Tenta autenticar
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user != null) {
        // 2️⃣ Busca a variante A/B do Remote Config
        final variant = await TesteAB.getVariant();

        // 3️⃣ Salva o grupo no Firestore (opcional)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'ab_group': variant,
          'last_login': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 4️⃣ Loga o evento do login
        await EventLogger.logEvent(
          userId: user.uid,
          group: variant,
          action: "login_success",
        );

        // 5️⃣ Redireciona conforme o grupo
        if (variant == "A") {
          Navigator.pushReplacementNamed(context, '/home_a');
        } else {
          Navigator.pushReplacementNamed(context, '/home_b');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _login, child: const Text("Entrar")),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Criar conta"),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/stats');
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text("Ver Estatísticas"),
            ),
          ],
        ),
      ),
    );
  }
}
