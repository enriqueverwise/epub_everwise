import 'dart:async';
import 'epub_content_file_ref.dart';

class EpubByteContentFileRef extends EpubContentFileRef {
  EpubByteContentFileRef({
    required super.epubBookRef,
    required super.fileName,
    required super.contentType,
    required super.contentMimeType,
  });

  Future<List<int>> readContent() {
    return readContentAsBytes();
  }

  @override
  List<Object?> get props => [
    epubBookRef,
    fileName,
    contentType,
    contentMimeType,
  ];
}
