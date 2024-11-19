import 'package:epub_everwise/epub_everwise.dart';
import 'package:epub_everwise/ui/epub_provider/viewmodel/epub_content_provider_cubit.dart';
import 'package:epub_everwise/ui/reader/epub_gesture_detector_view.dart';
import 'package:epub_everwise/ui/reader/viewmodel/epub_reader_cubit.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EpubBookProvider extends StatelessWidget {
  const EpubBookProvider({
    super.key,
    required this.epubBook,
  });
  final EpubBook epubBook;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EpubContentProviderCubit(
        epubBook: epubBook,
        epubFragmentId: null,
      )..loadData(),
      child: SafeArea(
        child: Scaffold(
          body: LayoutBuilder(
            builder:(context, constraints)=> BlocBuilder<EpubContentProviderCubit, EpubContentState>(
              builder: (context, state) {

                //final screenPadding = MediaQuery.paddingOf(context);
                //const spacing = 40 * 2;
                final safeSize = Size(
                  constraints.maxWidth,
                  (constraints.maxHeight-30),
                );
                return switch (state) {
                  EpubContentLoading() =>
                    ExtendedImage.memory(epubBook.coverImage!),
                  EpubContentError() => const Text("Error formating epub"),
                  EpubContentSuccess() => BlocProvider(
                      create: (context) => EpubReaderCubit(
                        content: state.content,
                        epubBook: epubBook,
                        screenSize: safeSize,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          fontFamily: 'Times',
                          color: Colors.white,
                        ),
                      )..initBook(),
                      child: EpubGestureDetectorView(
                        epubBook: epubBook,
                        content: state.content,
                      ),
                    ),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}
