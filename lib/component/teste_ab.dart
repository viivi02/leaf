import 'dart:math';

class TesteAB {
  static Future<String> getVariant() async {
    return Random().nextBool() ? "A" : "B";
  }
}
