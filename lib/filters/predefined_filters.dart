import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'filters.dart';

class InvertFilter extends ImageFilter {
  InvertFilter() : super("Invert", icon: Icons.invert_colors);

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
  GrayscaleFilter() : super("Grayscale", icon: Icons.filter_b_and_w);

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

class BrightnessFilter extends ParametrizedFilter {
  final int brightness;

  BrightnessFilter(this.brightness)
      : super("Brightness", icon: Icons.brightness_6);

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      pixels[i] = (pixels[i] + brightness).clamp(0, 255);
      pixels[i + 1] = (pixels[i + 1] + brightness).clamp(0, 255);
      pixels[i + 2] = (pixels[i + 2] + brightness).clamp(0, 255);
    }
  }

  @override
  List<FilterParameter> get fields => [
        FilterParameter("Brightness", brightness, int, min: -255, max: 255),
      ];

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return BrightnessFilter(fields[0].value);
  }
}

class ContrastFilter extends ParametrizedFilter {
  final double contrast;

  ContrastFilter(this.contrast) : super("Contrast", icon: Icons.contrast);

  @override
  void apply(Uint8List pixels, int width, int height) {
    var factor =
        (259 * (contrast * 255 + 255)) / (255 * (259 - contrast * 255));

    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      pixels[i] = (factor * (pixels[i] - 128) + 128).round().clamp(0, 255);
      pixels[i + 1] =
          (factor * (pixels[i + 1] - 128) + 128).round().clamp(0, 255);
      pixels[i + 2] =
          (factor * (pixels[i + 2] - 128) + 128).round().clamp(0, 255);
    }
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return ContrastFilter(fields[0].value);
  }

  @override
  List<FilterParameter> get fields => [
        FilterParameter("Contrast", contrast, double, min: -1.0, max: 1.0),
      ];
}

class GammaCorrectionFilter extends ParametrizedFilter {
  final double gamma;

  GammaCorrectionFilter(this.gamma)
      : super("Gamma Correction", icon: Icons.tonality);

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      pixels[i] = (pow(pixels[i] / 255, 1 / gamma) * 255).round().clamp(0, 255);
      pixels[i + 1] =
          (pow(pixels[i + 1] / 255, 1 / gamma) * 255).round().clamp(0, 255);
      pixels[i + 2] =
          (pow(pixels[i + 2] / 255, 1 / gamma) * 255).round().clamp(0, 255);
    }
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return GammaCorrectionFilter(fields[0].value);
  }

  @override
  List<FilterParameter> get fields => [
        FilterParameter("Gamma", gamma, double, min: 0.1, max: 2.2),
      ];
}

class ConvolutionFilter extends ParametrizedFilter {
  final Kernel kernel;

  ConvolutionFilter(this.kernel,
      {String name = "Convolution filter", IconData icon = Icons.filter})
      : super(name, icon: icon);

  @override
  void apply(Uint8List pixels, int width, int height) {
    kernelConvolution(pixels, width, height, kernel);
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return ConvolutionFilter(fields[0].value, name: name, icon: icon);
  }

  @override
  List<FilterParameter> get fields =>
      [FilterParameter("Kernel", kernel, Kernel)];
}

class BidirectionalEdgeDetection extends ParametrizedFilter {
  final int M;

  BidirectionalEdgeDetection(this.M)
      : super("Bidirectional Edge Detection", icon: Icons.filter);

  @override
  void apply(Uint8List pixels, int width, int height) {
    var pixels1 = Uint8List.fromList(pixels);
    var pixels2 = Uint8List.fromList(pixels);
    kernelConvolution(
        pixels1, width, height, Kernel([0, -1, 0, 0, 1, 0, 0, 0, 0]),
        abs: true);
    kernelConvolution(
        pixels2, width, height, Kernel([0, 0, 0, -1, 1, 0, 0, 0, 0]),
        abs: true);

    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      var values = [
        pixels1[i],
        pixels1[i + 1],
        pixels1[i + 2],
        pixels2[i],
        pixels2[i + 1],
        pixels2[i + 2],
      ];

      var newValue = 0;
      for (var val in values) {
        if (val > M) newValue = 255;
      }

      pixels[i] = newValue;
      pixels[i + 1] = newValue;
      pixels[i + 2] = newValue;
    }
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return BidirectionalEdgeDetection(fields[0].value);
  }

  @override
  List<FilterParameter> get fields => [
        FilterParameter("M", M, int, min: 0, max: 255),
      ];
}

class AverageDitheringFilter extends ParametrizedFilter {
  final int K;

  AverageDitheringFilter(this.K)
      : super("Average Dithering", icon: Icons.grain);

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var c = 0; c < 3; c++) {
      var avg = 0;
      for (var i = 0; i < pixels.lengthInBytes; i += 4) {
        avg += pixels[i + c];
      }
      avg ~/= pixels.lengthInBytes ~/ 4;

      var levels = [0, avg, 255];
      var l = 0;
      for (var i = 0; i < K - 2; i++) {
        levels.insert(l + 1, (levels[l] + levels[l + 1]) ~/ 2);
        l += 2;
        if (l >= levels.length - 1) l = 0;
      }

      for (var i = 0; i < pixels.lengthInBytes; i += 4) {
        var val = pixels[i + c];
        if (val < levels[1]) {
          pixels[i + c] = levels[0];
        } else if (val > levels[levels.length - 2]) {
          pixels[i + c] = levels[levels.length - 1];
        } else {
          for (var j = 1; j < levels.length - 1; j++) {
            if (val >= levels[j] && val < levels[j + 1]) {
              pixels[i + c] = levels[j];
              break;
            }
          }
        }
      }
    }
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return AverageDitheringFilter(fields[0].value);
  }

  @override
  List<FilterParameter> get fields => [
        FilterParameter("K", K, int),
      ];
}

