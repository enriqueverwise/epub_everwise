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

List<dom.Node> convertDocumentToElements(dom.Document document) =>
    document.getElementsByTagName('body').first.nodes;

List<dom.Element> _removeContainers(List<dom.Node> elements) {
  final List<dom.Element> result = [];

  for (final node in elements) {
    if (node is dom.Element && isJump(node)) {
      continue;
    }
    if (node.children.length > 1) {
      if (node is dom.Element) {
        if (_isTextElement(node)) {
          for (int childIndex = 0;
              childIndex < node.children.length;
              childIndex++) {
            if (!_isTextElement(node)) {
              result.add(node.children[childIndex]);
              node.children.removeAt(childIndex);
            }
          }
          result.add(node);
          continue;
        }else{
          result.addAll(_removeContainers(node.nodes));
        }

       // result.addAll(_removeContainers(node.nodes));
       //  if (node.children
       //      .where((element) => element.localName == 'p')
       //      .isNotEmpty) result.addAll(_removeContainers(node.nodes));
       //  if (node.localName != 'p') {
       //    result.addAll(_removeContainers(node.nodes));
       //  } else {
       //    result.add(node);
       //  }
      } else {
        if (node.nodeType == dom.Node.TEXT_NODE &&
            node.text?.trim().isNotEmpty == true) {
          final element = dom.Element.tag('p');
          element.text = node.text;
          result.add(element);
        }
      }
    } else {
      if (node is dom.Element) {
        result.addAll([node]);
      } else {
        if (node.nodeType == dom.Node.TEXT_NODE &&
            node.text?.trim().isNotEmpty == true) {
          final element = dom.Element.tag('p');
          element.text = node.text;
          result.add(element);
        }
      }
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
        final document = EpubCfiReader.empty().chapterDocument(next);
        if (document != null) {
          final result = convertDocumentToElements(document);
          try {
            elmList = _removeContainers(result);
          } catch (e) {
            print(e);
          }
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

bool _isTextElement(dom.Element? node) {
  final textualTags = [
    'p',
    'b',
    'i',
    'span',
    'em',
    'strong',
    'u',
    's',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
  ];
  if (node == null) return false;
  return textualTags.contains(node.localName);
}

TypeParagraph getTypeParagraph(dom.Element element) {
  final isImg = element.outerHtml.contains("<img") ||
      element.outerHtml.contains("<image");

  final isTable = element.localName?.contains("table") ?? false;

  final isJump = element.localName?.contains("br") ?? false;

  if (isTable) return TypeParagraph.table;

  if (isJump) return TypeParagraph.jump;

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

bool isJump(dom.Element element) {
  return element.localName == 'br';
}

class ParseParagraphsResult {
  ParseParagraphsResult(this.flatParagraphs, this.chapterIndexes);

  final List<EpubParagraph> flatParagraphs;
  final List<int> chapterIndexes;
}

// class Hum {
//   static dom.Element _createParagraph(String text, {String tag = 'p'}) {
//     final pElement = dom.Element.tag('p');
//     pElement.append(dom.Text(text));
//     return pElement;
//   }
//
//   // static List<dom.Element> flatElements(List<dom.Node> nodes) {
//   //   final List<dom.Element> result = [];
//   //
//   //   if (nodes.isEmpty) {
//   //     return result;
//   //   }
//   //
//   //   if (nodes.length == 1 &&
//   //       nodes.first.nodeType == dom.Node.TEXT_NODE &&
//   //       nodes.first.parentNode == null) {
//   //     final trimmedText = nodes.first.text?.trim() ?? '';
//   //     if (trimmedText.isNotEmpty) {
//   //       result.add(_createParagraph(trimmedText));
//   //     }
//   //     return result;
//   //   }
//   //
//   //   if (nodes
//   //       .whereType<dom.Element>()
//   //       .where((element) => element.localName)
//   //       .isNotEmpty) {
//   //     return nodes.whereType<dom.Element>().toList();
//   //   }
//   //
//   //   for (final node in nodes) {
//   //     if (node is dom.Element) {
//   //       result.add(node);
//   //     } else if (node is dom.Text) {
//   //       final trimmedText = node.text.trim() ?? '';
//   //       if (trimmedText.isNotEmpty) {
//   //         result.add(_createParagraph(trimmedText));
//   //       }
//   //     }
//   //   }
//   // }
//
//   static List<dom.Element> flattenTextAndRemoveContainers(
//       List<dom.Node> elements) {
//     final List<dom.Element> result = [];
//
//     for (final child in elements) {
//       // Si el nodo es texto, lo añadimos directamente
//       final type = child.nodeType;
//       if (child is dom.Element && isJump(child)) {
//         continue;
//       }
//       if (child.nodeType == dom.Node.TEXT_NODE) {
//         final trimmedText = child.text?.trim() ?? "";
//         if (trimmedText.isNotEmpty) {
//           result.add(_createParagraph(trimmedText,
//               tag: child.parent?.localName ?? 'p')); // Crea un <p> con el texto
//         }
//       } else if (child is dom.Element) {
//         // Si el nodo es un elemento (por ejemplo, <div>, <h1>, <p>, <img>, etc.)
//         final node = child;
//         if (isJump(child)) {
//           continue;
//         }
//         // Si el nodo es una etiqueta de texto (p, b, i, span, h1, p, etc.), lo mantenemos
//         if (_isTextElement(child)) {
//           // Aplanamos cualquier hijo que pueda ser una etiqueta contenedora
//
//           if (child.children.isEmpty ||
//               child.children
//                   .where((node) => (!_isTextElement(node) &&
//                       node.nodeType != dom.Node.TEXT_NODE))
//                   .isEmpty) {
//             result.add(child);
//           } else {
//             final flattenedChildren =
//                 flattenTextAndRemoveContainers(node.nodes);
//             result.add(_rebuildElement(node, flattenedChildren));
//           }
//         } else if (_isContainerElement(node)) {
//           // Si el nodo es una etiqueta de contenedor (div, section, etc.), la "aplanamos"
//           // Aplanamos los hijos de contenedores y los agregamos al resultado
//           result.addAll(flattenTextAndRemoveContainers(node.nodes));
//         } else {
//           result.add(node);
//         }
//       }
//     }
//
//     return result;
//   }
//
//   static bool isJump(dom.Element element) {
//     return element.localName == 'br';
//   }
//
// // Verifica si el nodo es una etiqueta relacionada con texto
//   static bool _isTextElement(dom.Element? node) {
//     final textualTags = [
//       'p',
//       'b',
//       'i',
//       'span',
//       'em',
//       'strong',
//       'u',
//       's',
//       'h1',
//       'h2',
//       'h3',
//       'h4',
//       'h5',
//       'h6',
//     ];
//     if (node == null) return false;
//     return textualTags.contains(node.localName);
//   }
//
// // Verifica si el nodo es una etiqueta de contenedor
//   static bool _isContainerElement(dom.Element node) {
//     final containerTags = [
//       'div',
//       'section',
//       'article',
//       'nav',
//       'header',
//       'footer'
//     ];
//     return containerTags.contains(node.localName);
//   }
//
// // Reconstruye el nodo con su contenido plano, sin etiquetas de contenedor
//   static dom.Element _rebuildElement(
//       dom.Element node, List<dynamic> flattenedChildren) {
//     final newElement = dom.Element.tag(node.localName!);
//     for (var child in flattenedChildren) {
//       if (child is String) {
//         newElement.text = child;
//       } else if (child is dom.Element) {
//         newElement.append(child);
//       }
//     }
//     return newElement;
//   }
// }
