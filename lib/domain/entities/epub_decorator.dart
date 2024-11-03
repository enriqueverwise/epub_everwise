import 'package:epub_everwise/domain/entities/epub_style.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EpubPageDecorator extends Equatable {
  final EpubStyle style;
  final EdgeInsets padding;
  const EpubPageDecorator({
    required this.padding,
    required this.style,
  });

  EpubPageDecorator copyWith({
    EdgeInsets? padding,
    EpubStyle? style,
  }) =>
      EpubPageDecorator(
        padding: padding ?? this.padding,
        style: style ?? this.style,
      );

  @override
  List<Object?> get props => [
    padding,
    style,
  ];
}