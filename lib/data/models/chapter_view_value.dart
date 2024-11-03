import 'package:epub_everwise/data/epub_parser.dart';
import 'package:equatable/equatable.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

export 'package:epub_parser/epub_parser.dart' hide Image;

class EpubChapterViewDetail extends Equatable {
  const EpubChapterViewDetail({
    required this.chapter,
    required this.chapterNumber,
    required this.paragraphNumber,
    required this.position,
  });

  final EpubChapter? chapter;
  final int chapterNumber;
  final int paragraphNumber;
  final ItemPosition position;

  /// Chapter view in percents
  double get progress {
    final itemLeadingEdgeAbsolute = position.itemLeadingEdge.abs();
    final fullHeight = itemLeadingEdgeAbsolute + position.itemTrailingEdge;
    final heightPercent = fullHeight / 100;
    return itemLeadingEdgeAbsolute / heightPercent;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        chapter,
        chapterNumber,
        paragraphNumber,
        position,
      ];
}
