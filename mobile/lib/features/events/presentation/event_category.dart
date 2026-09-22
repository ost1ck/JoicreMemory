import 'package:joicrememory/l10n/localization.dart';

class EventCategory {
  const EventCategory(this.value, this.label);

  final String value;
  final String label;
}

const eventCategories = [
  EventCategory('volunteering', 'Волонтерство'),
  EventCategory('charity', 'Благодійність'),
  EventCategory('cleanup', 'Прибирання'),
  EventCategory('education', 'Освіта'),
  EventCategory('community', 'Громада'),
  EventCategory('emergency', 'Терміново'),
  EventCategory('other', 'Інше'),
];

String categoryLabel(String value, {AppLocalizations? strings}) {
  if (strings != null) {
    return switch (value) {
      'volunteering' => strings.volunteering,
      'charity' => strings.charity,
      'cleanup' => strings.cleanup,
      'education' => strings.education,
      'community' => strings.community,
      'emergency' => strings.urgent,
      'other' => strings.other,
      _ => value,
    };
  }
  return eventCategories
      .firstWhere(
        (category) => category.value == value,
        orElse: () => EventCategory(value, value),
      )
      .label;
}
