import 'dart:typed_data';

abstract class ImageSubFilter {
  void apply(Uint8List data, int width, int height);
}

class ImageFilter extends ImageSubFilter {
  final List<ImageFilter> filters;
  String name;

  ImageFilter(this.name, this.filters);

  @override
  void apply(Uint8List data, int width, int height) {
    for (final filter in filters) {
      filter.apply(data, width, height);
    }
  }

  void addFilter(ImageFilter filter) {
    filters.add(filter);
  }

  void addFilters(List<ImageFilter> filters) {
    this.filters.addAll(filters);
  }
}

class NoFilter extends ImageSubFilter {
  @override
  void apply(Uint8List data, int width, int height) {}
}

class GrayscaleFilter extends ImageSubFilter {
  @override
  void apply(Uint8List data, int width, int height) {
    for (var i = 0; i < data.lengthInBytes; i += 4) {
      final r = data[i];
      final g = data[i + 1];
      final b = data[i + 2];
      final gray = (r + g + b) ~/ 3;
      data[i] = gray;
      data[i + 1] = gray;
      data[i + 2] = gray;
    }
  }
}
