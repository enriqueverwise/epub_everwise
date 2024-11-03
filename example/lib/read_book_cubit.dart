
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:epub_everwise/epub_everwise.dart';
import 'package:equatable/equatable.dart';

part 'read_book_state.dart';

enum ReadStatus{coverReady, bookReady, loading}
class ReadBookCubit extends Cubit<ReadBookState> {
  ReadBookCubit() : super(ReadBookState());



  Future<void> initBook(Uint8List bookBytes) async {
    final bookCover =
        await EpubDocument.getCoverFromBookData(bookBytes);

    emit(state.copyWith(bookCover: bookCover, status: ReadStatus.coverReady));
    Future.delayed(Duration(seconds: 1), () => openBook(bookBytes));
  }


  Future<void> openBook(Uint8List bytes) async {
    final book =
    await EpubDocument.openData(bytes);

    emit(state.copyWith(epubBook: book, status: ReadStatus.bookReady));
  }
}
