import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:epub_everwise/data/models/paragraph.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:epub_everwise/ui/reader/widgets/epub_page/epub_page_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaginationReaderWidget extends StatelessWidget {
  PaginationReaderWidget({
    super.key,
    required this.listPages,
    required this.images,
    required this.padding,
    required this.style,
    required this.initialPage,
  });

  final int initialPage;
  final List<EpubPage> listPages;
  final Map<String, EpubImageContentFile> images;
  late final controller = PageController(initialPage: initialPage);
  final EdgeInsets padding;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EpubReaderCubit, EpubReaderState>(
      listener: (context, state) {
        final currentPage = controller.page?.floor() ?? 0;
        if (state.pageIndex != (currentPage)) {
          final difference = state.pageIndex - currentPage;
          if (difference.abs() > 2) {
            controller.jumpToPage(
              state.pageIndex,
            );
          } else {
            controller.animateToPage(state.pageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        }
      },
      child: PageView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: listPages.length,

        scrollBehavior: const CupertinoScrollBehavior(),
        onPageChanged: (value) {
          context.read<EpubReaderCubit>().goToPage(value);
        },
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: padding,
            child: EpubPageWidget(
              screenSize: context.read<EpubReaderCubit>().getSizeScreen(),
              style: style,
              images: images,
              page: listPages[index],
              cssContent: context
                      .read<EpubReaderCubit>()
                      .epubBook
                      .content
                      ?.css
                      ?.entries
                      .first
                      .value
                      .cssContent ??
                  {},
            ),
          );
        },
      ),
    );
  }
}
