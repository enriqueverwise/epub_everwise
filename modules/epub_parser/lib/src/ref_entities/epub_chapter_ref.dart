import 'dart:async';
import 'package:equatable/equatable.dart';
import 'epub_text_content_file_ref.dart';

class EpubChapterRef extends Equatable {
  final EpubTextContentFileRef? epubTextContentFileRef;
  final String? title;
  final String? contentFileName;
  final String? anchor;
  final List<EpubChapterRef>? subChapters;

  EpubChapterRef({
    required this.epubTextContentFileRef,
    required this.title,
    required this.contentFileName,
    required this.anchor,
    required this.subChapters,
  });

  EpubChapterRef copyWith({
    EpubTextContentFileRef? epubTextContentFileRef,
    String? title,
    String? contentFileName,
    String? anchor,
    List<EpubChapterRef>? subChapters,
  }) =>
      EpubChapterRef(
        epubTextContentFileRef:
            epubTextContentFileRef ?? this.epubTextContentFileRef,
        title: title ?? this.title,
        contentFileName: contentFileName ?? this.contentFileName,
        anchor: anchor ?? this.anchor,
        subChapters: subChapters ?? this.subChapters,
      );

  Future<String> readHtmlContent() async {
    return epubTextContentFileRef!.readContentAsText();
  }

  @override
  List<Object?> get props => [
        epubTextContentFileRef,
        title,
        contentFileName,
        anchor,
        subChapters,
      ];
}
