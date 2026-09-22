import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../events/domain/entities/event_filters.dart';
import '../../../events/presentation/event_category.dart';

class MapFilterSelection {
  MapFilterSelection(String? category) : _category = category, filters = null;
  MapFilterSelection.advanced(EventFilters value)
    : filters = value,
      _category = null;
  final String? _category;
  String? get category =>
      filters == null
          ? _category
          : filters!.categories.length == 1
          ? filters!.categories.single
          : null;
  final EventFilters? filters;
}

/// Shared by home, map and event list. Changes stay local until Apply.
class MapFiltersSheet extends StatefulWidget {
  const MapFiltersSheet({
    super.key,
    this.category,
    this.filters,
    this.hasLocation = true,
  });
  final String? category;
  final EventFilters? filters;
  final bool hasLocation;
  @override
  State<MapFiltersSheet> createState() => _MapFiltersSheetState();
}

class _MapFiltersSheetState extends State<MapFiltersSheet> {
  late final Set<String> _categories = {
    ...?widget.filters?.categories,
    if (widget.filters == null && widget.category != null) widget.category!,
  };
  late int _radius = widget.filters?.radiusMeters ?? 20000;
  late DateTime? _from = widget.filters?.startsFrom;
  late DateTime? _before = widget.filters?.startsBefore;
  Future<void> _dates() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 5);
    final range = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange:
          _from == null || _before == null
              ? null
              : DateTimeRange(
                start: _from!,
                end: DateTime(_before!.year, _before!.month, _before!.day - 1),
              ),
    );
    if (!mounted || range == null) return;
    setState(() {
      _from = DateTime(range.start.year, range.start.month, range.start.day);
      _before = DateTime(range.end.year, range.end.month, range.end.day + 1);
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.eventFilters,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: context.l10n.closeFilters,
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(context.l10n.categoriesSelectMoreThanOne),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              FilterChip(
                label: Text(context.l10n.allCategories),
                selected: _categories.isEmpty,
                onSelected: (_) => setState(_categories.clear),
              ),
              for (final category in eventCategories)
                FilterChip(
                  label: Text(
                    categoryLabel(category.value, strings: context.l10n),
                  ),
                  selected: _categories.contains(category.value),
                  onSelected:
                      (selected) => setState(() {
                        if (selected) {
                          _categories.add(category.value);
                        } else {
                          _categories.remove(category.value);
                        }
                      }),
                ),
            ],
          ),
          Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.date_range),
            title: Text(context.l10n.eventStartDate),
            subtitle: Text(
              _from == null || _before == null
                  ? context.l10n.anyDate
                  : '${DateFormat('dd.MM.yyyy').format(_from!)} — ${DateFormat('dd.MM.yyyy').format(DateTime(_before!.year, _before!.month, _before!.day - 1))}',
            ),
            onTap: _dates,
            trailing:
                _from == null
                    ? Icon(Icons.chevron_right)
                    : IconButton(
                      tooltip: context.l10n.clearDates,
                      onPressed:
                          () => setState(() {
                            _from = null;
                            _before = null;
                          }),
                      icon: Icon(Icons.close),
                    ),
          ),
          Divider(height: 32),
          Text(
            context.l10n.radiusKm(((_radius / 1000).round()).toString()),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            min: 1,
            max: 100,
            divisions: 99,
            value: _radius / 1000,
            label: context.l10n.km(((_radius / 1000).round()).toString()),
            onChanged:
                widget.hasLocation
                    ? (value) => setState(() => _radius = value.round() * 1000)
                    : null,
          ),
          Text(
            widget.hasLocation
                ? context.l10n.fromYourSelectedCityOrCurrentLocation
                : context
                    .l10n
                    .aRadiusRequiresYourLocationOrASelectedCityCurrently,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  () => Navigator.pop(
                    context,
                    MapFilterSelection.advanced(
                      EventFilters(
                        categories: List.unmodifiable(_categories),
                        startsFrom: _from,
                        startsBefore: _before,
                        radiusMeters: _radius,
                      ),
                    ),
                  ),
              child: Text(context.l10n.showEvents),
            ),
          ),
          Center(
            child: TextButton(
              onPressed:
                  () => setState(() {
                    _categories.clear();
                    _from = null;
                    _before = null;
                    _radius = 20000;
                  }),
              child: Text(context.l10n.resetAllFilters),
            ),
          ),
        ],
      ),
    ),
  );
}
