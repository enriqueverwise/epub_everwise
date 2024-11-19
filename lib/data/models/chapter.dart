import 'package:equatable/equatable.dart';

class EpubViewChapter extends Equatable {
  const EpubViewChapter({required this.title, required this.index});

  final String? title;
  final int index;
  bool get isSubChapter => this is EpubViewSubChapter;

  @override
  List<Object?> get props => [title, index];
}

class EpubViewSubChapter extends EpubViewChapter {
  const EpubViewSubChapter({
    required super.title,
    required this.parentChapterIndex,
  }) : super(index: parentChapterIndex);
  final int parentChapterIndex;
}
