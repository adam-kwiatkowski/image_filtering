import 'dart:typed_data';

abstract class ImageFilter {
  String name;

  ImageFilter(this.name);

  void apply(Uint8List pixels, int width, int height);
}

class CompositeFilter extends ImageFilter {
  List<ImageFilter> filters = [];

  CompositeFilter(this.filters) : super("Composite");

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (var filter in filters) {
      filter.apply(pixels, width, height);
    }
  }
}

class NoFilter extends ImageFilter {
  NoFilter() : super("No filter");
  @override
  void apply(Uint8List pixels, int width, int height) {}
}

Uint8List applyFilters(Map<String, dynamic> args) {
  Uint8List pixels = args['pixels'];
  int width = args['width'];
  int height = args['height'];
  List<ImageFilter> filters = args['filters'];

  for (var i = 0; i < filters.length; i++) {
    filters[i].apply(pixels, width, height);
  }

  return pixels;
}
