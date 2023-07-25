import 'dart:io';
import 'package:pearl/pearl_data.dart';

Future<List<PearlData>> readFileData({required String fileName}) async {
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

void writeFileData({
  required Map<Neighborhood, List<(Homeowner, int)>> map,
}) async {
  File outputFile = File("output.txt");
  String strToWrite = "";
  for (var key in map.keys) {
    // print("${key.id}: ${map[key]?.join("")}");
    strToWrite += "${key.id}:";
    map[key]?.forEach((element) {
      strToWrite += " ${element.$1.id}(${element.$2})";
    });
    strToWrite += "\n";
    outputFile.writeAsString(
      strToWrite,
      mode: FileMode.writeOnly,
    );
  }
}

Map<Neighborhood, List<(Homeowner, int)>> distributeHomeowners2({
  required List<PearlData> fileData,
}) {
  List<Neighborhood> neighborhoods =
      fileData.whereType<Neighborhood>().toList();
  List<Homeowner> homeowners = fileData.whereType<Homeowner>().toList();

  Map<Neighborhood, List<(Homeowner, int)>> map = {};

  // sort the homeowners based on their priorities and scores
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

  int homeownersPerNeighborhood = (homeowners.length ~/ neighborhoods.length);

  int currentIndex = 0;

  // create lists of homeowners for each neighborhoods
  for (var neighborhood in neighborhoods) {
    List<(Homeowner, int)> homeownersForNeighborhood = [];

    for (int i = 0; i < homeownersPerNeighborhood; i++) {
      homeownersForNeighborhood.add((
        homeowners[currentIndex],
        homeowners[currentIndex].calculateDotProduct(neighborhood)
      ));
      currentIndex++;
    }

    homeownersForNeighborhood.sort((a, b) => b.$2.compareTo(a.$2));
    map[neighborhood] = homeownersForNeighborhood;
  }

  return map;
}

void printResult(Map<Neighborhood, List<(Homeowner, int)>> map) {
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
