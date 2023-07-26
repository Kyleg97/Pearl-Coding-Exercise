import 'package:pearl/pearl.dart';
import 'package:pearl/pearl_data.dart';
import 'package:test/test.dart';

void main() {
  test('calculate dot product', () {
    Homeowner homeowner = Homeowner(
      preferences: ["N0", "N1", "N2"],
      id: "H0",
      energy: 5,
      water: 3,
      resilience: 4,
    );
    Neighborhood neighborhood = Neighborhood(
      id: "N0",
      energy: 10,
      water: 5,
      resilience: 3,
    );
    int dotProduct = homeowner.calculateDotProduct(neighborhood);
    expect(dotProduct, 77);
  });

  test('compare by preferences', () {
    (Homeowner, int) homeowner1 = (
      Homeowner(
        preferences: ["N0", "N1", "N2"],
        id: "H0",
        energy: 5,
        water: 3,
        resilience: 4,
      ),
      100
    );
    (Homeowner, int) homeowner2 = (
      Homeowner(
        preferences: ["N1", "N0", "N2"],
        id: "H1",
        energy: 6,
        water: 3,
        resilience: 5,
      ),
      112
    );
    int result = Homeowner.compareByPreferences(homeowner1, homeowner2);
    expect(result, -1);
  });

  test('distribute homeowners', () {
    List<PearlData> data = [
      Neighborhood(
        id: "N0",
        energy: 5,
        water: 4,
        resilience: 6,
      ),
      Homeowner(
        preferences: ["N0"],
        id: "H0",
        energy: 3,
        water: 4,
        resilience: 5,
      ),
      Homeowner(
        preferences: ["N0"],
        id: "H1",
        energy: 4,
        water: 2,
        resilience: 3,
      ),
      Homeowner(
        preferences: ["N0"],
        id: "H2",
        energy: 1,
        water: 9,
        resilience: 3,
      ),
      Homeowner(
        preferences: ["N0"],
        id: "H3",
        energy: 7,
        water: 8,
        resilience: 6,
      ),
    ];
    var map = distributeHomeowners(fileData: data);
    var expectedMap = {
      data[0]: [
        (data[4], 103),
        (data[1], 61),
        (data[3], 59),
        (data[2], 46),
      ]
    };
    expect(map, expectedMap);
  });
}
