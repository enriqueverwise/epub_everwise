import 'package:equatable/equatable.dart';
import 'package:html/dom.dart' as dom;

enum TypeParagraph {
  image,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  text,
  table,
  jump;

  bool get isImg => this == image;
  bool get isText => this == text;
  bool get isTable => this == table;
  bool get isHighTitle => this == h1 || this == h2;
  bool get isTitle =>
      this == h1 ||
      this == h2 ||
      this == h3 ||
      this == h4 ||
      this == h5 ||
      this == h6;
}

class EpubParagraph extends Equatable {
  const EpubParagraph(
    this.element,
    this.chapterIndex,
    this.type,
  );

  final dom.Element element;
  final int chapterIndex;
  final TypeParagraph type;
  @override
  List<Object?> get props => [
        element,
        chapterIndex,
        type,
      ];
}
