
import 'epub_content_file.dart';

class EpubCssContentFile extends EpubContentFile {
  final Map<String, Map<String, String>>? cssContent;

  EpubCssContentFile({
    required super.fileName,
    required super.contentType,
    required super.contentMimeType,
    required this.cssContent,
  });

  @override
  List<Object?> get props => [
    super.fileName,
    super.contentType,
    super.contentMimeType,
    cssContent,
  ];
}
