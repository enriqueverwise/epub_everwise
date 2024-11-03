import 'package:equatable/equatable.dart';

class EpubViewChapter extends Equatable{
  const EpubViewChapter(this.title, this.startIndex);

  final String? title;
  final int startIndex;

  String get type => this is EpubViewSubChapter ? 'subchapter' : 'chapter';


  @override
  List<Object?> get props => [title, startIndex];
}

class EpubViewSubChapter extends EpubViewChapter {
  EpubViewSubChapter(super.title, super.startIndex);
}
