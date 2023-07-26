import 'package:vector_math/vector_math.dart';

class PearlData {
  final String id;
  final int energy;
  final int water;
  final int resilience;

  int calculateDotProduct(PearlData other) {
    return Vector3(
      energy.toDouble(),
      water.toDouble(),
      resilience.toDouble(),
    )
        .dot(
          Vector3(
            other.energy.toDouble(),
            other.water.toDouble(),
            other.resilience.toDouble(),
          ),
        )
        .ceil();
  }

  PearlData({
    required this.id,
    required this.energy,
    required this.water,
    required this.resilience,
  });
}

class Neighborhood extends PearlData {
  Neighborhood({
    required super.id,
    required super.energy,
    required super.water,
    required super.resilience,
  });
}

class Homeowner extends PearlData {
  final List<String> preferences;
  Homeowner({
    required this.preferences,
    required super.id,
    required super.energy,
    required super.water,
    required super.resilience,
  });

  static int compareByPreferences((Homeowner, int) a, (Homeowner, int) b) {
    return a.$1.preferences.join("").compareTo(b.$1.preferences.join(""));
  }

  @override
  String toString() {
    return "H $id E:$energy W:$water R:$resilience ${preferences.join(">")}";
  }
}
