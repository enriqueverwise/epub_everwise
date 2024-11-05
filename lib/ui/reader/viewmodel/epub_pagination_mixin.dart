import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:epub_everwise/data/models/paragraph.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart';

mixin EpubPaginationMixin {
  double? getImageHeight(
    EpubParagraph paragraph,
    Map<String, EpubImageContentFile> images,
    double maxWidth,
  ) {
    Element? imgElement =
        paragraph.element.getElementsByTagName("img").firstOrNull;

    imgElement ??= paragraph.element.getElementsByTagName("image").firstOrNull;
    String? filePath = imgElement?.attributes["src"];
    filePath ??= paragraph.element.attributes.entries
        .where((entry) => entry.key.toString().contains("href"))
        .firstOrNull
        ?.value;
    filePath = filePath?.replaceAll("../", '');
    final imageContent = images[filePath];

    if (imageContent != null) {
      final aspectRatio = imageContent.width / imageContent.height;

      final imageHeight = maxWidth / aspectRatio;

      return imageHeight;
    }
    return maxWidth;
  }

  double getHeightParagraph(
    EpubParagraph paragraph,
    Size screenSize,
    TextStyle style,
    Map<String, EpubImageContentFile> images,
  ) {
    double heightParagraph = 0;
    if (paragraph.type.isText) {
      heightParagraph = calculateHeightPerTextParagraph(
        screenSize.width,
        style,
        paragraph,
      );
    } else if (paragraph.type.isTitle) {
      heightParagraph = (calculateHeightPerTextParagraph(
            screenSize.width,
            style.copyWith(
              fontSize: style.fontSize! + 3,
              fontWeight: FontWeight.bold,
            ),
            paragraph,
          ) +
          20);
    } else {
      heightParagraph = getImageHeight(
            paragraph,
            images,
            screenSize.width - 30,
          ) ??
          0;
    }
    return heightParagraph;
  }

  double calculateHeightText(double maxWidth, TextStyle style, String text) {
    TextSpan span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);

    tp.layout(
      maxWidth: maxWidth,
    );
    return tp.height;
  }

  double calculateHeightPerTextParagraph(
    double maxWidth,
    TextStyle style,
    EpubParagraph paragraph,
  ) {
    return calculateHeightText(
      maxWidth,
      style,
      paragraph.element.text,
    );
  }

  EndBreakEpubParagraph? calculateNiceEndOfPage({
    required EpubParagraph paragraph,
    required double heightPageAvailable,
    required double paragraphHeight,
  }) {
    if (heightPageAvailable < 30) {
      return null;
    }
    //Percentage of text from paragraph remaining
    final percentageOfParagraphUsable = heightPageAvailable / paragraphHeight;

    int positionBreakParagraph =
        (paragraph.element.text.length * percentageOfParagraphUsable).floor();

    final int remainingParagraphText =
        paragraph.element.text.length - positionBreakParagraph;
    if (remainingParagraphText < 9) {
      positionBreakParagraph = paragraph.element.text.length;
    } else {
      int endPosition = calculateBestEndPosition(
        paragraph: paragraph,
        startPosition: 0,
        endPosition: positionBreakParagraph,
      );
      positionBreakParagraph = endPosition;
    }

    final breakParagraph = EndBreakEpubParagraph(
      breakPosition: positionBreakParagraph,
      paragraph: paragraph,
      usedHeight: (paragraphHeight * percentageOfParagraphUsable) + 20,
      totalHeight: paragraphHeight,
    );
    return breakParagraph;
  }

  List<EpubParagraph> getParagraphsOfChapter(
      int chapter, List<EpubParagraph> listAllParagraphs) {
    final blockOfParagraphByChapter = <int, List<EpubParagraph>>{};

    for (final ph in listAllParagraphs) {
      blockOfParagraphByChapter.update(ph.chapterIndex, (listPh) {
        listPh.add(ph);
        return listPh;
      }, ifAbsent: () {
        return [ph];
      });
    }

    return blockOfParagraphByChapter[chapter] ?? [];
  }

  List<EpubPage> pagesForListParagraphs({
    required Size screenSize,
    required TextStyle style,
    required List<EpubParagraph> listParagraphs,
    required Map<String, EpubImageContentFile> images,
  }) {
    final listPages = <EpubPage>[];

    final maxHeight = screenSize.height * 0.9;
    EpubPage? currentPage;

    for (int indexParagraph = 0;
        indexParagraph < listParagraphs.length;
        indexParagraph++) {
      final metadata = EpubParagraphMetadata(
        paragraphIndex: indexParagraph,
        chapterIndex: listParagraphs[indexParagraph].chapterIndex,
      );

      final paragraphPage = EpubParagraphPage(
        value: listParagraphs[indexParagraph],
        metadata: metadata,
      );

      // calcular tamaño párrafo
      double heightParagraph = getHeightParagraph(
        paragraphPage.value,
        screenSize,
        style,
        images,
      );

      if (currentPage != null &&
          currentPage.chapterIndex != paragraphPage.value.chapterIndex) {
        listPages.add(currentPage);
        currentPage = null;
      }
      if (currentPage == null) {
        final listPagesOfParagraph = getPagesForParagraph(
          paragraph: paragraphPage,
          maxHeight: maxHeight-40,
          heightParagraph: heightParagraph,
          realHeightParagraph: heightParagraph,
        );

        currentPage = listPagesOfParagraph.removeLast();
        if (listPagesOfParagraph.isNotEmpty) {
          listPages.addAll(listPagesOfParagraph);
        }

        if ((currentPage.height + 30) >= maxHeight ||
            indexParagraph == (listParagraphs.length - 1)) {
          listPages.add(currentPage);
          currentPage = null;
        }
        continue;
      } else {
        final remainingPageHeight = maxHeight - currentPage.height;

        if (remainingPageHeight >= heightParagraph) {
          currentPage.paragraphsPerPage.add(paragraphPage);
          currentPage = currentPage.copyWith(
            height: (currentPage.height + heightParagraph + 20),
          );
          if ((currentPage.height + 30) >= maxHeight ||
              indexParagraph == (listParagraphs.length - 1)) {
            listPages.add(currentPage);
            currentPage = null;
            continue;
          }
        } else {
          if (paragraphPage.value.type.isImg) {
            listPages.add(currentPage);
            currentPage = EpubPage(
              paragraphsPerPage: [paragraphPage],
              chapterIndex: paragraphPage.value.chapterIndex,
              height: heightParagraph,
            );

            continue;
          }
          EndBreakEpubParagraph? endBreakEpubParagraph = calculateNiceEndOfPage(
            paragraph: paragraphPage.value,
            heightPageAvailable: remainingPageHeight-20,
            paragraphHeight: heightParagraph,
          );

          if (endBreakEpubParagraph != null) {
            currentPage.paragraphsPerPage.add(
              paragraphPage.copyWith(
                metadata: paragraphPage.metadata.copyWith(
                  endPosition: endBreakEpubParagraph.breakPosition,
                ),
              ),
            );
          }

          listPages.add(currentPage);
          currentPage = null;

          final listParagraphPages = getPagesForParagraph(
            paragraph: paragraphPage,
            maxHeight: maxHeight,
            heightParagraph: heightParagraph -
                (endBreakEpubParagraph != null
                    ? endBreakEpubParagraph.usedHeight
                    : 0),
            realHeightParagraph: heightParagraph,
            indexBreakPosition: endBreakEpubParagraph != null
                ? endBreakEpubParagraph.breakPosition
                : 0,
          );

          currentPage = listParagraphPages.removeLast();
          if (listParagraphPages.isNotEmpty) {
            listPages.addAll(listParagraphPages);
          }

          if ((currentPage.height + 30) >= maxHeight ||
              indexParagraph == (listParagraphs.length - 1)) {
            listPages.add(currentPage);
            currentPage = null;
          }
        }
      }
    }
    return listPages;
  }

  List<EpubPage> getPagesForParagraph({
    required EpubParagraphPage paragraph,
    required double maxHeight,
    required double heightParagraph,
    required double realHeightParagraph,
    int? indexBreakPosition,
  }) {
    final listPagesParagraph = <EpubPage>[];

    if (paragraph.value.type.isImg) {
      final epubPage = EpubPage(
        paragraphsPerPage: [paragraph],
        chapterIndex: paragraph.value.chapterIndex,
        height: heightParagraph + 40,
      );
      listPagesParagraph.add(epubPage);
      return listPagesParagraph;
    }

    final numPagesForParagraph = (heightParagraph / maxHeight);
    final nRealPages = numPagesForParagraph.floor();
    int startPosition = indexBreakPosition ?? 0;
    double sizeParagraphPortion = 0;
    if (nRealPages > 0) {
      final percentagePortionParagraph = maxHeight / heightParagraph;
      sizeParagraphPortion = heightParagraph * percentagePortionParagraph;

      final textTotalPortionParagraph =
          (paragraph.value.element.text.substring(startPosition).length *
                  percentagePortionParagraph)
              .floor();


      for (int indexPage = 0; indexPage < nRealPages; indexPage++) {
        try {
          int endPosition = (startPosition + textTotalPortionParagraph).floor();
          endPosition = calculateBestEndPosition(
            paragraph: paragraph.value,
            startPosition: startPosition,
            endPosition: endPosition,
          );

          paragraph = paragraph.copyWith(
            metadata: paragraph.metadata.copyWith(
              startPosition: startPosition,
              endPosition: endPosition,
            ),
          );

          // final startBreakParagraph = StartBreakEpubParagraph(
          //   startPosition: startPosition,
          //   endPosition: endPosition,
          //   paragraph: paragraph,
          //   totalHeight: heightParagraph,
          //   usedHeight: maxHeight,
          // );
          startPosition = endPosition;
          final epubPage = EpubPage(
            paragraphsPerPage: [paragraph],
            chapterIndex: paragraph.value.chapterIndex,
            height: maxHeight,
          );
          listPagesParagraph.add(epubPage);
        } catch (e) {
          print(e);
        }
      }
    }
    EpubPage epubPage;
    if (startPosition != 0) {
      //Page with leftOvers of paragraph

      paragraph = paragraph.copyWith(
        metadata: paragraph.metadata.copyWith(
          startPosition: startPosition,
        ),
      );
      // final startBreakParagraph = StartBreakEpubParagraph(
      //   startPosition: startPosition,
      //   paragraph: paragraph,
      //   totalHeight: heightParagraph,
      //   usedHeight: heightParagraph - sizeParagraphPortion,
      // );

      epubPage = EpubPage(
        paragraphsPerPage: [paragraph],
        chapterIndex: paragraph.value.chapterIndex,
        height: heightParagraph - sizeParagraphPortion,
      );
    } else {
      epubPage = EpubPage(
        paragraphsPerPage: [paragraph],
        chapterIndex: paragraph.value.chapterIndex,
        height: heightParagraph,
      );
    }
    listPagesParagraph.add(epubPage);

    return listPagesParagraph;
  }

  int calculateBestEndPosition({
    required EpubParagraph paragraph,
    required int startPosition,
    required int endPosition,
  }) {
    int startPositionSearch = endPosition - 25;
    int endPositionSearch = endPosition;
    if (startPosition > startPositionSearch) {
      startPositionSearch = startPosition;
    }

    if (paragraph.element.text.length <= (endPositionSearch + 40)) {
      return paragraph.element.text.length;
    } else {
      endPositionSearch = endPosition + 40;
    }

    String subTextForSearch = paragraph.element.text.substring(
      startPositionSearch,
      endPositionSearch,
    );

    int indexOfBreak = subTextForSearch.lastIndexOf(".");
    if (indexOfBreak < 0) {
      indexOfBreak = subTextForSearch.lastIndexOf("?");
    }
    if (indexOfBreak < 0) {
      indexOfBreak = subTextForSearch.lastIndexOf("!");
    }

    if (indexOfBreak < 0) {
      indexOfBreak = subTextForSearch.lastIndexOf(",");
    }
    if (indexOfBreak < 0) {
      indexOfBreak = subTextForSearch.lastIndexOf(" ");
    }
    if (indexOfBreak >= 0) {
      endPositionSearch = startPositionSearch + indexOfBreak + 1;
    }
    return endPositionSearch;
  }
}
