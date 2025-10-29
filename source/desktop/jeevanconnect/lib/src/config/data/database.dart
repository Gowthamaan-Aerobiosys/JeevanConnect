import 'package:path_provider/path_provider.dart';

import '../../../objectbox.g.dart';

class Database {
  static late final Store _store;

  Future init() async {
    String rootPath = (await getApplicationSupportDirectory()).path;
    _store = await openStore(directory: "$rootPath/jeevan_connect");
    return;
  }

  dispose() {
    _store.close();
  }

  get store => _store;
}
