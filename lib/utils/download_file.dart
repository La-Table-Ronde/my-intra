import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:my_intra/utils/fetch_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';

Future<void> downloadFile(String fileUrl, String filename) async {
  final url = 'https://intra.epitech.eu/$fileUrl';
  final bytes = await fetchBytes(url);

  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getTemporaryDirectory();
    } else {
      await getTemporaryDirectory();
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getTemporaryDirectory();
      }
    }
  } catch (err, stack) {
    FirebaseCrashlytics.instance.recordError(err, stack);
  }
  try {
    final file = File('${directory!.path}/my_intra/$filename');
    file.create(recursive: true);
    if (file.existsSync()) {
      await file.writeAsBytes(bytes);
    } else {
      File('${directory.path}/my_intra/$filename');
      await file.writeAsBytes(bytes);
    }
    await OpenFile.open(file.path);
  } catch (err, stack) {
    FirebaseCrashlytics.instance.recordError(err, stack);
    rethrow;
  }
}
