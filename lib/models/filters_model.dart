import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/filters.dart';

import '../functional_filters.dart';

class FiltersModel extends ChangeNotifier {
  final List<ImageFilter> _filters = [
    NoFilter(),
    InvertFilter(),
    GrayscaleFilter(),
    CompositeFilter([InvertFilter()])
  ];

  List<ImageFilter> get filters => _filters;

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ImageFilter item = _filters.removeAt(oldIndex);
    _filters.insert(newIndex, item);
    notifyListeners();
  }

  void add(ImageFilter filter) {
    _filters.add(filter);
    notifyListeners();
  }

  void remove(ImageFilter filter) {
    _filters.remove(filter);
    notifyListeners();
  }

  void clear() {
    _filters.clear();
    notifyListeners();
  }
}
