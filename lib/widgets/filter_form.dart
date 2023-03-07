import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_filtering/filters/filters.dart';

class FilterForm extends StatefulWidget {
  final List<FilterParameter> fields;

  const FilterForm({
    super.key,
    required this.fields,
    required this.onSubmit,
  });

  final Function(List<FilterParameter>) onSubmit;

  @override
  State<FilterForm> createState() => _FilterFormState();
}

class _FilterFormState extends State<FilterForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var field in widget.fields) ParameterField(field: field),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit(widget.fields);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ParameterField extends StatefulWidget {
  const ParameterField({
    super.key,
    required this.field,
  });

  final FilterParameter field;

  @override
  State<ParameterField> createState() => _ParameterFieldState();
}

class _ParameterFieldState extends State<ParameterField> {
  @override
  Widget build(BuildContext context) {
    if (widget.field.type == String) {
      return TextFormField(
        initialValue: widget.field.value,
        decoration: InputDecoration(
          labelText: widget.field.label,
        ),
        onChanged: (value) => setState(() {
          widget.field.value = value;
        }),
      );
    } else if (widget.field.type == int) {
      if (widget.field.min != null && widget.field.max != null) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.field.label),
              ],
            ),
            Row(
              children: [
                Text("${widget.field.min}"),
                Expanded(
                  child: Slider(
                    value: (widget.field.value as int).toDouble(),
                    min: (widget.field.min as int).toDouble(),
                    max: (widget.field.max as int).toDouble(),
                    divisions: 100,
                    label: "${widget.field.value}",
                    onChanged: (value) => setState(() {
                      widget.field.value = value.round();
                    }),
                  ),
                ),
                Text("${widget.field.max}"),
              ],
            ),
          ],
        );
      } else {
        return TextFormField(
            initialValue: "${widget.field.value}",
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: widget.field.label,
            ),
            onChanged: (value) => setState(() {
                  try {
                    widget.field.value = int.parse(value);
                  } catch (e) {
                    widget.field.value = 0;
                  }
                }));
      }
    } else if (widget.field.type == double) {
      if (widget.field.min != null && widget.field.max != null) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.field.label),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("${widget.field.min}"),
                Expanded(
                  child: Slider(
                    value: widget.field.value,
                    min: widget.field.min,
                    max: widget.field.max,
                    divisions: 100,
                    label: (widget.field.value as double).toStringAsFixed(2),
                    onChanged: (value) => setState(() {
                      widget.field.value = value;
                    }),
                  ),
                ),
                Text("${widget.field.max}"),
              ],
            ),
          ],
        );
      } else {
        return TextFormField(
          initialValue: "${widget.field.value}",
          decoration: InputDecoration(
            labelText: widget.field.label,
          ),
          onChanged: (value) => setState(() {
            try {
              widget.field.value = double.parse(value);
            } catch (e) {
              widget.field.value = 0.0;
            }
          }),
        );
      }
    } else if (widget.field.type == bool) {
      // switch with a label
      return Row(
        children: [
          Text(widget.field.label),
          Switch(
            value: widget.field.value,
            onChanged: (value) => setState(() {
              widget.field.value = value;
            }),
          ),
        ],
      );
    } else if (widget.field.type == Kernel) {
      var kernel = widget.field.value as Kernel;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kernel values"),
                SizedBox(
                  width: 350,
                  child: Table(
                    children: [
                      for (int i = 0; i < kernel.size!.height; i++)
                        TableRow(children: [
                          for (int j = 0; j < kernel.size!.width; j++)
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(8, 10, 8, 10),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: (i == kernel.anchor!.x &&
                                                j == kernel.anchor!.y)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .outline
                                            : Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                      ),
                                    ),
                                    isDense: true,
                                  ),
                                  controller: TextEditingController(
                                      text: kernel
                                          .values[i * kernel.size!.width + j]
                                          .toString()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => setState(() {
                                    var newList = List<num>.from(kernel.values);
                                    try {
                                      newList[i * kernel.size!.width + j] =
                                          double.parse(value);
                                    } catch (e) {
                                      newList[i * kernel.size!.width + j] = 0.0;
                                    }
                                    widget.field.value =
                                        kernel.copyWith(values: newList);
                                  }),
                                ),
                              ),
                            )
                        ])
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Anchor"),
                SizedBox(
                  width: 126,
                  child: Table(
                    defaultColumnWidth: const FixedColumnWidth(10),
                    children: [
                      for (int i = 0; i < kernel.size!.height; i++)
                        TableRow(children: [
                          for (int j = 0; j < kernel.size!.width; j++)
                            TableCell(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  widget.field.value =
                                      kernel.copyWith(anchor: Point(i, j));
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    color: (i == kernel.anchor!.x &&
                                            j == kernel.anchor!.y)
                                        ? Theme.of(context).colorScheme.outline
                                        : Theme.of(context)
                                            .colorScheme
                                            .outlineVariant,
                                  ),
                                ),
                              ),
                            )
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(mainAxisSize: MainAxisSize.max, children: [
          SizedBox(
            width: 50,
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Width",
              ),
              controller: TextEditingController(text: "${kernel.size!.width}"),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                try {
                  var width = int.parse(value).clamp(1, 9);
                  widget.field.value = kernel.copyWith(
                      size: KernelSize(width, kernel.size!.height),
                      values: List.generate(
                          width * kernel.size!.height, (index) => 0));
                } catch (e) {
                  widget.field.value = kernel.copyWith(
                      size: KernelSize(1, kernel.size!.height),
                      values:
                          List.generate(1 * kernel.size!.height, (index) => 0));
                }
              }),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text("x"),
          ),
          SizedBox(
            width: 50,
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Height",
              ),
              controller: TextEditingController(text: "${kernel.size!.height}"),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                try {
                  var height = int.parse(value).clamp(1, 9);
                  widget.field.value = kernel.copyWith(
                      size: KernelSize(kernel.size!.width, height),
                      values: List.generate(
                          kernel.size!.width * height, (index) => 0));
                } catch (e) {
                  widget.field.value = kernel.copyWith(
                      size: KernelSize(kernel.size!.width, 1),
                      values:
                          List.generate(kernel.size!.width * 1, (index) => 0));
                }
              }),
            ),
          ),
        ]),
        Row(children: [
          SizedBox(
              width: 100,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Offset",
                ),
                controller: TextEditingController(text: "${kernel.offset!}"),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  try {
                    widget.field.value =
                        kernel.copyWith(offset: double.parse(value));
                  } catch (e) {
                    widget.field.value = kernel.copyWith(offset: 0.0);
                  }
                }),
              ))
        ]),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Divisor",
                ),
                controller: TextEditingController(
                    text: "${kernel.divisor == 0 ? "" : kernel.divisor}"),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  try {
                    widget.field.value =
                        kernel.copyWith(divisor: double.parse(value));
                  } catch (e) {
                    widget.field.value = kernel.copyWith(divisor: 0.0);
                  }
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextButton(
                child: const Text("Auto"),
                onPressed: () => setState(() {
                  widget.field.value = kernel.copyWith(
                      divisor: kernel.values.reduce((a, b) => a + b));
                }),
              ),
            )
          ],
        ),
      ]);
    }
    return const Text("Unsupported type");
  }
}
