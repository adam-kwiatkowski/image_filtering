import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/filters.dart';
import 'package:provider/provider.dart';

import 'models/active_filters_model.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required ui.Image? image,
  }) : _image = image;

  final ui.Image? _image;

  @override
  Widget build(BuildContext context) {
    var filters = context.watch<ActiveFiltersModel>();
    return SizedBox(
      width: 350,
      height: 350,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Filter results will appear here'),
                ],
              )
            : FutureBuilder<ui.Image>(
                future: buildImage(filters),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RawImage(
                      image: snapshot.data!,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
      ),
    );
  }

  Future<ui.Image> buildImage(ActiveFiltersModel filters) {
    return _image!.toByteData().then((pixels) {
      return compute(applyFilters, {
        'pixels': pixels!.buffer.asUint8List(),
        'width': _image!.width,
        'height': _image!.height,
        'filters': filters.list,
      }).then((result) {
        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(result, _image!.width, _image!.height,
            ui.PixelFormat.rgba8888, completer.complete);
        return completer.future;
      });
    });
  }
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
