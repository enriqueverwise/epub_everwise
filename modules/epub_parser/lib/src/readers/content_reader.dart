import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'package:epub_parser/src/entities/epub_css_content_file.dart';
import 'package:epub_parser/src/ref_entities/epub_css_content_file_ref.dart';

import '../entities/epub_content_type.dart';
import '../ref_entities/epub_book_ref.dart';
import '../ref_entities/epub_byte_content_file_ref.dart';
import '../ref_entities/epub_content_file_ref.dart';
import '../ref_entities/epub_content_ref.dart';
import '../ref_entities/epub_text_content_file_ref.dart';
import '../schema/opf/epub_manifest_item.dart';

class ContentReader {
  static Future<EpubContentRef> parseContentMap(EpubBookRef bookRef,
      {bool loadImages = true}) async {
    final html = <String, EpubTextContentFileRef>{};
    final css = <String, EpubCssContentFileRef>{};
    final images = <String, EpubByteContentFileRef>{};
    final fonts = <String, EpubByteContentFileRef>{};
    final allFiles = <String, EpubContentFileRef>{};

    bookRef.schema!.package!.Manifest!.Items!
        .forEach((EpubManifestItem manifestItem) {
      final fileName = manifestItem.Href;
      final contentMimeType = manifestItem.MediaType!;
      final contentType = getContentTypeByContentMimeType(contentMimeType);
      switch (contentType) {
        case EpubContentType.CSS:
          final epubTextContentFile = EpubCssContentFileRef(
            epubBookRef: bookRef,
            fileName: Uri.decodeFull(fileName!),
            contentType: contentType,
            contentMimeType: contentMimeType,
          );
          css[fileName] = epubTextContentFile;
          allFiles[fileName] = epubTextContentFile;
          break;
        case EpubContentType.XHTML_1_1:
        case EpubContentType.OEB1_DOCUMENT:
        case EpubContentType.OEB1_CSS:
        case EpubContentType.XML:
        case EpubContentType.DTBOOK:
        case EpubContentType.DTBOOK_NCX:
          final epubTextContentFile = EpubTextContentFileRef(
            epubBookRef: bookRef,
            fileName: Uri.decodeFull(fileName!),
            contentType: contentType,
            contentMimeType: contentMimeType,
          );

          switch (contentType) {
            case EpubContentType.XHTML_1_1:
              html[fileName] = epubTextContentFile;
              break;
            case EpubContentType.DTBOOK:
            case EpubContentType.CSS:
            case EpubContentType.DTBOOK_NCX:
            case EpubContentType.OEB1_DOCUMENT:
            case EpubContentType.XML:
            case EpubContentType.OEB1_CSS:
            case EpubContentType.IMAGE_GIF:
            case EpubContentType.IMAGE_JPEG:
            case EpubContentType.IMAGE_PNG:
            case EpubContentType.IMAGE_SVG:
            case EpubContentType.IMAGE_BMP:
            case EpubContentType.FONT_TRUETYPE:
            case EpubContentType.FONT_OPENTYPE:
            case EpubContentType.OTHER:
              break;
          }
          allFiles[fileName] = epubTextContentFile;
          break;
        default:
          final epubByteContentFile = EpubByteContentFileRef(
            epubBookRef: bookRef,
            fileName: Uri.decodeFull(fileName!),
            contentType: contentType,
            contentMimeType: contentMimeType,
          );
          switch (contentType) {
            case EpubContentType.IMAGE_GIF:
            case EpubContentType.IMAGE_JPEG:
            case EpubContentType.IMAGE_PNG:
            case EpubContentType.IMAGE_SVG:
            case EpubContentType.IMAGE_BMP:
              images[fileName] = epubByteContentFile;
              break;
            case EpubContentType.FONT_TRUETYPE:
            case EpubContentType.FONT_OPENTYPE:
              fonts[fileName] = epubByteContentFile;
              break;
            case EpubContentType.CSS:
            case EpubContentType.XHTML_1_1:
            case EpubContentType.DTBOOK:
            case EpubContentType.DTBOOK_NCX:
            case EpubContentType.OEB1_DOCUMENT:
            case EpubContentType.XML:
            case EpubContentType.OEB1_CSS:
            case EpubContentType.OTHER:
              break;
          }
          allFiles[fileName] = epubByteContentFile;
          break;
      }
    });
    return EpubContentRef(
      html: html,
      css: css,
      images: images,
      fonts: fonts,
      allFiles: allFiles,
    );
  }

  static EpubContentType getContentTypeByContentMimeType(
      String contentMimeType) {
    switch (contentMimeType.toLowerCase()) {
      case 'application/xhtml+xml':
      case 'text/html':
        return EpubContentType.XHTML_1_1;
      case 'application/x-dtbook+xml':
        return EpubContentType.DTBOOK;
      case 'application/x-dtbncx+xml':
        return EpubContentType.DTBOOK_NCX;
      case 'text/x-oeb1-document':
        return EpubContentType.OEB1_DOCUMENT;
      case 'application/xml':
        return EpubContentType.XML;
      case 'text/css':
        return EpubContentType.CSS;
      case 'text/x-oeb1-css':
        return EpubContentType.OEB1_CSS;
      case 'image/gif':
        return EpubContentType.IMAGE_GIF;
      case 'image/jpeg':
        return EpubContentType.IMAGE_JPEG;
      case 'image/png':
        return EpubContentType.IMAGE_PNG;
      case 'image/svg+xml':
        return EpubContentType.IMAGE_SVG;
      case 'image/bmp':
        return EpubContentType.IMAGE_BMP;
      case 'font/truetype':
        return EpubContentType.FONT_TRUETYPE;
      case 'font/opentype':
        return EpubContentType.FONT_OPENTYPE;
      case 'application/vnd.ms-opentype':
        return EpubContentType.FONT_OPENTYPE;
      default:
        return EpubContentType.OTHER;
    }
  }
}
