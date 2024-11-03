import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'package:epub_parser/src/ref_entities/epub_css_content_file_ref.dart';
import 'package:image/image.dart';
import 'package:image_size_getter/image_size_getter.dart';

import 'entities/epub_book.dart';
import 'entities/epub_byte_content_file.dart';
import 'entities/epub_chapter.dart';
import 'entities/epub_content.dart';
import 'entities/epub_content_file.dart';
import 'entities/epub_content_image.dart';
import 'entities/epub_css_content_file.dart';
import 'entities/epub_text_content_file.dart';
import 'readers/content_reader.dart';
import 'readers/schema_reader.dart';
import 'ref_entities/epub_book_ref.dart';
import 'ref_entities/epub_byte_content_file_ref.dart';
import 'ref_entities/epub_chapter_ref.dart';
import 'ref_entities/epub_content_file_ref.dart';
import 'ref_entities/epub_content_ref.dart';
import 'ref_entities/epub_text_content_file_ref.dart';
import 'schema/opf/epub_metadata_creator.dart';

/// A class that provides the primary interface to read Epub files.
///
/// To open an Epub and load all data at once use the [readBook()] method.
///
/// To open an Epub and load only basic metadata use the [openBook()] method.
/// This is a good option to quickly load text-based metadata, while leaving the
/// heavier lifting of loading images and main content for subsequent operations.
///
/// ## Example
/// ```dart
/// // Read the basic metadata.
/// EpubBookRef epub = await EpubReader.openBook(epubFileBytes);
/// // Extract values of interest.
/// String title = epub.Title;
/// String author = epub.Author;
/// var metadata = epub.Schema.Package.Metadata;
/// String genres = metadata.Subjects.join(', ');
/// ```
class EpubReader {
  /// Loads basics metadata.
  ///
  /// Opens the book asynchronously without reading its main content.
  /// Holds the handle to the EPUB file.
  ///
  /// Argument [bytes] should be the bytes of
  /// the epub file you have loaded with something like the [dart:io] package's
  /// [readAsBytes()].
  ///
  /// This is a fast and convenient way to get the most important information
  /// about the book, notably the [Title], [Author] and [AuthorList].
  /// Additional information is loaded in the [Schema] property such as the
  /// Epub version, Publishers, Languages and more.
  static Future<EpubBookRef> openBook(FutureOr<List<int>> bytes) async {
    List<int> loadedBytes;
    if (bytes is Future) {
      loadedBytes = await bytes;
    } else {
      loadedBytes = bytes;
    }

    var epubArchive = ZipDecoder().decodeBytes(loadedBytes);

    final schema = await SchemaReader.readSchema(epubArchive);
    final title = schema.package!.Metadata!.Titles!
        .firstWhere((String name) => true, orElse: () => '');
    final authorList = schema.package!.Metadata!.Creators!
        .map((EpubMetadataCreator creator) => creator.Creator)
        .toList();
    final author = authorList.join(', ');
    final epubBookRef = EpubBookRef(
      epubArchive: epubArchive,
      title: title,
      author: author,
      authorList: authorList,
      schema: schema,
      content: null,
    );
    final content = await ContentReader.parseContentMap(epubBookRef);
    return epubBookRef.copyWith(
      content: content,
    );
  }

  /// Opens the book asynchronously and reads all of its content into the memory. Does not hold the handle to the EPUB file.
  static Future<EpubBook> readBook(FutureOr<List<int>> bytes) async {
    List<int> loadedBytes;
    if (bytes is Future) {
      loadedBytes = await bytes;
    } else {
      loadedBytes = bytes;
    }

    var epubBookRef = await openBook(loadedBytes);
    final schema = epubBookRef.schema;
    final title = epubBookRef.title ?? 'untitled';
    final authorList = epubBookRef.authorList;
    final author = epubBookRef.author ?? 'no Author';

    final epubBookInfo = EpubBookInfo(
      title: title,
      author: author,
    );

    final content = await readContent(epubBookRef.content!);
    final coverImage = await epubBookRef.readCover();
    final chapterRefs = await epubBookRef.getChapters();
    final listChapters = await readChapters(chapterRefs);

    return EpubBook(
      epubBookInfo: epubBookInfo,
      schema: schema,
      content: content,
      coverImage: coverImage,
      chapters: listChapters,
    );
  }

  static Future<EpubContent> readContent(EpubContentRef contentRef) async {
    final html = await readTextContentFiles(contentRef.html!);
    final css = await readCssContentFiles(contentRef.css!);
    final images = await readImageContentFiles(contentRef.images!);
    final fonts = await readByteContentFiles(contentRef.fonts!);
    final allFiles = <String, EpubContentFile>{};

    final epubContent = EpubContent(
      html: html,
      css: css,
      images: images,
      fonts: fonts,
      allFiles: allFiles,
    );
    epubContent.html!.forEach((String? key, EpubTextContentFile value) {
      epubContent.allFiles![key!] = value;
    });
    epubContent.css!.forEach((String? key, EpubCssContentFile value) {
      epubContent.allFiles![key!] = value;
    });

    epubContent.images!.forEach((String? key, EpubImageContentFile value) {
      epubContent.allFiles![key!] = value;
    });
    epubContent.fonts!.forEach((String? key, EpubByteContentFile value) {
      epubContent.allFiles![key!] = value;
    });

    await Future.forEach(contentRef.allFiles!.keys, (dynamic key) async {
      if (!epubContent.allFiles!.containsKey(key)) {
        epubContent.allFiles![key] =
            await readByteContentFile(contentRef.allFiles![key]!);
      }
    });

    return epubContent;
  }

