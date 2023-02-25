import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/filters.dart';

import '../base_filters.dart';

class FilterGalleryModel extends ChangeNotifier {
  final List<ImageFilter> _filters = predefinedFilters;

  List<ImageFilter> get list => _filters;

  void add(ImageFilter filter) {
    _filters.add(filter);
    notifyListeners();
  }

  void remove(ImageFilter filter) {
    _filters.remove(filter);
    notifyListeners();
  }
}
