import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

abstract class ImageFilter {
  String name;
  IconData icon;

  ImageFilter(this.name, {this.icon = Icons.filter});

  void apply(Uint8List pixels, int width, int height);
}

class CompositeFilter extends ImageFilter {
  List<ImageFilter> filters = [];

  CompositeFilter(this.filters, {name = "Composite", icon = Icons.photo_filter})
      : super(name);

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var filter in filters) {
      filter.apply(pixels, width, height);
    }
  }
}

class FilterParameter<T> {
  final String label;
  T value;
  final Type type;
  final List<T>? options;
  final T? min;
  final T? max;

  FilterParameter(this.label, this.value, this.type,
      {this.options, this.min, this.max});

  @override
  String toString() {
    return "$label: $value";
  }
}

abstract class ParametrizedFilter extends ImageFilter {
  ParametrizedFilter(super.name, {super.icon = Icons.filter});

  List<FilterParameter> get fields;

  ParametrizedFilter copyWith(List<FilterParameter> fields);
}

class KernelSize<T> {
  T width;
  T height;

  KernelSize(this.width, this.height);

  KernelSize.square(T size) : this(size, size);

  @override
  String toString() {
    return "KernelSize($width, $height)";
  }
}

class Kernel {
  List<num> values;
  KernelSize<int>? size;
  Point<int>? anchor;
  num? divisor;

  Kernel(this.values, {this.size, this.anchor, this.divisor}) {
    size ??= KernelSize.square(sqrt(values.length).round());
    anchor ??= Point(size!.width ~/ 2, size!.height ~/ 2);
    divisor ??= values.reduce((a, b) => a + b);
    divisor = divisor == 0 ? 1 : divisor;
  }

  Kernel copyWith(
      {List<num>? values,
      KernelSize<int>? size,
      Point<int>? anchor,
      num? divisor}) {
    return Kernel(values ?? this.values,
        size: size ?? this.size,
        anchor: anchor ?? this.anchor,
        divisor: divisor ?? this.divisor);
  }

  @override
  String toString() {
    return "Kernel($values, size: $size, anchor: $anchor, divisor: $divisor)";
  }
}
