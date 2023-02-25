import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onImageSelected,
  });

  final Function(XFile) onImageSelected;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  XFile? _image;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) => {
        setState(() {
          _isDragging = true;
        })
      },
      onDragExited: (details) => {
        setState(() {
          _isDragging = false;
        })
      },
      onDragDone: (details) => {
        setState(() {
          _image = details.files.first;
          if (_image!.path.endsWith('.png') || _image!.path.endsWith('.jpg')) {
            widget.onImageSelected(_image!);
          } else {
            _image = null;
          }
        })
      },
      child: SizedBox(
        width: 350,
        height: 350,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: _isDragging
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                )
              : null,
          child: _image == null
              ? Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined),
                      SizedBox(
                        height: 15,
                      ),
                      Text("Drag and drop an image here"),
                    ],
                  ),
                )
              : Image.file(File(_image!.path)),
        ),
      ),
    );
  }
}
