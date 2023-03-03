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
              ElevatedButton(
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
    }
    return const Text("Unsupported type");
  }
}
