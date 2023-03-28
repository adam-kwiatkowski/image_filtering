import 'dart:typed_data';
import 'dart:math';

List<int> hsv2rgb(double hue, double saturation, double value) {
  double chroma = value * saturation;
  double hue1 = hue / 60;
  double x = chroma * (1 - (hue1 % 2 - 1).abs());
  double r1 = 0.0, g1 = 0.0, b1 = 0.0;
  if (hue1 >= 0 && hue1 <= 1) {
    r1 = chroma;
    g1 = x;
    b1 = 0;
  } else if (hue1 >= 1 && hue1 <= 2) {
    r1 = x;
    g1 = chroma;
    b1 = 0;
  } else if (hue1 >= 2 && hue1 <= 3) {
    r1 = 0;
    g1 = chroma;
    b1 = x;
  } else if (hue1 >= 3 && hue1 <= 4) {
    r1 = 0;
    g1 = x;
    b1 = chroma;
  } else if (hue1 >= 4 && hue1 <= 5) {
    r1 = x;
    g1 = 0;
    b1 = chroma;
  } else if (hue1 >= 5 && hue1 <= 6) {
    r1 = chroma;
    g1 = 0;
    b1 = x;
  }

  double m = value - chroma;
  double r = r1 + m;
  double g = g1 + m;
  double b = b1 + m;

  return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
}

List<double> xy2polar(int x, int y) {
  double r = sqrt(x * x + y * y);
  double theta = atan2(y, x);
  return [r, theta];
}

double rad2deg(double rad) {
  return ((rad + pi) / (2 * pi)) * 360;
}

Uint8List generateColorWheel(int diameter) {
  var pixels = Uint8List(diameter * diameter * 4);
  for (var y = 0; y < diameter; y++) {
    for (var x = 0; x < diameter; x++) {
      var i = (y * diameter + x) * 4;
      var px = x - diameter ~/ 2;
      var py = y - diameter ~/ 2;

      var polar = xy2polar(px, py);
      var r = polar[0];
      var theta = polar[1];

      if (r > diameter / 2) {
        pixels[i] = 255;
        pixels[i + 1] = 255;
        pixels[i + 2] = 255;
        pixels[i + 3] = 255;
        continue;
      }

      var hue = rad2deg(theta);
      var saturation = r / (diameter / 2);
      var value = 1.0;
      var rgb = hsv2rgb(hue, saturation, value);
      pixels[i] = rgb[0];
      pixels[i + 1] = rgb[1];
      pixels[i + 2] = rgb[2];
      pixels[i + 3] = 255;
    }
  }
  return pixels;
}