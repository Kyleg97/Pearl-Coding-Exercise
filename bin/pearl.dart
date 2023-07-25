import 'package:pearl/pearl.dart' as pearl;

void main(List<String> arguments) async {
  var fileData = await pearl.loadFileData(fileName: "input.txt");
  var scoresMap = pearl.distributeHomeowners2(fileData: fileData);
  pearl.printResult(scoresMap);
}
