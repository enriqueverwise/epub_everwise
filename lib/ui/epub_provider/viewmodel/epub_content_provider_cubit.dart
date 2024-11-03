import 'package:bloc/bloc.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/epub_parser.dart';
import 'package:epub_everwise/data/models/chapter.dart';
import 'package:epub_everwise/data/models/chapter_view_value.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/data/models/paragraph.dart';
import 'package:equatable/equatable.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'epub_content_state.dart';

class EpubContentProviderCubit extends Cubit<EpubContentState> {
  EpubContentProviderCubit({
    required this.epubBook,
    required this.epubFragmentId,
  }) : super(EpubContentLoading());
  final EpubBook epubBook;
  final String? epubFragmentId;

  List<EpubViewChapter> _getTableOfContents() {
    int index = -1;

    final listChapters = epubBook.chapters!.fold<List<EpubViewChapter>>(
      [],
      (acc, next) {
        index += 1;
        acc.add(
          EpubViewChapter(
            next.title,
            0,
          ),
        );
        for (final subChapter in next.subChapters!) {
          index += 1;
          acc.add(
            EpubViewSubChapter(
              subChapter.title,
              0,
              //_getChapterStartIndex(index),
            ),
          );
        }
        return acc;
      },
    );

    return listChapters;
  }

  void updateCurrentChapter(EpubChapter? currentChapter, int chapterIndex,
      ItemPosition position, int paragraphIndex) {
    final currentChapterDetails = EpubChapterViewDetail(
      chapter: currentChapter,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: paragraphIndex + 1,
      position: position,
    );
  }

  Future<void> loadData() async {
    emit(EpubContentLoading());
    try {
      final listChapters = parseChapters(epubBook);
      final listViewChapters = _getTableOfContents();
      final parseParagraphsResult =
          parseParagraphs(listChapters, epubBook.content);
      final listParagraphs = parseParagraphsResult.flatParagraphs;

      emit(
        EpubContentSuccess(
          chapterIndex: 0,
          content: EpubBookContent(
            listParagraphs: listParagraphs,
            listChapters: listViewChapters,
          ),
        ),
      );
    } catch (error) {
      emit(EpubContentError());
    }
  }

  void goToChapter(int index) {
    final pagState = (state as EpubContentSuccess);
    emit(pagState.copyWith(chapterIndex: index));
  }

  void nextChapter() {
    final pagState = (state as EpubContentSuccess);
    emit(pagState.copyWith(chapterIndex: (pagState.chapterIndex + 1)));
  }

  void previousChapter() {
    final pagState = (state as EpubContentSuccess);
    emit(pagState.copyWith(chapterIndex: (pagState.chapterIndex - 1)));
  }
}
