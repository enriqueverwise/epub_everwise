part of 'epub_reader_cubit.dart';

class EpubReaderState extends Equatable {
  const EpubReaderState({
    required this.pageIndex,
    required this.chapterContent,
    required this.decorator,
    this.totalPages = 0,
    this.panelVisible = false,
  });

  final int pageIndex;
  final int totalPages;
  final EpubChapterContent chapterContent;
  final EpubPageDecorator decorator;
  final bool panelVisible;

  EpubReaderState copyWith({
    int? pageIndex,
    EpubChapterContent? chapterContent,
    EpubPageDecorator? decorator,
    int? totalPages,
    bool? panelVisible,
  }) =>
      EpubReaderState(
        pageIndex: pageIndex ?? this.pageIndex,
        chapterContent: chapterContent ?? this.chapterContent,
        decorator: decorator ?? this.decorator,
        totalPages: totalPages ?? this.totalPages,
        panelVisible: panelVisible ?? this.panelVisible,
      );

  @override
  List<Object?> get props => [
        pageIndex,
        chapterContent,
        decorator,
        totalPages,
        panelVisible,
      ];
}
