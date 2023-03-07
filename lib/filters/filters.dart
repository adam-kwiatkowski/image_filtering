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
  num? offset;

  Kernel(this.values, {this.size, this.anchor, this.divisor, this.offset}) {
    size ??= KernelSize.square(sqrt(values.length).round());
    anchor ??= Point(size!.width ~/ 2, size!.height ~/ 2);
    divisor ??= values.reduce((a, b) => a + b);
    divisor = divisor == 0 ? 1 : divisor;
    offset ??= 0;
  }

  Kernel copyWith(
      {List<num>? values,
      KernelSize<int>? size,
      Point<int>? anchor,
      num? divisor,
      num? offset}) {
    return Kernel(values ?? this.values,
        size: size ?? this.size,
        anchor: anchor ?? this.anchor,
        divisor: divisor ?? this.divisor,
        offset: offset ?? this.offset);
  }

  @override
  String toString() {
    return "Kernel($values, size: $size, anchor: $anchor, divisor: $divisor, offset: $offset)";
  }
}

void kernelConvolution(Uint8List pixels, int width, int height, Kernel kernel,
    {bool abs = false}) {
  var result = Uint8List.fromList(pixels);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var r = 0.0;
      var g = 0.0;
      var b = 0.0;

      for (var ky = 0; ky < kernel.size!.height; ky++) {
        for (var kx = 0; kx < kernel.size!.width; kx++) {
          var px = x + kx - kernel.anchor!.x;
          var py = y + ky - kernel.anchor!.y;

          if (px >= 0 && px < width && py >= 0 && py < height) {
            var i = (py * width + px) * 4;
            var k = kernel.values[ky * kernel.size!.width + kx];

            r += pixels[i] * k;
            g += pixels[i + 1] * k;
            b += pixels[i + 2] * k;
          }
        }
      }

      var i = (y * width + x) * 4;
      if (abs) {
        result[i] = (kernel.offset! + (r / kernel.divisor!)).round().abs();
        result[i + 1] = (kernel.offset! + (g / kernel.divisor!)).round().abs();
        result[i + 2] = (kernel.offset! + (b / kernel.divisor!)).round().abs();
      } else {
        result[i] =
            (kernel.offset! + (r / kernel.divisor!)).round().clamp(0, 255);
        result[i + 1] =
            (kernel.offset! + (g / kernel.divisor!)).round().clamp(0, 255);
        result[i + 2] =
            (kernel.offset! + (b / kernel.divisor!)).round().clamp(0, 255);
      }
    }
  }

  pixels.setAll(0, result);
}
