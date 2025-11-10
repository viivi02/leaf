import 'dart:math';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TesteAB {
  static const _keyVariant = 'user_ab_variant';

  static Future<String> getVariant() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔹 Se já tiver uma variante salva localmente, retorna ela
    final savedVariant = prefs.getString(_keyVariant);
    if (savedVariant != null && (savedVariant == "A" || savedVariant == "B")) {
      return savedVariant;
    }

    final remoteConfig = FirebaseRemoteConfig.instance;

    // Configura valores padrão
    await remoteConfig.setDefaults({'ab_variant': 'A'});

    // Configurações de fetch (sem intervalo mínimo durante o desenvolvimento)
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ),
    );

    // Busca valores do servidor
    await remoteConfig.fetchAndActivate();

    // Tenta obter do Remote Config
    String variant = remoteConfig.getString('ab_variant');

    // 🔹 Se o Remote Config não definir, escolhe aleatoriamente
    if (variant != "A" && variant != "B") {
      final random = Random();
      variant = random.nextBool() ? "A" : "B";
    }

    // 🔹 Salva localmente para manter consistência nos próximos logins
    await prefs.setString(_keyVariant, variant);

    return variant;
  }
}
