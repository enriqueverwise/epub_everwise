import 'package:equatable/equatable.dart';

import '../schema/navigation/epub_navigation.dart';
import '../schema/opf/epub_package.dart';

class EpubSchema extends Equatable {
  final EpubPackage? package;
  final EpubNavigation? navigation;
  final String? contentDirectoryPath;

  EpubSchema({
    required this.package,
    required this.navigation,
    required this.contentDirectoryPath,
  });

  @override
  List<Object?> get props => [
    package,
    navigation,
    contentDirectoryPath,
  ];
}
