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
      FilterParameter("Contrast", contrast, double, min: -1, max: 1),
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
      FilterParameter("Gamma", gamma, double, min: 0.1, max: 10),
  ];
}

class ConvolutionFilter extends ImageFilter {
  List<double> kernel;
  int kernelSize;
  double divisor;
  double bias;

  ConvolutionFilter(this.kernel,
      {this.divisor = 1,
      this.bias = 0,
      name = "Convolution",
      icon = Icons.blur_on})
      : kernelSize = sqrt(kernel.length).round(),
        super(name, icon: icon);

  @override
  void apply(Uint8List pixels, int width, int height) {
    var newPixels = Uint8List.fromList(pixels);

    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      var x = (i / 4) % width;
      var y = (i / 4) ~/ width;

      var r = 0.0;
      var g = 0.0;
      var b = 0.0;

      for (var ky = 0; ky < kernelSize; ky++) {
        for (var kx = 0; kx < kernelSize; kx++) {
          var dx = x + kx - kernelSize ~/ 2;
          var dy = y + ky - kernelSize ~/ 2;

          if (dx < 0 || dx >= width || dy < 0 || dy >= height) {
            continue;
          }

          var pixelIndex = ((dy * width + dx) * 4).round();
          var kernelIndex = ky * kernelSize + kx;

          r += pixels[pixelIndex] * kernel[kernelIndex];
          g += pixels[pixelIndex + 1] * kernel[kernelIndex];
          b += pixels[pixelIndex + 2] * kernel[kernelIndex];
        }
      }

      newPixels[i] = (r / divisor + bias).round().clamp(0, 255);
      newPixels[i + 1] = (g / divisor + bias).round().clamp(0, 255);
      newPixels[i + 2] = (b / divisor + bias).round().clamp(0, 255);
    }

    pixels.setAll(0, newPixels);
  }
}

// invert, grayscale, brightness, contrast, gamma correction, blur, gaussian blur, sharpen, edge detection, emboss
var predefinedFilters = [
  InvertFilter(),
  GrayscaleFilter(),
  BrightnessFilter(50),
  ContrastFilter(.5),
  GammaCorrectionFilter(2),
  ConvolutionFilter([
    1, 1, 1,
    1, 1, 1,
    1, 1, 1
  ], name: "Blur", icon: Icons.blur_linear),
  ConvolutionFilter([
    0, 1, 0,
    1, 4, 1,
    0, 1, 0
  ], name: "Gaussian Blur", icon: Icons.blur_on),
  ConvolutionFilter([
    0, -1, 0,
    -1, 5, -1,
    0, -1, 0
  ], name: "Sharpen", icon: Icons.deblur),
  ConvolutionFilter([
    -1, -1, -1,
    -1, 8, -1,
    -1, -1, -1
  ], name: "Edge Detection", icon: Icons.blur_on),
  ConvolutionFilter([
    -1, -1, 0,
    -1, 1, 1,
    0, 1, 1
  ], name: "Emboss", icon: Icons.blur_on),
];