class MedianCutFilter extends ParametrizedFilter {
  final int K;

  MedianCutFilter(this.K) : super("Median Cut", icon: Icons.area_chart);

  @override
  void apply(Uint8List pixels, int width, int height) {
    var colors = pixelsToColor(pixels);
    var colorMap = medianCut(colors, K).toSet().toList();
    var quantizedPixels = replacePixelsWithColorMap(pixels, colorMap);
    pixels.setAll(0, quantizedPixels);
  }

  List<Color> pixelsToColor(Uint8List pixels) {
    var colors = <Color>[];
    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      colors.add(Color.fromARGB(
          pixels[i + 3], pixels[i], pixels[i + 1], pixels[i + 2]));
    }
    return colors;
  }

  Uint8List colorsToPixels(List<Color> colors) {
    var pixels = Uint8List(colors.length * 4);
    for (var i = 0; i < colors.length; i++) {
      var color = colors[i];
      pixels[i * 4] = color.red;
      pixels[i * 4 + 1] = color.green;
      pixels[i * 4 + 2] = color.blue;
      pixels[i * 4 + 3] = color.alpha;
    }
    return pixels;
  }

  List<Color> quantize(List<Color> colors) {
    var r = colors.map((c) => c.red).reduce((a, b) => a + b) ~/ colors.length;
    var g = colors.map((c) => c.green).reduce((a, b) => a + b) ~/ colors.length;
    var b = colors.map((c) => c.blue).reduce((a, b) => a + b) ~/ colors.length;
    return List.generate(
        colors.length, (index) => Color.fromARGB(255, r, g, b));
  }

  Uint8List replacePixelsWithColorMap(Uint8List pixels, List<Color> colorMap) {
    var newPixels = Uint8List(pixels.length);
    for (var i = 0; i < pixels.length; i += 4) {
      var color = Color.fromARGB(
          pixels[i + 3], pixels[i], pixels[i + 1], pixels[i + 2]);
      var closestColor = findClosestColor(colorMap, color);
      newPixels[i] = closestColor.red;
      newPixels[i + 1] = closestColor.green;
      newPixels[i + 2] = closestColor.blue;
      newPixels[i + 3] = closestColor.alpha;
    }
    return newPixels;
  }

  Color findClosestColor(List<Color> colorMap, Color color) {
    var minDistance = double.infinity;
    var closestColor = color;
    for (var mapColor in colorMap) {
      var distance = colorDistance(color, mapColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = mapColor;
      }
    }
    return closestColor;
  }

  double colorDistance(Color a, Color b) {
    var dr = a.red - b.red;
    var dg = a.green - b.green;
    var db = a.blue - b.blue;
    return sqrt(dr * dr + dg * dg + db * db);
  }

  List<Color> medianCut(List<Color> colors, int k) {
    if (k == 1) return quantize(colors);

    var rRange = colors.map((c) => c.red).reduce((a, b) => max(a, b)) -
        colors.map((c) => c.red).reduce((a, b) => min(a, b));
    var gRange = colors.map((c) => c.green).reduce((a, b) => max(a, b)) -
        colors.map((c) => c.green).reduce((a, b) => min(a, b));
    var bRange = colors.map((c) => c.blue).reduce((a, b) => max(a, b)) -
        colors.map((c) => c.blue).reduce((a, b) => min(a, b));

    var maxRange = max(rRange, max(gRange, bRange));

    var sortedColors = colors;
    if (maxRange == rRange) {
      sortedColors.sort((a, b) => a.red.compareTo(b.red));
    } else if (maxRange == gRange) {
      sortedColors.sort((a, b) => a.green.compareTo(b.green));
    } else {
      sortedColors.sort((a, b) => a.blue.compareTo(b.blue));
    }

    var half = sortedColors.length ~/ 2;

    var colors1 = medianCut(sortedColors.sublist(0, half), k ~/ 2);
    var colors2 = medianCut(sortedColors.sublist(half), k ~/ 2);

    return colors1 + colors2;
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return MedianCutFilter(fields[0].value);
  }

  @override
  List<FilterParameter> get fields => [
        FilterParameter("K", K, int),
      ];
}

var predefinedFilters = [
  InvertFilter(),
  GrayscaleFilter(),
  BrightnessFilter(50),
  ContrastFilter(.5),
  GammaCorrectionFilter(1.5),
  ConvolutionFilter(Kernel([1, 1, 1, 1, 1, 1, 1, 1, 1]),
      name: "Blur", icon: Icons.blur_linear),
  ConvolutionFilter(Kernel([1, 2, 1, 2, 4, 2, 1, 2, 1]),
      name: "Gaussian Blur", icon: Icons.blur_on),
  ConvolutionFilter(Kernel([0, -1, 0, -1, 5, -1, 0, -1, 0]),
      name: "Sharpen", icon: Icons.deblur),
  ConvolutionFilter(Kernel([-1, -1, -1, -1, 8, -1, -1, -1, -1]),
      name: "Edge Detection", icon: Icons.blur_on),
  ConvolutionFilter(Kernel([-1, -1, 0, -1, 1, 1, 0, 1, 1]),
      name: "Emboss", icon: Icons.blur_on),
  ConvolutionFilter(Kernel([0, 0, 0, 0, 1, 0, 0, 0, 0]),
      name: "Identity", icon: Icons.filter_none),
  BidirectionalEdgeDetection(40),
  AverageDitheringFilter(2),
  MedianCutFilter(2),
];