  static Future<Map<String, EpubTextContentFile>> readTextContentFiles(
      Map<String, EpubTextContentFileRef> textContentFileRefs) async {
    final mapEpubTextContentFile = <String, EpubTextContentFile>{};

    await Future.forEach(textContentFileRefs.keys, (dynamic key) async {
      EpubContentFileRef value = textContentFileRefs[key]!;
      final fileName = value.fileName;
      final contentType = value.contentType;
      final contentMimeType = value.contentMimeType;
      final content = await value.readContentAsText();
      mapEpubTextContentFile.addAll({
        key: EpubTextContentFile(
          fileName: fileName,
          contentType: contentType,
          contentMimeType: contentMimeType,
          content: content,
        )
      });
    });
    return mapEpubTextContentFile;
  }

  static Future<Map<String, EpubCssContentFile>> readCssContentFiles(
      Map<String, EpubCssContentFileRef> textContentFileRefs) async {
    final mapEpubTextContentFile = <String, EpubCssContentFile>{};

    await Future.forEach(textContentFileRefs.keys, (dynamic key) async {
      EpubContentFileRef value = textContentFileRefs[key]!;
      final fileName = value.fileName;
      final contentType = value.contentType;
      final contentMimeType = value.contentMimeType;
      final content = await value.readContentAsText();
      final style = parse(content);
      final contentMap = getCssMapFromFile(style);
      mapEpubTextContentFile.addAll({
        key: EpubCssContentFile(
          fileName: fileName,
          contentType: contentType,
          contentMimeType: contentMimeType,
          cssContent: contentMap,
        )
      });
    });
    return mapEpubTextContentFile;
  }

  static Future<Map<String, EpubByteContentFile>> readByteContentFiles(
      Map<String, EpubByteContentFileRef> byteContentFileRefs) async {
    var result = <String, EpubByteContentFile>{};
    await Future.forEach(byteContentFileRefs.keys, (dynamic key) async {
      result[key] = await readByteContentFile(byteContentFileRefs[key]!);
    });
    return result;
  }

  static Future<Map<String, EpubImageContentFile>> readImageContentFiles(
      Map<String, EpubByteContentFileRef> byteContentFileRefs) async {
    var result = <String, EpubImageContentFile>{};
    await Future.forEach(byteContentFileRefs.keys, (dynamic key) async {
      final bytes = await readByteContentFile(byteContentFileRefs[key]!);
      final imgSize = await ImageSizeGetter.getSizeAsync(
        AsyncImageInput.input(
          MemoryInput(
            Uint8List.fromList(
              bytes.content ?? [],
            ),
          ),
        ),
      );

      result[key] = EpubImageContentFile(
        fileName: bytes.fileName,
        contentType: bytes.contentType,
        contentMimeType: bytes.contentMimeType,
        content: bytes.content,
        height: imgSize.height.toDouble(),
        width: imgSize.width.toDouble(),
      );
    });

    return result;
  }

  static Future<EpubByteContentFile> readByteContentFile(
      EpubContentFileRef contentFileRef) async {
    final fileName = contentFileRef.fileName;
    final contentType = contentFileRef.contentType;
    final contentMimeType = contentFileRef.contentMimeType;
    final content = await contentFileRef.readContentAsBytes();

    return EpubByteContentFile(
      fileName: fileName,
      contentType: contentType,
      contentMimeType: contentMimeType,
      content: content,
    );
  }

  static Future<List<EpubChapter>> readChapters(
      List<EpubChapterRef> chapterRefs) async {
    final listChapters = <EpubChapter>[];
    await Future.forEach(chapterRefs, (EpubChapterRef chapterRef) async {
      final title = chapterRef.title;
      final contentFileName = chapterRef.contentFileName;
      final anchor = chapterRef.anchor;
      final htmlContent = await chapterRef.readHtmlContent();
      final subChapters = await readChapters(chapterRef.subChapters ?? []);
      final chapter = EpubChapter(
        title: title,
        contentFileName: contentFileName,
        anchor: anchor,
        htmlContent: htmlContent,
        subChapters: subChapters,
      );

      listChapters.add(chapter);
    });
    return listChapters;
  }

  static Map<String, Map<String, String>> getCssMapFromFile(
      StyleSheet stylesheet) {
    // Create a map to store CSS rules
    final cssMap = <String, Map<String, String>>{};

    // Manually populate cssMap from the parsed stylesheet
    for (var rule in stylesheet.topLevels) {
      if (rule is RuleSet) {
        final selector = rule.selectorGroup?.span?.text.trim();

        if (selector == null) {
          continue;
        }
        // Initialize a map for properties of this selector
        cssMap[selector] = {};

        // Populate the properties map for this selector
        for (var declaration in rule.declarationGroup.declarations) {
          final declarationText = declaration.span?.text;
          final parts = declarationText?.split(':');
          if (parts != null && parts.length == 2) {
            final property = parts[0].trim();
            final value = parts[1].replaceAll(';', '').trim();
            cssMap[selector]![property] = value;
          }
        }
      }
    }
    return cssMap;
  }
}
