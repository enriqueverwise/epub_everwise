import 'package:epub_everwise/data/epub_cfi_reader.dart';
import 'package:epub_everwise/data/models/chapter_view_value.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/domain/entities/epub_reader_content.dart';
import 'package:epub_everwise/ui/reader/epub_reader_view.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
export 'package:epub_parser/epub_parser.dart' hide Image;

typedef ExternalLinkPressed = bool Function(String href);

const minTrailingEdge = 0.55;
const minLeadingEdge = -0.05;

class EpubGestureDetectorView extends StatelessWidget {
  EpubGestureDetectorView({
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
  final FocusNode _focusNode = FocusNode();

  String? selectedText;
  int? chapterIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tapArea = size.width * 0.3;

    return BlocListener<EpubReaderCubit, EpubReaderState>(
      listener: (context, state) {
        print(
            "Read chapter ${state.chapterContent.listPages[state.pageIndex].chapterIndex}");
        chapterIndex =
            state.chapterContent.listPages[state.pageIndex].chapterIndex;
      },
      child: SelectionArea(
        focusNode: _focusNode,
        onSelectionChanged: (value) {
          selectedText = value?.plainText;
        },
        contextMenuBuilder: (context, editableTextState) {
          final List<ContextMenuButtonItem> buttonItems =
              editableTextState.contextMenuButtonItems;
          buttonItems.insert(
            0,
            ContextMenuButtonItem(
              label: 'Create post',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Create post'),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Text(" “ ${selectedText ?? ''} ” "),
                                  SizedBox(height: 10),
                                  Text("Chapter $chapterIndex"),
                                ],
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Post created",
                                      ),
                                    ),
                                  );
                                },
                                child: Text("Post"))
                          ],
                        )),
                  ),
                );
              },
            ),
          );
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        child: GestureDetector(
          onTapUp: (details) {
            selectedText = null;
            _focusNode.unfocus();
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
        ),
      ),
    );
  }
}
