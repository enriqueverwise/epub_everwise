import 'package:epub_everwise/domain/entities/epub_reader_physics.dart';
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
  final EpubReaderPhysics physics;
  const EpubStyle({
    required this.textStyle,
    required this.backgroundOption,
    required this.physics,
  });

  EpubStyle copyWith({
    TextStyle? textStyle,
    EpubBackgroundOption? backgroundOption,
    EpubReaderPhysics? physics,
  }) =>
      EpubStyle(
        textStyle: textStyle ?? this.textStyle,
        backgroundOption: backgroundOption ?? this.backgroundOption,
        physics: physics ?? this.physics,
      );

  @override
  List<Object?> get props => [
    textStyle,
    backgroundOption,
    physics,
  ];
}