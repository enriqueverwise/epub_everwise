import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EpubReaderPhysics extends Equatable {
  final Axis scrollDirection;
  final bool isPageSnapping;

  factory EpubReaderPhysics.book({Axis scrollDirection = Axis.horizontal}) =>
      EpubReaderPhysics(
        scrollDirection: scrollDirection,
        isPageSnapping: true,
      );
  factory EpubReaderPhysics.scroll() =>
      const EpubReaderPhysics(scrollDirection: Axis.vertical, isPageSnapping: false);

  const EpubReaderPhysics({
    required this.scrollDirection,
    required this.isPageSnapping,
  });

  @override
  List<Object> get props => [scrollDirection, isPageSnapping];
}
