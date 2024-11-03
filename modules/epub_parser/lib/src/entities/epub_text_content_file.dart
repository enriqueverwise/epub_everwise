
import 'epub_content_file.dart';

class EpubTextContentFile extends EpubContentFile {
  final String? content;

  EpubTextContentFile({
    required super.fileName,
    required super.contentType,
    required super.contentMimeType,
    required this.content,
  });

  @override
  List<Object?> get props => [
    super.fileName,
    super.contentType,
    super.contentMimeType,
    content,
  ];
}
