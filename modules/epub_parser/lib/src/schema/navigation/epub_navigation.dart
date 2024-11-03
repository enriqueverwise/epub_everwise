import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart' as collections;
import 'package:quiver/core.dart';

import 'epub_navigation_doc_author.dart';
import 'epub_navigation_doc_title.dart';
import 'epub_navigation_head.dart';
import 'epub_navigation_list.dart';
import 'epub_navigation_map.dart';
import 'epub_navigation_page_list.dart';

class EpubNavigation extends Equatable{
  final EpubNavigationHead? head;
  final EpubNavigationDocTitle? docTitle;
  final List<EpubNavigationDocAuthor>? docAuthors;
  final EpubNavigationMap? navMap;
  final EpubNavigationPageList? pageList;
  final List<EpubNavigationList>? navLists;

  EpubNavigation({
    required this.head,
    required this.docTitle,
    required this.docAuthors,
    required this.navMap,
    required this.pageList,
    required this.navLists,
  });

  @override
  // TODO: implement props
  List<Object?> get props =>[
    head,
    docTitle,
    docAuthors,
    navMap,
    pageList,
    navLists,
  ];
}
