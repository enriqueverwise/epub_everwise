import 'package:epub_everwise/data/epub_cfi_reader.dart';
import 'package:epub_everwise/data/models/chapter_view_value.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/ui/reader/epub_reader_view.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
export 'package:epub_parser/epub_parser.dart' hide Image;

typedef ExternalLinkPressed = bool Function(String href);

const minTrailingEdge = 0.55;
const minLeadingEdge = -0.05;

class EpubGestureDetectorView extends StatelessWidget {
  const EpubGestureDetectorView({
    this.onExternalLinkPressed,
    required this.epubBook,
    required this.content,
    this.shrinkWrap = false,
    super.key,
  });

  final ExternalLinkPressed? onExternalLinkPressed;
  final bool shrinkWrap;
  final EpubBook epubBook;
  final EpubBookContent content;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tapArea = size.width * 0.3;
    return GestureDetector(
      onTapUp: (details) {
        final halfScreen = MediaQuery.sizeOf(context).width / 2;
        if (details.localPosition.dx > (halfScreen + tapArea)) {
          context
              .read<EpubReaderCubit>()
              .onPageChange(EpubChangeDirection.next);
        } else if (details.localPosition.dx < (halfScreen - tapArea)) {
          context
              .read<EpubReaderCubit>()
              .onPageChange(EpubChangeDirection.back);
        } else {
          context.read<EpubReaderCubit>().updatePanelVisibility();
        }
      },
      child: EpubReaderView(
        content: content,
        epubBook: epubBook,
      ),
    );
  }
}
