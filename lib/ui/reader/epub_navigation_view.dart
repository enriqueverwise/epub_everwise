import 'package:collection/collection.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/chapter_view_value.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:epub_everwise/ui/reader/widgets/epub_style_manager_widget.dart';
import 'package:epub_everwise/ui/reader/widgets/page_selector/page_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/epub_page.dart';

class EpubNavigationView extends StatelessWidget {
  const EpubNavigationView({
    super.key,
    required this.listPages,
    required this.epubBook,
    required this.content,
  });

  final List<EpubPage> listPages;
  final EpubBook epubBook;
  final EpubBookContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageSelectorWidget(
              listPages: listPages,
              images: epubBook.content?.images ?? {},
            ),
          ),
          navigationPanel(
            context,
          ),
          pageInfoPanel(),
        ],
      ),
    );
  }

  Widget pageInfoPanel() {
    return BlocBuilder<EpubReaderCubit, EpubReaderState>(
      builder: (context, state) {
        if (state.panelVisible) {
          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                  child: Text(
                      "${state.pageIndex + 1} of ${state.chapterContent.listPages.length} chapter: ${state.chapterContent.listPages[state.pageIndex.abs()].chapterIndex}  ${state.chapterContent.listPages[state.pageIndex.abs()].height.toStringAsFixed(2)}, ${state.chapterContent.listPages[state.pageIndex.abs()].paragraphsPerPage.first.metadata.paragraphIndex}:${state.chapterContent.listPages[state.pageIndex.abs()].paragraphsPerPage.first.metadata.startPosition}-${state.chapterContent.listPages[state.pageIndex.abs()].paragraphsPerPage.first.metadata.endPosition}")),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget navigationPanel(
    BuildContext context,
  ) {
    final cubit = context.read<EpubReaderCubit>();
    return Positioned.fill(
      bottom: 80,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: BlocBuilder<EpubReaderCubit, EpubReaderState>(
          builder: (context, state) => Visibility(
            visible: state.panelVisible,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                  color: const Color(0xFFB13E2F),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(
                          1.0,
                          3,
                        ),
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        blurStyle: BlurStyle.normal)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFB13E2F),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                title: Text("You are exiting the app"),
                                content: Text("Test"),
                              );
                            });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () async {
                      final index = await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return BottomSheet(
                              onClosing: () {},
                              builder: (context) => ListView(
                                children: content.listChapters
                                    .mapIndexed((index, chapter) => TextButton(
                                          child: Text(chapter.title ?? ""),
                                          onPressed: () => {
                                            Navigator.pop(context, index),
                                          },
                                        ))
                                    .toList(),
                              ),
                            );
                          });

                      if (index != null) {
                        cubit.goToChapter(index);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.font_download),
                    onPressed: () async {
                      final oldStyle = state.decorator.style;
                      final style = await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return BottomSheet(
                              onClosing: () {},
                              enableDrag: true,
                              showDragHandle: true,
                              builder: (context) => EpubStyleManagerWidget(
                                epubStyle: oldStyle,
                              ),
                            );
                          });

                      if (style != null) {
                        cubit.updateStyle(style);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
