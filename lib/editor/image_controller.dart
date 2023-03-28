import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ImageNotifier extends ValueNotifier<PlatformFile?> {
  ImageNotifier() : super(null);

  Future<bool> selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select an image',
      type: FileType.image,
      allowMultiple: false,
    );
    final files = result?.files;

    if (files != null && files.isNotEmpty && files.first.bytes != null) {
      value = files.first;
    }

    return value != null;
  }

  void clear() => value = null;
}
