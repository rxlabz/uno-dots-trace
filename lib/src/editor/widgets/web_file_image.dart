import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Image buildImageFromFile( PlatformFile file) =>Image.memory(file.bytes!, fit: BoxFit.contain);

