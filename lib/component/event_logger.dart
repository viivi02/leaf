import 'package:cloud_firestore/cloud_firestore.dart';

class EventLogger {
  static Future<void> logEvent({
    required String userId,
    required String group,
    required String action,
    int? durationMs,
  }) async {
    await FirebaseFirestore.instance.collection("ab_events").add({
      "userId": userId,
      "group": group,
      "action": action,
      "duration_ms": durationMs,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
}
