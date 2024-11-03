import 'package:equatable/equatable.dart';

import 'epub_byte_content_file.dart';
import 'epub_content_file.dart';
import 'epub_content_image.dart';
import 'epub_css_content_file.dart';
import 'epub_text_content_file.dart';

class EpubContent extends Equatable {
  final Map<String, EpubTextContentFile>? html;
  final Map<String, EpubCssContentFile>? css;
  final Map<String, EpubImageContentFile>? images;
  final Map<String, EpubByteContentFile>? fonts;
  final Map<String, EpubContentFile>? allFiles;

  EpubContent({
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
