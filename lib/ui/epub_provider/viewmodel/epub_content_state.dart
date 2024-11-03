part of 'epub_content_provider_cubit.dart';

sealed class EpubContentState extends Equatable {
  const EpubContentState();

  @override
  List<Object?> get props => [];
}

final class EpubContentLoading extends EpubContentState {}

final class EpubContentError extends EpubContentState {}

final class EpubContentSuccess extends EpubContentState {
  final int chapterIndex;
  final EpubBookContent content;
  const EpubContentSuccess({
    required this.chapterIndex,
    required this.content,
  });

  EpubContentSuccess copyWith({
    int? chapterIndex,
    EpubBookContent? content,
  }) =>
      EpubContentSuccess(
        chapterIndex: chapterIndex ?? this.chapterIndex,
        content: content ?? this.content,
      );

  @override
  List<Object> get props => [
        chapterIndex,
        content,
      ];
}
