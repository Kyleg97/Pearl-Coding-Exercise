import 'dart:io';

import 'package:vector_math/vector_math.dart';
import 'package:collection/collection.dart';

Future<List<LineData>> loadFileData({required String fileName}) async {
  List<LineData> inputData = [];
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

Map<Neighborhood, List<(Homeowner, num)>> computeScores(
    {required List<LineData> fileData}) {
  List<Neighborhood> neighborhoods =
      fileData.whereType<Neighborhood>().toList();
  List<Homeowner> homeowners = fileData.whereType<Homeowner>().toList();
  for (var each in homeowners) {
    print(each.preferences);
  }
  int maxPerNeighborhood = homeowners.length ~/ neighborhoods.length;
  Map<Neighborhood, List<(Homeowner, num)>> map = {
    for (var n in neighborhoods) n: []
  };
  print("--------");
  homeowners.sort(Homeowner.compareByPreferences);
  for (var each in homeowners) {
    print("${each.id}: ${each.preferences}");
  }
  for (var n in neighborhoods) {
    List<(Homeowner, num)> nCandidates = [];
    for (var h in homeowners) {
      if (map.containsValue(h)) {
        continue;
      }
      if (map[n]?.length == maxPerNeighborhood) {
        break;
      }
      if (h.preferences.first != n.id && map[n]?.length != maxPerNeighborhood) {
        continue;
      }
      double score = Vector3(n.energy, n.water, n.resilience)
          .dot(Vector3(h.energy, h.water, h.resilience));
      // print("${h.id} score: $score for neighborhood ${n.id}");
      // print(
      //     "values used for h=>  E:${h.energy} W:${h.water} R:${h.resilience}");
      // print(
      //     "values used for n=>  E:${n.energy} W:${n.water} R:${n.resilience}");
      (Homeowner, num) candidate = (h, score);
      nCandidates.add(candidate);
    }
    nCandidates.sort((a, b) => b.$2.compareTo(a.$2));
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

void printResult(Map<Neighborhood, List<(Homeowner, num)>> map) {
  print("");
  for (var e in map.entries) {
    List<String> test = [];
    for (var each in e.value) {
      var str = "${each.$1.id}(${each.$2.toInt().toString()})";
      test.add(str);
    }
    print("${e.key.id}: ${test.join(" ")}\n");
  }
}

class LineData {
  final String id;
  final double energy;
  final double water;
  final double resilience;

  LineData({
    required this.id,
    required this.energy,
    required this.water,
    required this.resilience,
  });
}

class Neighborhood extends LineData {
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

class Homeowner extends LineData {
  final List<String> preferences;
  Homeowner({
    required this.preferences,
    required super.id,
    required super.energy,
    required super.water,
    required super.resilience,
  });

  static int compareByPreferences(Homeowner a, Homeowner b) {
    return a.preferences.join("").compareTo(b.preferences.join(""));
  }

  @override
  String toString() {
    return "H $id E:$energy W:$water R:$resilience ${preferences.join(">")}";
  }
}
