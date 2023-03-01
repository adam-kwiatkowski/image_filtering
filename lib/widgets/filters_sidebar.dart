import 'package:flutter/material.dart';
import 'package:image_filtering/filters/filters.dart';
import 'package:provider/provider.dart';

import '../models/active_filters_model.dart';
import '../models/filter_gallery_model.dart';

class FiltersSidebar extends StatelessWidget {
  const FiltersSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var activeFilters = context.watch<ActiveFiltersModel>();
    var filterGallery = context.watch<FilterGalleryModel>();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
                child: ReorderableListView(
              buildDefaultDragHandles: false,
              onReorder: activeFilters.reorder,
              children: [
                for (int i = 0; i < activeFilters.list.length; i++)
                  activeFilters.list[i] is CompositeFilter
                      ? ListTileTheme(
                          dense: true,
                          key: ValueKey(i),
                          child: buildExpansionTile(i, activeFilters),
                        )
                      : ListTileTheme(
                          iconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          key: ValueKey(i),
                          child: buildListTile(i, activeFilters, context)),
              ],
            )),
            Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                        onPressed: activeFilters.list.isNotEmpty
                            ? () {
                                var filter = activeFilters.merge();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Save as a custom filter'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: 'Name',
                                              ),
                                              onChanged: (value) {
                                                filter.name = value;
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              filterGallery.add(filter);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            : null,
                        child: const Text('Save filter'),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      OutlinedButton(
                        onPressed: activeFilters.clear,
                        child: const Text("Clear all"),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  ExpansionTile buildExpansionTile(int i, ActiveFiltersModel filters) {
    var filter = filters.list[i] as CompositeFilter;
    return ExpansionTile(
      title: Text(filter.name),
      controlAffinity: ListTileControlAffinity.leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove'),
              ),
            ];
          }, onSelected: (value) {
            if (value == 'remove') {
              filters.remove(filter);
            }
          }),
          ReorderableDragStartListener(
              index: i, child: const Icon(Icons.drag_handle))
        ],
      ),
      children: [
        for (int j = 0; j < filter.filters.length; j++)
          buildSubListTile(j, filter.filters[j])
      ],
    );
  }

  ListTile buildSubListTile(int i, ImageFilter filter) {
    return ListTile(
      key: ValueKey(i),
      dense: true,
      title: Text(filter.name),
      leading: Icon(filter.icon),
    );
  }

  ListTile buildListTile(
      int i, ActiveFiltersModel filters, BuildContext context) {
    var filter = filters.list[i];
    return ListTile(
      key: ValueKey(i),
      dense: true,
      title: Text(filter.name),
      leading: Icon(filter.icon),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'edit',
                enabled: filter is FilterModel,
                child: const Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove'),
              ),
            ];
          }, onSelected: (value) {
            if (value == 'edit') {
              var model = filter as FilterModel;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Edit ${model.name}"),
                      content: FilterForm(filter: (filters.list[i] as FilterModel)),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              print(model.fields);
                            },
                            child: const Text("Close"))
                      ],
                    );
                  });
            } else if (value == 'remove') {
              filters.remove(filter);
            }
          }),
          ReorderableDragStartListener(
              index: i, child: const Icon(Icons.drag_handle)),
        ],
      ),
    );
  }
}

class FilterForm extends StatefulWidget {
  final FilterModel filter;

  const FilterForm({
    super.key,
    required this.filter,
  });

  @override
  State<FilterForm> createState() => _FilterFormState();
}

class _FilterFormState extends State<FilterForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    widget.filter.fields[0].value = 0;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (var field in widget.filter.fields) buildField(field)],
      ),
    );
  }

  buildField(FilterField field) {
    if (field.type == String) {
      return TextFormField(
        initialValue: field.value,
        decoration: InputDecoration(
          labelText: field.label,
        ),
        onChanged: (value) {
          field.value = value;
        },
      );
    } else if (field.type == int) {
      return TextFormField(
        initialValue: "${field.value}",
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: field.label,
        ),
        onChanged: (value) {
          field.value = int.parse(value);
        },
      );
    } else if (field.type == double) {
      return TextFormField(
        initialValue: "${field.value}",
        decoration: InputDecoration(
          labelText: field.label,
        ),
        onChanged: (value) {
          field.value = double.parse(value);
        },
      );
    } else if (field.type == bool) {
      return CheckboxListTile(
        title: Text(field.label),
        value: field.value,
        onChanged: (value) {
          field.value = value;
        },
      );
    }
  }
}
