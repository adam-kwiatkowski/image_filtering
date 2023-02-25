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
