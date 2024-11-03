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

class EpubPage extends Equatable {
  final List<EpubParagraph> paragraphsPerPage;
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
    List<EpubParagraph>? paragraphsPerPage,
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
