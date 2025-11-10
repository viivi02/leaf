import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class EventLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// 🔹 Loga qualquer tipo de evento personalizado
  static Future<void> logEvent({
    required String userId,
    required String group, // variante A ou B
    required String action, // nome do evento (ex: "button_click", "book_added")
    int? durationMs,
    Map<String, dynamic>? extra, // parâmetros adicionais
  }) async {
    final eventData = {
      "userId": userId,
      "group": group,
      "action": action,
      "duration_ms": durationMs ?? 0,
      "timestamp": FieldValue.serverTimestamp(),
      if (extra != null) ...extra, // adiciona parâmetros extras se houver
    };

    // 🔸 Salva no Firestore (útil para auditoria e análise manual)
    await _firestore.collection("ab_events").add(eventData);

    // 🔸 Envia o mesmo evento para o Firebase Analytics
    await _analytics.logEvent(
      name: action,
      parameters: {
        "user_id": userId,
        "variant": group, // renomeado pra "variant" (mais claro no painel)
        "duration_ms": durationMs ?? 0,
        if (extra != null) ...extra,
      },
    );
  }

  /// 🔹 Loga tempo de permanência em uma tela específica
  static Future<void> logScreenDuration({
    required String userId,
    required String group,
    required String screenName,
    required int durationMs,
  }) async {
    await _firestore.collection("ab_events").add({
      "userId": userId,
      "group": group,
      "action": "screen_duration",
      "screen_name": screenName,
      "duration_ms": durationMs,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await _analytics.logEvent(
      name: "screen_duration",
      parameters: {
        "user_id": userId,
        "variant": group,
        "screen_name": screenName,
        "duration_ms": durationMs,
      },
    );
  }
}
