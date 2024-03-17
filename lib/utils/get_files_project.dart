import 'dart:convert';

import 'package:my_intra/model/files.dart';
import 'package:my_intra/utils/fetch_data.dart';

Future<List<File>> getFilesForProject(String projectUrl) async {
  final url = projectUrl;
  final responseString = await fetchData(url);
  final value = jsonDecode(responseString);
  final List<File> files = [];
  for (var file in value) {
    if (file['type'] == 'd') {
      List<File> filesInFolder = await getFilesForProject(
          "https://intra.epitech.eu/${file['fullpath']}/?format=json");
      files.addAll(filesInFolder);
      continue;
    }
    files.add(File.fromJson(file));
  }
  return files;
}
