import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFService {
  void save(pw.Document doc, {String? title}) async {
    final dir = await getApplicationDocumentsDirectory();

    final path = '${dir.path}/${title ?? 'unodots'}.pdf';
    debugPrint('EditorController.toPDF... $path');
    await File(path).writeAsBytes(await doc.save());
  }
}
