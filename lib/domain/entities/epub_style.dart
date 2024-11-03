import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum EpubBackgroundOption {
  everwiseColor,
  dark,
  light;

  String get text => switch (this) {
    EpubBackgroundOption.everwiseColor => "Original",
    EpubBackgroundOption.dark => "Dark",
    EpubBackgroundOption.light => "Light"
  };

  Color get color => switch (this) {
    EpubBackgroundOption.everwiseColor => Colors.red,
    EpubBackgroundOption.dark => Colors.black,
    EpubBackgroundOption.light => Colors.white
  };

  bool get isEverwise => this == everwiseColor;
  bool get isDark => this == dark;
  bool get isLight => this == light;
}

class EpubStyle extends Equatable {
  final TextStyle textStyle;
  final EpubBackgroundOption backgroundOption;
  final Axis scrollDirection;
  const EpubStyle({
    required this.textStyle,
    required this.backgroundOption,
    this.scrollDirection = Axis.horizontal,
  });

  EpubStyle copyWith({
    TextStyle? textStyle,
    EpubBackgroundOption? backgroundOption,
    Axis? scrollDirection,
  }) =>
      EpubStyle(
        textStyle: textStyle ?? this.textStyle,
        backgroundOption: backgroundOption ?? this.backgroundOption,
        scrollDirection: scrollDirection ?? this.scrollDirection,
      );

  @override
  List<Object?> get props => [
    textStyle,
    backgroundOption,
    scrollDirection,
  ];
}