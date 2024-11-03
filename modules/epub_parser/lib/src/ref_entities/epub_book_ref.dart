import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:equatable/equatable.dart';

import '../entities/epub_schema.dart';
import '../readers/book_cover_reader.dart';
import '../readers/chapter_reader.dart';
import 'epub_chapter_ref.dart';
import 'epub_content_ref.dart';

class EpubBookRef extends Equatable {
  final Archive? epubArchive;
  final String? title;
  final String? author;
  final List<String?>? authorList;
  final EpubSchema? schema;
  final EpubContentRef? content;

  EpubBookRef({
    required this.epubArchive,
    required this.title,
    required this.author,
    required this.authorList,
    required this.schema,
    required this.content,
  });

  EpubBookRef copyWith({
    Archive? epubArchive,
    String? title,
    String? author,
    List<String?>? authorList,
    EpubSchema? schema,
    EpubContentRef? content,
  }) =>
      EpubBookRef(
        epubArchive: epubArchive ?? this.epubArchive,
        title: title ?? this.title,
        author: author ?? this.author,
        authorList: authorList ?? this.authorList,
        schema: schema ?? this.schema,
        content: content ?? this.content,
      );

  Future<List<EpubChapterRef>> getChapters() async {
    return ChapterReader.getChapters(this);
  }

  Future<Uint8List?> readCover() async {
    return await BookCoverReader.readBookCover(this);
  }

  @override
  List<Object?> get props => [
        epubArchive,
        title,
        author,
        authorList,
        schema,
        content,
      ];
}
