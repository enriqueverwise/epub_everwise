import 'dart:async';
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import '../entities/epub_content_type.dart';
import '../utils/zip_path_utils.dart';
import 'epub_book_ref.dart';

abstract class EpubContentFileRef extends Equatable {
  final EpubBookRef epubBookRef;
  final String? fileName;
  final EpubContentType? contentType;
  final String? contentMimeType;

  EpubContentFileRef({
    required this.epubBookRef,
    required this.fileName,
    required this.contentType,
    required this.contentMimeType,
  });

  ArchiveFile getContentFileEntry() {
    var contentFilePath = ZipPathUtils.combine(
        epubBookRef.schema!.contentDirectoryPath, fileName);
    var contentFileEntry = epubBookRef.epubArchive!
        .files
        .firstWhereOrNull((ArchiveFile x) => x.name == contentFilePath);
    if (contentFileEntry == null) {
      throw Exception(
          'EPUB parsing error: file $contentFilePath not found in archive.');
    }
    return contentFileEntry;
  }

  List<int> getContentStream() {
    return openContentStream(getContentFileEntry());
  }

  List<int> openContentStream(ArchiveFile contentFileEntry) {
    var contentStream = <int>[];
    if (contentFileEntry.content == null) {
      throw Exception(
          'Incorrect EPUB file: content file \"$fileName\" specified in manifest is not found.');
    }
    contentStream.addAll(contentFileEntry.content);
    return contentStream;
  }

  Future<Uint8List> readContentAsBytes() async {
    var contentFileEntry = getContentFileEntry();
    var content = openContentStream(contentFileEntry);
    return Uint8List.fromList(content);
  }

  Future<String> readContentAsText() async {
    var contentStream = getContentStream();
    var result = convert.utf8.decode(contentStream);
    return result;
  }
}
