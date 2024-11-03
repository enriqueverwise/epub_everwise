import 'package:epub_everwise/data/models/chapter.dart';
import 'package:epub_everwise/data/models/paragraph.dart';
import 'package:equatable/equatable.dart';

class EpubBookContent extends Equatable {
  final List<EpubParagraph> listParagraphs;
  final List<EpubViewChapter> listChapters;

  const EpubBookContent({
    required this.listParagraphs,
    required this.listChapters,
  });

  @override
  List<Object?> get props => [
        listChapters,
        listParagraphs,
      ];
}
