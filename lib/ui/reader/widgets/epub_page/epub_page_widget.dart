import 'dart:async';

import 'package:epub_everwise/epub_everwise.dart' hide Image;
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'epub_page_mixin.dart';

class EpubPageWidget extends StatelessWidget with EpubPageMixin {
  const EpubPageWidget({
    super.key,
    required this.images,
    required this.page,
    required this.screenSize,
    required this.style,
    required this.cssContent,
  });
  final Size screenSize;
  final EpubPage page;
  final TextStyle style;
  final Map<String, EpubImageContentFile>? images;
  final Map<String, Map<String, String>> cssContent;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: HtmlWidget(
        _getHtmlContent(),
        textStyle: style,
        customStylesBuilder: (element) => getStylesByTag(
          style: style,
          element: element,
          cssContent: cssContent,
        ),
        customWidgetBuilder: (element) => getWidgetByTag(
          element: element,
          images: images,
          screenSize: screenSize,
        ),
      ),
    );
  }

  String _getHtmlContent() {
    final htmlContent = List.generate(page.paragraphsPerPage.length, (index) {
      String paragraph;
      if (page.paragraphsPerPage[index].metadata.startPosition != null ||
          page.paragraphsPerPage[index].metadata.endPosition != null) {
        paragraph = page.paragraphsPerPage[index].value.element.text.substring(
          page.paragraphsPerPage[index].metadata.startPosition ?? 0,
          page.paragraphsPerPage[index].metadata.endPosition,
        );
        paragraph = "<p color='blue'>$paragraph</p>";
      } else {
        paragraph = page.paragraphsPerPage[index].value.element.outerHtml
            .substring(
              page.paragraphsPerPage[index].metadata.startPosition ?? 0,
              page.paragraphsPerPage[index].metadata.endPosition,
            )
            .replaceAll("<br></br>", "")
            .replaceAll("<p>&nbsp;</p>", "");
      }
      return paragraph;
    });

    return htmlContent.join();
    //if (page.startBreakParagraph != null)
    // "<p>${page.startBreakParagraph!.paragraph.element.text.substring(
    //   page.startBreakParagraph!.startPosition,
    //   page.startBreakParagraph!.endPosition,
    // )} </p>",

    // if (page.endBreakParagraph != null)
    //   "<p>${page.endBreakParagraph!.paragraph.element.text.substring(0, page.endBreakParagraph!.breakPosition).replaceAll("<br></br>", "")}</p>",
    // ].join();
  }
}

