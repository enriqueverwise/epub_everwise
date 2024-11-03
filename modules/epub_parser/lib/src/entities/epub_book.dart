import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'epub_chapter.dart';
import 'epub_content.dart';
import 'epub_schema.dart';

class EpubBookInfo extends Equatable {
  final String title;
  final String author;

  EpubBookInfo({
    required this.title,
    required this.author,
  });

  @override
  List<Object?> get props => [
        title,
        author,
      ];
}

class EpubBook extends Equatable {
  final EpubBookInfo? epubBookInfo;
  final EpubSchema? schema;
  final EpubContent? content;
  final Uint8List? coverImage;
  final List<EpubChapter>? chapters;

  EpubBook({
    required this.epubBookInfo,
    required this.schema,
    required this.content,
    required this.coverImage,
    required this.chapters,
  });

  EpubBook copyWith({
    EpubBookInfo? epubBookInfo,
    EpubSchema? schema,
    EpubContent? content,
    Uint8List? coverImage,
    List<EpubChapter>? chapters,
  }) =>
      EpubBook(
        epubBookInfo: epubBookInfo ?? this.epubBookInfo,
        schema: schema ?? this.schema,
        content: content ?? this.content,
        coverImage: coverImage ?? this.coverImage,
        chapters: chapters ?? this.chapters,
      );

  @override
  List<Object?> get props => [
        epubBookInfo,
        schema,
        content,
        coverImage,
      ];
}
