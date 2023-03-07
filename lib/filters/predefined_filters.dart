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
  int brightness;

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
  double contrast;

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
  double gamma;

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
  Kernel kernel;

  ConvolutionFilter(this.kernel,
      {String name = "Convolution filter", IconData icon = Icons.filter})
      : super(name, icon: icon);

  @override
  void apply(Uint8List pixels, int width, int height) {
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
        result[i] = (r / kernel.divisor!).round().clamp(0, 255);
        result[i + 1] = (g / kernel.divisor!).round().clamp(0, 255);
        result[i + 2] = (b / kernel.divisor!).round().clamp(0, 255);
      }
    }

    pixels.setAll(0, result);
  }

  @override
  ParametrizedFilter copyWith(List<FilterParameter> fields) {
    return ConvolutionFilter(fields[0].value, name: name, icon: icon);
  }

  @override
  List<FilterParameter> get fields =>
      [FilterParameter("Kernel", kernel, Kernel)];
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
];
