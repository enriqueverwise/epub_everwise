import 'package:epub_everwise/data/models/paragraph.dart';
import 'package:equatable/equatable.dart';

sealed class BreakEpubParagraph extends Equatable {
  final int breakPosition;
  final EpubParagraph paragraph;
  final double totalHeight;
  final double usedHeight;
  const BreakEpubParagraph({
    required this.breakPosition,
    required this.paragraph,
    required this.totalHeight,
    required this.usedHeight,
  });
}

class StartBreakEpubParagraph extends BreakEpubParagraph {
  final int startPosition;
  final int? endPosition;

  const StartBreakEpubParagraph({
    required this.startPosition,
    required super.paragraph,
    required super.totalHeight,
    this.endPosition,
    required super.usedHeight,
  }) : super(
          breakPosition: startPosition,
        );

  @override
  List<Object?> get props => [
        startPosition,
        endPosition,
        usedHeight,
        paragraph,
        totalHeight,
      ];
}

class EndBreakEpubParagraph extends BreakEpubParagraph {
  const EndBreakEpubParagraph({
    required super.breakPosition,
    required super.paragraph,
    required super.totalHeight,
    required super.usedHeight,
  });

  EndBreakEpubParagraph copyWith({
    int? breakPosition,
    EpubParagraph? paragraph,
    double? usedHeight,
    double? totalHeight,
  }) =>
      EndBreakEpubParagraph(
        breakPosition: breakPosition ?? this.breakPosition,
        paragraph: paragraph ?? this.paragraph,
        usedHeight: usedHeight ?? this.usedHeight,
        totalHeight: totalHeight ?? this.totalHeight,
      );

  @override
  List<Object?> get props => [
        breakPosition,
        paragraph,
        usedHeight,
        totalHeight,
      ];
}

class EpubPageInfo extends Equatable {
  final List<EpubParagraphMetadata> listParagraphMetadata;

  const EpubPageInfo({required this.listParagraphMetadata});

  @override
  List<Object?> get props => [listParagraphMetadata];
}

class EpubParagraphMetadata extends Equatable {
  final int paragraphIndex;
  final int chapterIndex;
  final int? startPosition;
  final int? endPosition;

  const EpubParagraphMetadata({
    required this.paragraphIndex,
    required this.chapterIndex,
    this.startPosition,
    this.endPosition,
  });

  EpubParagraphMetadata copyWith({
    int? paragraphIndex,
    int? chapterIndex,
    int? startPosition,
    int? endPosition,
  }) =>
      EpubParagraphMetadata(
        paragraphIndex: paragraphIndex ?? this.paragraphIndex,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        startPosition: startPosition ?? this.startPosition,
        endPosition: endPosition ?? this.endPosition,
      );

  @override
  List<Object?> get props =>
      [paragraphIndex, chapterIndex, startPosition, endPosition];
}

class EpubParagraphPage extends Equatable {
  final EpubParagraphMetadata metadata;
  final EpubParagraph value;

  const EpubParagraphPage({
    required this.value,
    required this.metadata,
  });

  EpubParagraphPage copyWith({
    EpubParagraph? value,
    EpubParagraphMetadata? metadata,
  }) =>
      EpubParagraphPage(
        value: value ?? this.value,
        metadata: metadata ?? this.metadata,
      );

  @override
  List<Object?> get props => [value, metadata];
}

class EpubPage extends Equatable {
  final List<EpubParagraphPage> paragraphsPerPage;
  final int chapterIndex;
  final double height;
  final StartBreakEpubParagraph? startBreakParagraph;
  final EndBreakEpubParagraph? endBreakParagraph;

  const EpubPage({
    required this.paragraphsPerPage,
    required this.chapterIndex,
    this.startBreakParagraph,
    this.endBreakParagraph,
    required this.height,
  });

  EpubPage copyWith({
    List<EpubParagraphPage>? paragraphsPerPage,
    int? chapterIndex,
    int? lines,
    StartBreakEpubParagraph? startBreakParagraph,
    EndBreakEpubParagraph? endBreakParagraph,
    double? height,
  }) =>
      EpubPage(
        paragraphsPerPage: paragraphsPerPage ?? this.paragraphsPerPage,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        startBreakParagraph: startBreakParagraph ?? this.startBreakParagraph,
        endBreakParagraph: endBreakParagraph ?? this.endBreakParagraph,
        height: height ?? this.height,
      );

  @override
  List<Object?> get props => [
        paragraphsPerPage,
        chapterIndex,
        startBreakParagraph,
        endBreakParagraph,
        height
      ];
}

extension EpubPageExt on EpubPage {
  EpubParagraphPage? getParagraphByIndex(EpubParagraphMetadata metadata) {
    return paragraphsPerPage
        .where((paragraph) =>
            paragraph.metadata.paragraphIndex == metadata.paragraphIndex)
        .firstOrNull;
  }

  bool doesParagraphBelongToPage(EpubParagraphMetadata metadata) {
    final paragraph = getParagraphByIndex(metadata);
    if (paragraph != null) {
      if ((paragraph.metadata.startPosition ?? 0) <=
          (metadata.startPosition ?? 0)) {
        final endParagraph = paragraph.metadata.endPosition;
        return endParagraph == null ||
            endParagraph >= (metadata.startPosition ?? 0);
      }
    }
    return false;
  }
}
