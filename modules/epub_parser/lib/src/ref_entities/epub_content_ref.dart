import 'package:equatable/equatable.dart';
import 'epub_byte_content_file_ref.dart';
import 'epub_content_file_ref.dart';
import 'epub_css_content_file_ref.dart';
import 'epub_text_content_file_ref.dart';

class EpubContentRef extends Equatable {
  final Map<String, EpubTextContentFileRef>? html;
  final Map<String, EpubCssContentFileRef>? css;
  final Map<String, EpubByteContentFileRef>? images;
  final Map<String, EpubByteContentFileRef>? fonts;
  final Map<String, EpubContentFileRef>? allFiles;

  EpubContentRef({
    required this.html,
    required this.css,
    required this.images,
    required this.fonts,
    required this.allFiles,
  });

  @override
  List<Object?> get props => [
    html,
    css,
    images,
    fonts,
    allFiles,
  ];
}
