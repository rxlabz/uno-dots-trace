// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFService {
  void save(pw.Document doc, {String? title}) async {
    final bytes = await doc.save();

    final pdfFile = Blob(
      <Uint8List>[bytes],
      'application/pdf',
    );
    final pdfUrl = Url.createObjectUrl(pdfFile);
    final link = AnchorElement();
    link.href = pdfUrl;
    link.download = 'uno-dots.pdf';
    link.click();
  }
}
