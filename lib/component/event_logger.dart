import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class EventLogger {
  static Future<void> logEvent({
    required String userId,
    required String group,
    required String action,
    int? durationMs,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final analytics = FirebaseAnalytics.instance;

    // Salva no Firestore
    await firestore.collection("ab_events").add({
      "userId": userId,
      "group": group,
      "action": action,
      "duration_ms": durationMs,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Envia para o Analytics (para o painel do Firebase)
    await analytics.logEvent(
      name: action,
      parameters: {
        "user_id": userId,
        "group": group,
        "duration_ms": durationMs ?? 0,
      },
    );
  }
}
