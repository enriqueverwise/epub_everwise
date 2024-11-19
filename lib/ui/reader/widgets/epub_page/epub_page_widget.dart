import 'dart:async';

import 'package:epub_everwise/domain/entities/epub_style.dart';
import 'package:epub_everwise/epub_everwise.dart' hide Image;
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final EpubStyle style;
  final Map<String, EpubImageContentFile>? images;
  final Map<String, Map<String, String>> cssContent;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: HtmlWidget(
        _getHtmlContent(),
        textStyle: style.textStyle,
        customStylesBuilder: (element) => getStylesByTag(
          style: style.textStyle,
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
        final tag =
            page.paragraphsPerPage[index].value.element.localName ?? "p";
        paragraph = "<$tag>$paragraph</$tag>";

        print(
            "paragraph: ${page.paragraphsPerPage[index].metadata.endPosition}");
      } else {
        paragraph = page.paragraphsPerPage[index].value.element.outerHtml
            .replaceAll("</br>", "")
            .replaceAll("<br/>", "")
            .replaceAll("<br>", "")
            .replaceAll("<p>&nbsp;</p>", "");
      }
      return paragraph;
    });

    final divider = style.showDevDivider ? "<br/>------------" : "<br/>";
    return htmlContent.join(divider);
  }
}
