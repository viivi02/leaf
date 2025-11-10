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
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      // 🔹 1. Autenticação
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user != null) {
        // 🔹 2. Busca variante A/B
        final variant = await TesteAB.getVariant();

        // 🔹 3. Atualiza Firestore corretamente
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Cria o documento se for o primeiro login
          await userDoc.set({
            'email': user.email,
            'group': variant,
            'ab_group': variant,
            'created_at': FieldValue.serverTimestamp(),
            'last_login': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualiza apenas último login
          await userDoc.update({'last_login': FieldValue.serverTimestamp()});
        }

        // 🔹 4. Loga evento de sucesso
        await EventLogger.logEvent(
          userId: user.uid,
          group: variant,
          action: "login_success",
        );

        // 🔹 5. Navega conforme grupo
        if (variant == "A") {
          Navigator.pushReplacementNamed(context, '/home_a');
        } else {
          Navigator.pushReplacementNamed(context, '/home_b');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao fazer login: ${e.message}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Fundo com gradiente
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Card(
              color: Colors.white.withOpacity(0.1),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Bem-vindo de volta!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo de e-mail
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Campo de senha
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Botão de login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Entrar",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão de cadastro
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Criar conta",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Botão de estatísticas
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/stats');
                      },
                      icon: const Icon(Icons.bar_chart, color: Colors.white70),
                      label: const Text(
                        "Ver Estatísticas",
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
