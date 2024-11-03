import '../ref_entities/epub_book_ref.dart';
import '../ref_entities/epub_chapter_ref.dart';
import '../ref_entities/epub_text_content_file_ref.dart';
import '../schema/navigation/epub_navigation_point.dart';

class ChapterReader {
  static List<EpubChapterRef> getChapters(EpubBookRef bookRef) {
    if (bookRef.schema!.navigation == null) {
      return <EpubChapterRef>[];
    }
    return getChaptersImpl(
        bookRef, bookRef.schema!.navigation!.navMap!.Points!);
  }

  static List<EpubChapterRef> getChaptersImpl(
      EpubBookRef bookRef, List<EpubNavigationPoint> navigationPoints) {
    var listChapterRef = <EpubChapterRef>[];
    // navigationPoints.forEach((EpubNavigationPoint navigationPoint) {
    for (var navigationPoint in navigationPoints) {
      String? contentFileName;
      String? anchor;
      if (navigationPoint.Content?.Source == null) continue;
      var contentSourceAnchorCharIndex =
          navigationPoint.Content!.Source!.indexOf('#');
      if (contentSourceAnchorCharIndex == -1) {
        contentFileName = navigationPoint.Content!.Source;
        anchor = null;
      } else {
        contentFileName = navigationPoint.Content!.Source!
            .substring(0, contentSourceAnchorCharIndex);
        anchor = navigationPoint.Content!.Source!
            .substring(contentSourceAnchorCharIndex + 1);
      }
      contentFileName = Uri.decodeFull(contentFileName!);
      EpubTextContentFileRef? htmlContentFileRef;
      if (!bookRef.content!.html!.containsKey(contentFileName)) {
        throw Exception(
            'Incorrect EPUB manifest: item with href = \"$contentFileName\" is missing.');
      }

      htmlContentFileRef = bookRef.content!.html![contentFileName];

      final chapterRef = EpubChapterRef(
        epubTextContentFileRef: htmlContentFileRef,
        title: navigationPoint.NavigationLabels!.first.Text,
        contentFileName: contentFileName,
        anchor: anchor,
        subChapters: getChaptersImpl(bookRef, navigationPoint.ChildNavigationPoints!),
      );
      listChapterRef.add(chapterRef);
    }
    ;
    return listChapterRef;
  }
}
