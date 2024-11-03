import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import '../ref_entities/epub_book_ref.dart';
import '../ref_entities/epub_byte_content_file_ref.dart';
import '../schema/opf/epub_manifest_item.dart';
import '../schema/opf/epub_metadata_meta.dart';

class BookCoverReader {
  static Future<Uint8List?> readBookCover(EpubBookRef bookRef) async {
    var metaItems = bookRef.schema!.package!.Metadata!.MetaItems;
    if (metaItems == null || metaItems.isEmpty) return null;

    var coverMetaItem = metaItems.firstWhereOrNull(
        (EpubMetadataMeta metaItem) =>
            (metaItem.Name != null &&
                metaItem.Name!.toLowerCase() == 'cover') ||
            (metaItem.Attributes?["name"] != null &&
                metaItem.Attributes!["name"]!.toLowerCase().contains("cover")));
    if (coverMetaItem == null) return null;

    final content =
        (coverMetaItem.Content != null && coverMetaItem.Content!.isNotEmpty)
            ? coverMetaItem.Content
            : coverMetaItem.Attributes?["content"];
    if (content == null || content.isEmpty) {
      throw Exception(
          'Incorrect EPUB metadata: cover item content is missing.');
    }

    var coverManifestItem = bookRef.schema!.package!.Manifest!.Items!
        .firstWhereOrNull((EpubManifestItem manifestItem) =>
            manifestItem.Id!.toLowerCase() == content.toLowerCase());
    if (coverManifestItem == null) {
      throw Exception(
          'Incorrect EPUB manifest: item with ID = \"${content}\" is missing.');
    }

    EpubByteContentFileRef? coverImageContentFileRef;
    if (!bookRef.content!.images!.containsKey(coverManifestItem.Href)) {
      throw Exception(
          'Incorrect EPUB manifest: item with href = \"${coverManifestItem.Href}\" is missing.');
    }

    coverImageContentFileRef = bookRef.content!.images![coverManifestItem.Href];
    final coverImageContent =
        await coverImageContentFileRef!.readContentAsBytes();
    return coverImageContent;
  }
}
