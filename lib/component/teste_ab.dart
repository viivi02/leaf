import 'package:firebase_remote_config/firebase_remote_config.dart';

class TesteAB {
  static Future<String> getVariant() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Configura valores padrão
    await remoteConfig.setDefaults({
      'ab_variant': 'A', // valor padrão
    });

    // Busca valores do servidor
    await remoteConfig.fetchAndActivate();

    // Lê a variante vinda do console do Firebase
    final variant = remoteConfig.getString('ab_variant');

    // Garante que só retorne "A" ou "B"
    if (variant != "A" && variant != "B") {
      return "A";
    }

    return variant;
  }
}
