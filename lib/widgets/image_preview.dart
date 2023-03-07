import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required ui.Image? image,
  }) : _image = image;

  final ui.Image? _image;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
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
            : InteractiveViewer(
                child: RawImage(
                  image: _image!,
                ),
              ),
      ),
    );
  }
}
