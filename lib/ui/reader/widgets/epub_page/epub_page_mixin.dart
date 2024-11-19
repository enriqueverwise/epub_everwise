import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;

import '../../../../data/models/chapter_view_value.dart';

mixin EpubPageMixin {
  Map<String, String> getStylesByTag({
    required TextStyle style,
    required dom.Element element,
    required Map<String, Map<String, String>> cssContent,
  }) {
    final styleMap = <String, String>{};
    if (element.localName == "h1" ||
        element.localName == "h2" ||
        element.localName == "h3") {
      styleMap.addAll({
        "text-align": "center",
        'font-size': '${style.fontSize! + 5}px',
        'font-weight': 'bold',
      });
    } else {
      styleMap.addAll(getStyleFromCssContent(element.className, cssContent));
    }
    if (element.localName == "p" && !styleMap.containsKey("text-align")) {
      styleMap.addAll({"text-align": "justify;"});
    }
    if(element.localName == "table") {
      styleMap.addAll({
        'font-size': '${style.fontSize! - 3}px',
        'font-weight': 'normal',
        'border': '1',
      });
    }
    return styleMap;
  }

  Map<String, String> getStyleFromCssContent(
      String className, Map<String, Map<String, String>> cssContent) {
    final styleMap = <String, String>{};
    if (className.isNotEmpty && cssContent.isNotEmpty) {
      final css = cssContent.entries
          .where(
            (entry) => entry.key.contains(
              className,
            ),
          )
          .map((entry) => entry.value)
          .toList();

      for (final cssElement in css) {
        cssElement.forEach((key, value) {
          if (key.contains("text-align") || key.contains("font-weight")) {
            styleMap.addAll({key: value});
          }
        });
      }
    }
    return styleMap;
  }

  Widget? getWidgetByTag({
    required dom.Element element,
    required Map<String, EpubImageContentFile>? images,
    required Size screenSize,
  }) {
    if (element.localName == "img" || element.localName == "image") {
      String? url = element.attributes['src'];
      url ??= element.attributes.entries
          .where((entry) => entry.key.toString().contains("href"))
          .firstOrNull
          ?.value;
      url = url?.replaceAll("../", '');
      final content = Uint8List.fromList(images![url]?.content ?? []);
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.width,
            maxHeight: screenSize.height,
          ),
          child: ExtendedImage(
            image: MemoryImage(content),
            handleLoadingProgress: true,
          ),
        ),
      );
    }
    return null;
  }
}
