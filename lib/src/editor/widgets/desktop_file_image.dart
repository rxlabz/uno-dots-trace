import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Image buildImageFromFile(PlatformFile file) =>
    Image.file(File(file.path!), fit: BoxFit.contain);
