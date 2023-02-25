import 'dart:typed_data';

import 'filters.dart';

class InvertFilter extends ImageFilter {
  InvertFilter() : super("Invert");

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      pixels[i] = 255 - pixels[i];
      pixels[i + 1] = 255 - pixels[i + 1];
      pixels[i + 2] = 255 - pixels[i + 2];
    }
  }
}

class GrayscaleFilter extends ImageFilter {
  GrayscaleFilter() : super("Grayscale");

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      var r = pixels[i];
      var g = pixels[i + 1];
      var b = pixels[i + 2];
      var gray = (r + g + b) ~/ 3;
      pixels[i] = gray;
      pixels[i + 1] = gray;
      pixels[i + 2] = gray;
    }
  }
}
