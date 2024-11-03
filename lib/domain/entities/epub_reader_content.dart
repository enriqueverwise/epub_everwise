import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:equatable/equatable.dart';

class EpubChapterContent extends Equatable {
  final int chapterIndex;
  final List<EpubPage> listPages;
  const EpubChapterContent({
    required this.chapterIndex,
    required this.listPages,
  });

  EpubChapterContent copyWith({
    int? chapterIndex,
    List<EpubPage>? listPages,
  }) =>
      EpubChapterContent(
        chapterIndex: chapterIndex ?? this.chapterIndex,
        listPages: listPages ?? this.listPages,
      );

  @override
  List<Object?> get props => [
    chapterIndex,
    listPages,
  ];
}