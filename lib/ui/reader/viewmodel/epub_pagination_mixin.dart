
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
    Element? imgElement = paragraph.element.localName == "img" ? paragraph.element : null;

    imgElement ??= paragraph.element.getElementsByTagName("img").firstOrNull;

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
    return null;
  }

  double? getHeightParagraph(
    EpubParagraph paragraph,
    Size screenSize,
    TextStyle style,
    Map<String, EpubImageContentFile> images,
  ) {
    double? heightParagraph;

    switch (paragraph.type) {
      case TypeParagraph.image:
        heightParagraph = getImageHeight(
              paragraph,
              images,
              screenSize.width - 30,
            );
        break;
      case TypeParagraph.jump:
        heightParagraph = 10;
      case TypeParagraph.text:
        heightParagraph = calculateHeightPerTextParagraph(
          screenSize.width-10,
          style,
          paragraph,
        );
        break;
      case TypeParagraph.h1:
      case TypeParagraph.h2:
      case TypeParagraph.h3:
      case TypeParagraph.h4:
      case TypeParagraph.h5:
      case TypeParagraph.h6:
        heightParagraph = (calculateHeightPerTextParagraph(
              screenSize.width,
              style.copyWith(
                fontSize: style.fontSize! + 3,
                fontWeight: FontWeight.bold,
              ),
              paragraph,
            ) +
            20);
        break;
      case TypeParagraph.table:
        heightParagraph = (calculateHeightPerTextParagraph(
          screenSize.width,
          style.copyWith(
            fontSize: style.fontSize!,
            fontWeight: FontWeight.bold,
          ),
          paragraph,
        ));
        break;
    }

    print("heightParagraph: $heightParagraph");
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
    required TextStyle style,
    required double width,
  }) {
    if (heightPageAvailable <= 30) {
      return null;
    }
    //Percentage of text from paragraph remaining
    final percentageOfParagraphUsable = heightPageAvailable / paragraphHeight;

    int positionBreakParagraph =
        (paragraph.element.text.length * percentageOfParagraphUsable).floor();

    print("height available: $heightPageAvailable");

    positionBreakParagraph = getLastParagraphPositionForEndLine(
      positionBreakParagraph: positionBreakParagraph,
      paragraph: paragraph,
      heightPageAvailable: heightPageAvailable,
      style: style,
      width: width,
    );

    final int remainingParagraphText =
        paragraph.element.text.length - positionBreakParagraph;
    if (remainingParagraphText < 10) {
      positionBreakParagraph = paragraph.element.text.length;
    } else {
      // int endPosition = calculateBestEndPosition(
      //   paragraph: paragraph,
      //   startPosition: 0,
      //   endPosition: positionBreakParagraph,
      // );
      // positionBreakParagraph = endPosition;
    }

    final breakParagraph = EndBreakEpubParagraph(
      breakPosition: positionBreakParagraph,
      paragraph: paragraph,
      usedHeight: (paragraphHeight * percentageOfParagraphUsable),
      totalHeight: paragraphHeight,
    );
    return breakParagraph;
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
      ) ?? maxHeight;

      if (currentPage != null &&
          currentPage.chapterIndex != paragraphPage.value.chapterIndex) {
        listPages.add(currentPage);
        currentPage = null;
      }
      print("current paragraph: ${indexParagraph}");
      if (currentPage == null) {
        print("new page");
        final listPagesOfParagraph = getPagesForParagraph(
          paragraph: paragraphPage,
          maxHeight: maxHeight,
          heightParagraph: heightParagraph,
          realHeightParagraph: heightParagraph,
          style: style,
          width: screenSize.width,
        );

        currentPage = listPagesOfParagraph.removeLast();
        if (listPagesOfParagraph.isNotEmpty) {
          listPages.addAll(listPagesOfParagraph);
        }

        if ((currentPage.height) >= maxHeight ||
            indexParagraph == (listParagraphs.length - 1)) {
          listPages.add(currentPage);
          currentPage = null;
        }
        continue;
      } else {
        print("dirty page ${listPages.length}");
        final remainingPageHeight = maxHeight - currentPage.height;

        if (remainingPageHeight >= heightParagraph) {
          print("adding whole paragraph to page");
          currentPage.paragraphsPerPage.add(paragraphPage);
          currentPage = currentPage.copyWith(
            height: (currentPage.height +
                heightParagraph +
                sizeParagraphJump(
                  style.fontSize!,
                  style.height!,
                )),
          );
          if ((currentPage.height) >= maxHeight ||
              indexParagraph == (listParagraphs.length - 1)) {
            listPages.add(currentPage);
            currentPage = null;
            continue;
          }
        } else {
          if (paragraphPage.value.type.isImg ||
              paragraphPage.value.type.isTable ||
              paragraphPage.value.type.isHighTitle) {
            print("adding img/table to page");
            listPages.add(currentPage);
            currentPage = EpubPage(
              paragraphsPerPage: [paragraphPage],
              chapterIndex: paragraphPage.value.chapterIndex,
              height: heightParagraph,
            );

            continue;
          }

          print(
              "This paragraph needs to be cut hp: $heightParagraph currentPageHeight: ${currentPage.height} remainingPageHeight: $remainingPageHeight");
          EndBreakEpubParagraph? endBreakEpubParagraph = calculateNiceEndOfPage(
            paragraph: paragraphPage.value,
            heightPageAvailable: remainingPageHeight,
            paragraphHeight: heightParagraph,
            style: style,
            width: screenSize.width,
          );

          if (endBreakEpubParagraph != null) {
            currentPage = currentPage.copyWith(
              height: (currentPage.height + endBreakEpubParagraph.usedHeight),
            );
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
              style: style,
              width: screenSize.width);

          if (listParagraphPages.isEmpty) {
            continue;
          }
          currentPage = listParagraphPages.removeLast();
          if (listParagraphPages.isNotEmpty) {
            listPages.addAll(listParagraphPages);
          }

          if ((currentPage.height + sizeParagraphJump(style.fontSize!,style.height!, )) >= maxHeight ||
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
    required TextStyle style,
    required double width,
  }) {
    int startPosition = indexBreakPosition ?? 0;
    if (startPosition < 0) {
      startPosition = 0;
    }
    final listPagesParagraph = <EpubPage>[];

    if (paragraph.value.type.isImg) {
      final epubPage = EpubPage(
        paragraphsPerPage: [paragraph],
        chapterIndex: paragraph.value.chapterIndex,
        height: heightParagraph,
      );
      listPagesParagraph.add(epubPage);
      return listPagesParagraph;
    }

    final numPagesForParagraph = (heightParagraph / maxHeight);
    final nRealPages = numPagesForParagraph.floor();

    print("pages: $numPagesForParagraph height Paragraph $heightParagraph");
    if (nRealPages > 0) {
      final percentagePortionParagraph = maxHeight / heightParagraph;

      print(
          "${paragraph.metadata.paragraphIndex}: paragraph used per page: ${percentagePortionParagraph}");
      if (startPosition < 0) {
        print("startPosition: $startPosition");
      }
      final textTotalPortionParagraph =
          (paragraph.value.element.text.substring(startPosition).length *
                  percentagePortionParagraph)
              .floor();

      for (int indexPage = 0; indexPage < nRealPages; indexPage++) {
        try {
          int endPosition = (startPosition + textTotalPortionParagraph).floor();

          // endPosition = calculateBestEndPosition(
          //   paragraph: paragraph.value,
          //   startPosition: startPosition,
          //   endPosition: endPosition,
          // );

          endPosition = getLastParagraphPositionForEndLine(
            positionBreakParagraph: endPosition,
            paragraph: paragraph.value,
            heightPageAvailable: maxHeight,
            style: style,
            width: width,
            startPosition: startPosition,
          );

          paragraph = paragraph.copyWith(
            metadata: paragraph.metadata.copyWith(
              startPosition: startPosition,
              endPosition: endPosition,
            ),
          );

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
      if (startPosition >= (paragraph.value.element.text.length-1)) {
        return listPagesParagraph;
      }
      final textParagraphLeftOver = paragraph.value.element.text.substring(
        startPosition,
      );

      if (textParagraphLeftOver.trim().isEmpty) {
        return listPagesParagraph;
      }
      //Page with leftOvers of paragraph

      final heightParagraphLeftOver = calculateHeightText(
        width,
        style,
        textParagraphLeftOver,
      );

      paragraph = paragraph.copyWith(
        metadata: paragraph.metadata.copyWith(
          startPosition: startPosition,
          endPosition: paragraph.value.element.text.length,
        ),
      );

      epubPage = EpubPage(
        paragraphsPerPage: [paragraph],
        chapterIndex: paragraph.value.chapterIndex,
        height: heightParagraphLeftOver,
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
    if (endPosition - startPosition < 40) {
      return endPosition;
    }

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

  int getLastParagraphPositionForEndLine({
    int startPosition = 0,
    required int positionBreakParagraph,
    required EpubParagraph paragraph,
    required double heightPageAvailable,
    required TextStyle style,
    required double width,
  }) {
    double? previousHeight;

    for (int endPosition = positionBreakParagraph;
        endPosition < (paragraph.element.text.length);) {
      final textHeight = calculateHeightText(
        width,
        style,
        paragraph.element.text.substring(startPosition, endPosition),
      );

      if (textHeight > heightPageAvailable) {
        if (previousHeight == null || previousHeight > heightPageAvailable) {
          print(
              "text needs to be reduced, too big: h: $textHeight ph: $heightPageAvailable");
          endPosition--;
          previousHeight = textHeight;
        } else {
          print(
              "breaking end of position ${endPosition} height-too big: $textHeight");
          positionBreakParagraph = endPosition - 1;
          break;
        }

        break;
      } else {
        if (previousHeight == null || previousHeight < heightPageAvailable) {
          print("text still can grow: h: $textHeight ph: $heightPageAvailable");
          endPosition++;
          previousHeight = textHeight;
        } else {
          positionBreakParagraph = endPosition;
          break;
        }
      }
    }

    if (positionBreakParagraph < 0) {
      positionBreakParagraph = 0;
    }

    if (positionBreakParagraph > (paragraph.element.text.length - 1)) {
      positionBreakParagraph = paragraph.element.text.length;
    }
    return positionBreakParagraph;
  }

  double sizeParagraphJump(double fontSize, double height) => fontSize * height;
}
