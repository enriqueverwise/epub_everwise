import 'package:collection/collection.dart';
import 'package:epub_everwise/data/models/chapter.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/chapter_view_value.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:epub_everwise/ui/reader/widgets/epub_style_manager_widget.dart';
import 'package:epub_everwise/ui/reader/widgets/page_selector/page_selector_widget.dart';
import 'package:flutter/cupertino.dart';
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
        final page = state.chapterContent.listPages[state.pageIndex.abs()];
        if (state.panelVisible) {
          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                  child: Column(
                children: [
                  Text(
                    "${state.pageIndex + 1} of "
                    "${state.chapterContent.listPages.length}, "
                    "chapter: ${content.listChapters[page.chapterIndex].index} & ${page.chapterIndex}, "
                    " h: ${page.height.toStringAsFixed(2)}, "
                    "p: ${page.paragraphsPerPage.first.metadata.paragraphIndex}-"
                    "${page.paragraphsPerPage.last.metadata.paragraphIndex}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "start: ${page.paragraphsPerPage.first.metadata.startPosition??"clean"}, end: ${page.paragraphsPerPage.last.metadata.endPosition??"clean"}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )),
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
                              return AlertDialog(
                                title: Text(
                                  "You are exiting the app",
                                  style: TextStyle(fontSize: 18),
                                ),
                                content:
                                    Text("You will go back to Epub selection"),
                                actions: [
                                  //red elevated button

                                  ElevatedButton(
                                    child: Text("Back to Menu"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurpleAccent
                                          .withOpacity(0.1),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final maxPages = state.chapterContent.listPages.length;
                      final currentPage = state.pageIndex;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "Enter page number",
                                    ),
                                    onSubmitted: (value) {
                                      final page = int.tryParse(value);
                                      if (page != null &&
                                          page > 0 &&
                                          page <= maxPages) {
                                        Navigator.of(context).pop();
                                        cubit.goToPage(page - 1);
                                      }
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () async {
                      final index = await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return BottomSheet(
                              enableDrag: true,
                              showDragHandle: true,
                              onClosing: () {},
                              builder: (context) =>
                                  getListChaptersWidget(context),
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
                          isScrollControlled: true,
                          //scrollControlDisabledMaxHeightRatio: 0.9,
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

  Widget getListChaptersWidget(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.listChapters.mapIndexed((index, chapter) {
            return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              if (chapter is EpubViewSubChapter)
                const SizedBox(
                  width: 30,
                  child: Text(
                    "-",
                    textAlign: TextAlign.right,
                  ),
                ),
              Flexible(
                child: TextButton(
                  child: Text(
                    chapter.title ?? "",
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () => {
                    Navigator.pop(context, index),
                  },
                ),
              ),
            ]);
          }).toList(),
        ));
  }
}
