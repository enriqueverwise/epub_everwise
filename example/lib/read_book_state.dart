part of 'read_book_cubit.dart';

class ReadBookState extends Equatable {
  final Uint8List? bookCover;
  final EpubBook? epubBook;
  final ReadStatus status;
  ReadBookState(
      {this.status = ReadStatus.loading, this.bookCover, this.epubBook});

  ReadBookState copyWith({Uint8List? bookCover, EpubBook? epubBook, ReadStatus? status}) =>
      ReadBookState(
        bookCover: bookCover ?? this.bookCover,
        epubBook: epubBook ?? this.epubBook,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [bookCover, epubBook, status];
}
