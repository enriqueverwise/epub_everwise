
import 'epub_content_file.dart';

class EpubByteContentFile extends EpubContentFile {
  final List<int>? content;

  EpubByteContentFile({
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
