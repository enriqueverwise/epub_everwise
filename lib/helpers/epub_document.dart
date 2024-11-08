// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/services.dart';
import 'package:universal_file/universal_file.dart';

class EpubDocument {
  static Future<EpubBook> openAsset(String assetName) async {
    final byteData = await rootBundle.load(assetName);
    final bytes = byteData.buffer.asUint8List();
    return EpubReader.readBook(bytes);
  }

  static Future<Uint8List?> getCoverFromBook(String assetName) async {
    final byteData = await rootBundle.load(assetName);
    final bytes = byteData.buffer.asUint8List();
    final book = await EpubReader.openBook(bytes);

    final image = await book.readCover();

    return image;
  }

  static Future<Uint8List?> getCoverFromBookData(Uint8List bytes) async {
    final book = await EpubReader.openBook(bytes);

    final image = await book.readCover();

    return image;
  }

  static Future<EpubBook> openData(Uint8List bytes) async {
    return EpubReader.readBook(bytes);
  }

  static Future<EpubBook> openFile(File file) async {
    final bytes = await file.readAsBytes();
    return EpubReader.readBook(bytes);
  }
}
