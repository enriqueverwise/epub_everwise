import 'package:equatable/equatable.dart';

class EpubChapter extends Equatable {
  final String? title;
  final String? contentFileName;
  final String? anchor;
  final String? htmlContent;
  final List<EpubChapter>? subChapters;

  EpubChapter({
    required this.title,
    required this.contentFileName,
    required this.anchor,
    required this.htmlContent,
    required this.subChapters,
  });

  @override
  List<Object?> get props => [
        title,
        contentFileName,
        anchor,
        htmlContent,
        subChapters,
      ];
}
