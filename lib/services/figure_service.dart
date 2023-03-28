import 'package:shared_preferences/shared_preferences.dart';

const String _figureKey = 'figures';

class FigureService {
  final SharedPreferences prefs;

  FigureService(this.prefs);

  Future<List<String>> load() async {
    if (prefs.containsKey(_figureKey)) {
      return prefs.getStringList(_figureKey)!;
    }

    await prefs.setStringList(_figureKey, []);
    return [];
  }

  Future<bool> save(List<String> data) async {
    return prefs.setStringList(_figureKey, data);
  }
}
