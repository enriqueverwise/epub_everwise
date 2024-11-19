import 'package:epub_everwise/domain/entities/epub_decorator.dart';
import 'package:epub_everwise/domain/entities/epub_reader_content.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:epub_everwise/ui/reader/widgets/page_selector/pagination_reader_widget.dart';
import 'package:epub_everwise/ui/reader/widgets/page_selector/scrollable_reader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageSelectorWidget extends StatelessWidget {
  const PageSelectorWidget({
    super.key,
    required this.listPages,
    required this.images,
  });

  final List<EpubPage> listPages;
  final Map<String, EpubImageContentFile> images;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EpubReaderCubit, EpubReaderState, EpubChapterContent>(
      selector: (state) => state.chapterContent,
      builder: (context, chapterContent) {
        if (chapterContent.listPages.isNotEmpty) {
          return BlocSelector<EpubReaderCubit, EpubReaderState,
                  EpubPageDecorator>(
              selector: (state) => state.decorator,
              builder: (context, decorator) {
                switch (decorator.style.physics.scrollDirection) {
                  case Axis.horizontal:
                    return PaginationReaderWidget(
                      listPages: listPages,
                      images: images,
                      padding: decorator.padding,
                      style: decorator.style,
                      initialPage:
                          context.read<EpubReaderCubit>().state.pageIndex,
                    );
                  case Axis.vertical:
                    return ScrollableReaderWidget(
                      listPages: listPages,
                      images: images,
                      padding: decorator.padding,
                      style: decorator.style,
                      initialPage:
                          context.read<EpubReaderCubit>().state.pageIndex,
                    );
                }
              });
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
