import 'package:equatable/equatable.dart';
import 'epub_content_type.dart';

abstract class EpubContentFile extends Equatable {
  final String? fileName;
  final EpubContentType? contentType;
  final String? contentMimeType;
  EpubContentFile({
    required this.fileName,
    required this.contentType,
    required this.contentMimeType,
  });
}
