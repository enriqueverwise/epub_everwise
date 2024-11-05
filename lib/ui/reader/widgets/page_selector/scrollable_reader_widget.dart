import 'dart:async';

import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/epub_page.dart';
import 'package:epub_everwise/data/models/paragraph.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:epub_everwise/ui/reader/widgets/epub_page/epub_page_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const _minTrailingEdge = 0.55;
const _minLeadingEdge = -0.05;

class ScrollableReaderWidget extends StatefulWidget {
  ScrollableReaderWidget({
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
  final EdgeInsets padding;
  final TextStyle style;

  @override
  State<ScrollableReaderWidget> createState() => _ScrollableReaderWidgetState();
}

class _ScrollableReaderWidgetState extends State<ScrollableReaderWidget> {
  ItemScrollController? _itemScrollController;
  ItemPositionsListener? _itemPositionListener;

  // void positionListener() {
  //   final currentPage = _itemPositionListener?.itemPositions.value ?? 0;
  //   if (context.read<EpubReaderCubit>().state.pageIndex != (currentPage)) {
  //     final difference = context.read<EpubReaderCubit>().state.pageIndex - currentPage;
  //     if (difference.abs() > 2) {
  //       controller.jumpToPage(
  //         context.read<EpubReaderCubit>().state.pageIndex,
  //       );
  //     } else {
  //       controller.animateToPage(context.read<EpubReaderCubit>().state.pageIndex,
  //           duration: const Duration(milliseconds: 300),
  //           curve: Curves.ease);
  //     }
  //   }
  // }

  // void _changeListener() {
  //   if (_itemPositionListener!.itemPositions.value.isEmpty) {
  //     return;
  //   }
  //   final position = _itemPositionListener!.itemPositions.value.first;
  //   final chapterIndex = _getChapterIndexBy(
  //     positionIndex: position.index,
  //     trailingEdge: position.itemTrailingEdge,
  //     leadingEdge: position.itemLeadingEdge,
  //   );
  //   final paragraphIndex = _getParagraphIndexBy(
  //     positionIndex: position.index,
  //     trailingEdge: position.itemTrailingEdge,
  //     leadingEdge: position.itemLeadingEdge,
  //   );
  //
  //   _currentValue = EpubChapterViewValue(
  //     chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
  //     chapterNumber: chapterIndex + 1,
  //     paragraphNumber: paragraphIndex + 1,
  //     position: position,
  //   );
  //   _controller.currentValueListenable.value = _currentValue;
  //   widget.onChapterChanged?.call(_currentValue);
  // }

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();

    _itemPositionListener?.itemPositions.addListener(_pageListener);
  }

  int _getAbsPageIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < _minTrailingEdge &&
        leadingEdge < _minLeadingEdge) {
      posIndex += 1;
    }

    return posIndex;
  }

  void _pageListener() {
    if (_itemPositionListener!.itemPositions.value.isEmpty) {
      return;
    }

    final position = _itemPositionListener!.itemPositions.value.first;

    final pageIndex = _getAbsPageIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );

    context.read<EpubReaderCubit>().goToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = context.read<EpubReaderCubit>().getSizeScreen();
    final height = MediaQuery.sizeOf(context).height;
    final cssContent = context
            .read<EpubReaderCubit>()
            .epubBook
            .content
            ?.css
            ?.entries
            .first
            .value
            .cssContent ??
        {};
    return BlocListener<EpubReaderCubit, EpubReaderState>(
      listener: (context, state) {
        final position = _itemPositionListener!.itemPositions.value.first;

        final currentPage = _getAbsPageIndexBy(
          positionIndex: position.index,
          trailingEdge: position.itemTrailingEdge,
          leadingEdge: position.itemLeadingEdge,
        );
        if (state.pageIndex != (currentPage)) {
          final difference = state.pageIndex - currentPage;
          if (difference.abs() > 2) {
            _itemScrollController?.scrollTo(
              index: state.pageIndex,
              duration: const Duration(milliseconds: 300),
            );
          }
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: widget.listPages.length,
        initialScrollIndex:  widget.initialPage,
        scrollDirection: Axis.vertical,
        itemPositionsListener: _itemPositionListener,
        itemScrollController: _itemScrollController,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: widget.padding,
            child: EpubPageWidget(
              screenSize: sizeScreen,
              style: widget.style,
              images: widget.images,
              page: widget.listPages[index],
              cssContent: cssContent,
            ),
          );
        },
      ),
    );
  }
}
