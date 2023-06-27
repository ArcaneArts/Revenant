import 'package:application/util/sugar.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:serviced/serviced.dart';

class StorageService extends StatelessService implements AsyncStartupTasked {
  @override
  Future<void> onStartupTask() async {
    if (!kIsWeb) {
      String path = (await getApplicationDocumentsDirectory()).path;
      Hive.init(path);
      success("Initialized Non-Web Hive storage location: $path");
    }

    box = await hive("main");
    verbose("Storage Initialized");
  }
}
