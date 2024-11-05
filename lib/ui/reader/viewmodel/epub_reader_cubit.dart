import 'package:epub_everwise/domain/entities/epub_reader_content.dart';
import 'package:epub_everwise/domain/entities/epub_reader_physics.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:epub_everwise/domain/entities/epub_decorator.dart';
import 'package:epub_everwise/domain/entities/epub_style.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_pagination_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'epub_reader_state.dart';

enum EpubChangeDirection {
  next,
  back;

  bool get isNext => this == next;
}

class EpubReaderCubit extends Cubit<EpubReaderState> with EpubPaginationMixin {
  EpubReaderCubit({
    required this.content,
    required this.epubBook,
    required this.screenSize,
    required TextStyle textStyle,
  }) : super(
          EpubReaderState(
            chapterContent: const EpubChapterContent(
              chapterIndex: 0,
              listPages: [],
            ),
            pageIndex: 0,
            decorator: EpubPageDecorator(
              style: EpubStyle(
                textStyle: textStyle,
                backgroundOption: EpubBackgroundOption.everwiseColor,
                physics: EpubReaderPhysics.book(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
          ),
        );

  final EpubBookContent content;
  final EpubBook epubBook;
  final Size screenSize;

  void initBook() {
    final listPages = _getListPages(
      state.chapterContent.chapterIndex,
      state.decorator.style.textStyle,
    );

    emit(
      state.copyWith(
        chapterContent: EpubChapterContent(
          chapterIndex: state.chapterContent.chapterIndex,
          listPages: listPages,
        ),
      ),
    );
  }

  void onPageChange(EpubChangeDirection direction) {
    if (direction.isNext) {
      tryNextPage();
    } else {
      tryPreviousPage();
    }
  }

  void tryNextPage() {
    if (state.pageIndex < (state.chapterContent.listPages.length - 1)) {
      emit(state.copyWith(
        pageIndex: (state.pageIndex + 1),
      ));
    } else {
      tryNextChapter();
    }
  }

  void tryPreviousPage() {
    if (state.pageIndex > 0) {
      emit(state.copyWith(
        pageIndex: (state.pageIndex - 1),
      ));
    } else {
      tryPreviousChapter();
    }
  }

  void onChapterChange(EpubChangeDirection direction) {
    if (direction.isNext) {
      tryNextChapter();
    } else {
      tryPreviousChapter();
    }
  }

  void tryPreviousChapter() {
    if (state.chapterContent.chapterIndex > 0) {
      final nextChapter = (state.chapterContent.chapterIndex - 1);
      final listPages = _getListPages(
        nextChapter,
        state.decorator.style.textStyle,
      );

      int pageIndex =
          listPages.indexWhere((page) => page.chapterIndex == nextChapter);

      emit(state.copyWith(
        pageIndex: pageIndex,
        chapterContent:
            EpubChapterContent(chapterIndex: nextChapter, listPages: listPages),
      ));
    }
  }

  void tryNextChapter() {
    if (state.chapterContent.chapterIndex < (content.listChapters.length - 1)) {
      final nextChapter = (state.chapterContent.chapterIndex + 1);

      final listPages = _getListPages(
        nextChapter,
        state.decorator.style.textStyle,
      );

      int pageIndex =
          listPages.indexWhere((page) => page.chapterIndex == nextChapter);

      emit(state.copyWith(
        pageIndex: pageIndex,
        chapterContent:
            EpubChapterContent(chapterIndex: nextChapter, listPages: listPages),
      ));
    }
  }

  void goToChapter(int index) {
    int pageIndex = state.chapterContent.listPages
        .indexWhere((page) => page.chapterIndex == index);

    emit(state.copyWith(
      pageIndex: pageIndex,
      chapterContent: state.chapterContent.copyWith(chapterIndex: index),
    ));
  }

  void updateStyle(EpubStyle style) {
    final metadataParagraph = state.chapterContent.listPages[state.pageIndex]
        .paragraphsPerPage.first.metadata;

    final listPages = _getListPages(
      state.chapterContent.chapterIndex,
      style.textStyle,
    );

    final pageIndex = listPages.indexWhere(
      (page) => page.doesParagraphBelongToPage(
        metadataParagraph,
      ),
    );

    emit(
      state.copyWith(
        decorator: state.decorator.copyWith(
          style: style.copyWith(
            textStyle: style.textStyle.copyWith(
              color:
                  style.backgroundOption.isLight ? Colors.black : Colors.white,
            ),
          ),
        ),
        pageIndex: pageIndex,
        chapterContent: EpubChapterContent(
          chapterIndex: state.chapterContent.chapterIndex,
          listPages: listPages,
        ),
      ),
    );
  }

  Size getSizeScreen() {
    final width =
        screenSize.width - state.decorator.padding.along(Axis.horizontal);
    final height =
        screenSize.height - state.decorator.padding.along(Axis.vertical);
    return Size(width, height);
  }

  List<EpubPage> _getListPages(int chapter, TextStyle style) {
    return pagesForListParagraphs(
      screenSize: getSizeScreen(),
      style: style,
      listParagraphs: content.listParagraphs,
      images: epubBook.content?.images ?? {},
    );
  }

  void showPanel() {
    emit(
      state.copyWith(
        panelVisible: true,
      ),
    );
  }

  void updatePanelVisibility() {
    if (state.panelVisible) {
      hidePanel();
    } else {
      showPanel();
    }
  }

  void hidePanel() {
    emit(
      state.copyWith(
        panelVisible: false,
      ),
    );
  }

  void goToPage(int pageIndex) {
    emit(state.copyWith(pageIndex: pageIndex));
  }
}
