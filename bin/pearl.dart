import 'package:pearl/pearl.dart' as pearl;

void main(List<String> arguments) async {
  var fileData = await pearl.readFileData(fileName: "input.txt");
  var scoresMap = pearl.distributeHomeowners(fileData: fileData);
  pearl.printResult(scoresMap);
  pearl.writeFileData(map: scoresMap);
}
