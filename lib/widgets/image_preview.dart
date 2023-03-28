import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required ui.Image? image,
  }) : _image = image;

  final ui.Image? _image;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool _originalSize = false;
  final TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: widget._image == null
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
            : Stack(children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    constrained: !_originalSize,
                    minScale: _originalSize ? 1 : 0.5,
                    maxScale: _originalSize ? 1 : 2.5,
                    transformationController: _transformationController,
                    child: RawImage(
                      image: widget._image!,
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(
                        _originalSize ? Icons.zoom_out_map : Icons.zoom_in),
                    onPressed: () {
                      _transformationController.value = Matrix4.identity();
                      setState(() {
                        _originalSize = !_originalSize;
                      });
                    },
                    tooltip: _originalSize ? 'Fit to screen' : 'Original size',
                  ),
                ),
              ]),
      ),
    );
  }
}
