import 'dart:async';
import 'epub_content_file_ref.dart';

class EpubCssContentFileRef extends EpubContentFileRef {
  EpubCssContentFileRef({
    required super.epubBookRef,
    required super.fileName,
    required super.contentType,
    required super.contentMimeType,
  });

  Future<String> readContentAsync() async {
    return readContentAsText();
  }

  @override
  List<Object?> get props =>[
    epubBookRef,
    fileName,
    contentType,
    contentMimeType,
  ];
}
