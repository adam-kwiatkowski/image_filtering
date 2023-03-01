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

class FilterField<T> {
  final String label;
  T value;
  final Type type;
  final List<T>? options;
  final T? min;
  final T? max;

  FilterField(this.label, this.value, this.type, {this.options, this.min, this.max});

  @override
  String toString() {
    return "$label: $value";
  }
}

abstract class FilterModel extends ImageFilter {
  FilterModel(super.name, {super.icon = Icons.filter});

  List<FilterField> get fields;

  FilterModel copyWith(List<FilterField> fields);
}