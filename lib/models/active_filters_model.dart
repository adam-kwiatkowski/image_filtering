import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/filters/filters.dart';

class ActiveFiltersModel extends ChangeNotifier {
  final List<ImageFilter> _filters = [];

  List<ImageFilter> get list => _filters;

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

  void update(ImageFilter filter, int index) {
    _filters[index] = filter;
    notifyListeners();
  }

  void clear() {
    _filters.clear();
    notifyListeners();
  }

  ImageFilter merge() {
    if (_filters.length == 1) {
      if (_filters[0] is ParametrizedFilter) {
        var filter = _filters[0] as ParametrizedFilter;
        return filter.copyWith(filter.fields);
      }
    }
    List<ImageFilter> filters = [];
    for (var i = 0; i < _filters.length; i++) {
      if (_filters[i] is CompositeFilter) {
        filters.addAll((_filters[i] as CompositeFilter).filters);
      } else {
        filters.add(_filters[i]);
      }
    }
    return CompositeFilter(filters);
  }
}
