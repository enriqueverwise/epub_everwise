import 'package:epub_everwise/data/epub_cfi_reader.dart';
import 'package:html/dom.dart' as dom;

import 'models/paragraph.dart';

export 'package:epub_parser/epub_parser.dart' hide Image;

List<EpubChapter> parseChapters(EpubBook epubBook) =>
    epubBook.chapters!.fold<List<EpubChapter>>(
      [],
      (acc, next) {
        acc.add(next);
        next.subChapters!.forEach(acc.add);
        return acc;
      },
    );

List<dom.Element> convertDocumentToElements(dom.Document document) =>
    document.getElementsByTagName('body').first.children;

List<dom.Element> _removeAllDiv(List<dom.Element> elements) {
  final List<dom.Element> result = [];

  for (final node in elements) {
    if (node.localName == 'div' && node.children.length > 1) {
      result.addAll(_removeAllDiv(node.children));
    } else {
      result.add(node);
    }
  }

  return result;
}

ParseParagraphsResult parseParagraphs(
  List<EpubChapter> chapters,
  EpubContent? content,
) {
  String? filename = '';
  final List<int> chapterIndexes = [];
  final paragraphs = chapters.fold<List<EpubParagraph>>(
    [],
    (listParagraph, next) {
      List<dom.Element> elmList = [];
      if (filename != next.contentFileName) {
        filename = next.contentFileName;
        final document = EpubCfiReader().chapterDocument(next);
        if (document != null) {
          final result = convertDocumentToElements(document);
          elmList = _removeAllDiv(result);
        }
      }

      if (next.anchor == null) {
        // last element from document index as chapter index
        chapterIndexes.add(listParagraph.length);
        listParagraph.addAll(elmList.map((element) => EpubParagraph(
              element,
              chapterIndexes.length - 1,
          getTypeParagraph(element),
            )));
        return listParagraph;
      } else {
        final index = elmList.indexWhere(
          (elm) => elm.outerHtml.contains(
            'id="${next.anchor}"',
          ),
        );
        if (index == -1) {
          chapterIndexes.add(listParagraph.length);
          listParagraph.addAll(elmList.map((element) => EpubParagraph(
                element,
                chapterIndexes.length - 1,
            getTypeParagraph(element),
              )));
          return listParagraph;
        }

        chapterIndexes.add(index);
        listParagraph.addAll(elmList.map((element) => EpubParagraph(
              element,
              chapterIndexes.length - 1,
          getTypeParagraph(element),
            )));
        return listParagraph;
      }
    },
  );

  return ParseParagraphsResult(paragraphs, chapterIndexes);
}

TypeParagraph getTypeParagraph(dom.Element element) {
  final isImg =
      element.outerHtml.contains("img") || element.outerHtml.contains("image");

  if (isImg) return TypeParagraph.image;

  switch (element.localName) {
    case 'h1':
      return TypeParagraph.h1;
    case 'h2':
      return TypeParagraph.h2;
    case 'h3':
      return TypeParagraph.h3;
    case 'h4':
      return TypeParagraph.h4;
    case 'h5':
      return TypeParagraph.h5;
    case 'h6':
      return TypeParagraph.h6;
    default:
      return TypeParagraph.text;
  }
}

class ParseParagraphsResult {
  ParseParagraphsResult(this.flatParagraphs, this.chapterIndexes);

  final List<EpubParagraph> flatParagraphs;
  final List<int> chapterIndexes;
}
