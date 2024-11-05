import 'package:epub_everwise/domain/entities/epub_reader_content.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/data/models/epub_book_content.dart';
import 'package:epub_everwise/domain/entities/epub_style.dart';
import 'package:epub_everwise/ui/reader/epub_navigation_view.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EpubReaderView extends StatelessWidget {
  const EpubReaderView({
    super.key,
    required this.content,
    required this.epubBook,
  });

  final EpubBookContent content;
  final EpubBook epubBook;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EpubReaderCubit, EpubReaderState, EpubBackgroundOption>(
      selector: (state) => state.decorator.style.backgroundOption,
      builder: (context, bgOption) {
        return Container(
          padding: const EdgeInsets.only(top: kToolbarHeight / 2),
          decoration: switch (bgOption) {
            EpubBackgroundOption.everwiseColor =>
            const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F172A), Color(0xFF450A0A)])),
            EpubBackgroundOption.dark =>
            const BoxDecoration(color: Colors.black),
            EpubBackgroundOption.light =>
            const BoxDecoration(
              color: Colors.white,
            ),
          },
          child: BlocSelector<EpubReaderCubit, EpubReaderState, EpubChapterContent>(
            selector: (state) =>state.chapterContent,
            builder: (context, chapterContent) {
              return EpubNavigationView(
                listPages: chapterContent.listPages,
                epubBook: epubBook,
                content: content,
              );
            },
          ),
        );
      },
    );
  }
}
