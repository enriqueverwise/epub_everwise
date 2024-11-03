
import 'package:epub_parser/src/entities/epub_content_file.dart';

class EpubImageContentFile extends EpubContentFile {
  final List<int>? content;
  final double width;
  final double height;

  EpubImageContentFile({
    required super.fileName,
    required super.contentType,
    required super.contentMimeType,
    required this.content,
    required this.height,
    required this.width,
  });

  @override
  List<Object?> get props => [
    super.fileName,
    super.contentType,
    super.contentMimeType,
    content,
    height,
    width,
  ];
}