import 'dart:io';

import 'package:vector_math/vector_math.dart';
import 'package:collection/collection.dart';

Future<List<PearlData>> loadFileData({required String fileName}) async {
  List<PearlData> inputData = [];
  await File(fileName).readAsLines().then(
    (List<String> lines) {
      // iterate file line by line
      for (var line in lines) {
        // split line into space separated list of strings
        List<String> currentLineList = line.split(" ");
        if (currentLineList.first == "N") {
          Neighborhood neighborhood = Neighborhood(
            id: currentLineList[1],
            energy: double.parse(currentLineList[2].substring(2)),
            water: double.parse(currentLineList[3].substring(2)),
            resilience: double.parse(currentLineList[4].substring(2)),
          );
          inputData.add(neighborhood);
        } else if (currentLineList.first == "H") {
          Homeowner homeowner = Homeowner(
            id: currentLineList[1],
            energy: double.parse(currentLineList[2].substring(2)),
            water: double.parse(currentLineList[3].substring(2)),
            resilience: double.parse(currentLineList[4].substring(2)),
            preferences: currentLineList[5].split(">"),
          );
          inputData.add(homeowner);
        }
      }
    },
  );
  return inputData;
}

Map<Neighborhood, List<(Homeowner, num)>> distributeHomeowners({
  required List<PearlData> fileData,
}) {
  List<Neighborhood> neighborhoods =
      fileData.whereType<Neighborhood>().toList();
  List<Homeowner> homeowners = fileData.whereType<Homeowner>().toList();
  int maxPerNeighborhood = homeowners.length ~/ neighborhoods.length;
  Map<Neighborhood, List<(Homeowner, num)>> map = {
    for (var n in neighborhoods) n: []
  };
  // sort homeowners by preferences (N0 to Nn)
  homeowners.sort((a, b) {
    return a.preferences.join("").compareTo(b.preferences.join(""));
  });
  for (var h in homeowners) {
    print("${h.id}: ${h.preferences}");
  }

  // loop through each neighborhood
  for (var n in neighborhoods) {
    // possible homeowners for that neighborhood
    List<(Homeowner, num)> nCandidates = [];
    for (var h in homeowners) {
      if (map[n]?.length == maxPerNeighborhood) {
        break;
      }
      if (map.containsValue(h)) {
        continue;
      }
      double score = Vector3(n.energy, n.water, n.resilience)
          .dot(Vector3(h.energy, h.water, h.resilience));
      (Homeowner, num) candidate = (h, score);
      nCandidates.add(candidate);
    }

    print("");
    print("${n.id} nCandidates before sort");
    for (var each in nCandidates) {
      print("${each.$1.id}: ${each.$2} ${each.$1.preferences}");
    }

    nCandidates.sort(Homeowner.compareByPreferences);
    // nCandidates = nCandidates.sublist(0, maxPerNeighborhood);
    print("${n.id} nCandidates after 1st sort");
    for (var each in nCandidates) {
      print("${each.$1.id}: ${each.$2} ${each.$1.preferences}");
    }
    nCandidates.sort((a, b) => b.$2.compareTo(a.$2));
    print("${n.id} nCandidates after 2nd sort");
    for (var each in nCandidates) {
      print("${each.$1.id}: ${each.$2} ${each.$1.preferences}");
    }
    print("");
    var topCandidates = nCandidates.take(maxPerNeighborhood).toList();
    map[n] = topCandidates;
    for (var e in topCandidates) {
      if (homeowners.contains(e.$1)) {
        homeowners.remove(e.$1);
      }
    }
  }
  return map;
}

Map<Neighborhood, List<(Homeowner, num)>> distributeHomeowners2({
  required List<PearlData> fileData,
}) {
  List<Neighborhood> neighborhoods =
      fileData.whereType<Neighborhood>().toList();
  List<Homeowner> homeowners = fileData.whereType<Homeowner>().toList();

  Map<Neighborhood, List<(Homeowner, num)>> map = {};

  print("homeowners before sorting...");
  for (var each in homeowners) {
    print("${each.id}: ${each.preferences}");
  }

  // Sort the homeowners based on their priorities and scores
  homeowners.sort((a, b) {
    int preferencesComparison =
        a.preferences.join("").compareTo(b.preferences.join(""));
    if (preferencesComparison != 0) {
      return preferencesComparison;
    }
    return b
        .calculateDotProduct(neighborhoods.first)
        .compareTo(a.calculateDotProduct(neighborhoods.first));
  });
  print("homeowners after sorting...");
  print(homeowners);

  int homeownersPerNeighborhood = (homeowners.length ~/ neighborhoods.length);

  int currentIndex = 0;

  for (var neighborhood in neighborhoods) {
    List<(Homeowner, num)> homeownersForNeighborhood = [];

    for (int i = 0; i < homeownersPerNeighborhood; i++) {
      homeownersForNeighborhood.add((
        homeowners[currentIndex],
        homeowners[currentIndex].calculateDotProduct(neighborhood)
      ));
      currentIndex++;
    }

    map[neighborhood] = homeownersForNeighborhood;
  }

  return map;
}

void printResult(Map<Neighborhood, List<(Homeowner, num)>> map) {
  print("");
  for (var e in map.entries) {
    List<String> test = [];
    for (var each in e.value) {
      var str = "${each.$1.id}(${each.$2.toInt().toString()})";
      // var str = each.id;
      test.add(str);
    }
    print("${e.key.id}: ${test.join(" ")}\n");
  }
}

class PearlData {
  final String id;
  final double energy;
  final double water;
  final double resilience;

  double calculateDotProduct(Neighborhood neighborhood) {
    return Vector3(energy, water, resilience).dot(
      Vector3(neighborhood.energy, neighborhood.water, neighborhood.resilience),
    );
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

  @override
  String toString() {
    // return "N $id E:$energy W:$water R:$resilience";
    return id;
  }
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

  static int compareByPreferences((Homeowner, num) a, (Homeowner, num) b) {
    return a.$1.preferences.join("").compareTo(b.$1.preferences.join(""));
  }

  @override
  String toString() {
    return "H $id E:$energy W:$water R:$resilience ${preferences.join(">")}";
  }
}
