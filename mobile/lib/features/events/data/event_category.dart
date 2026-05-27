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

String categoryLabel(String value) {
  return eventCategories
      .firstWhere(
        (category) => category.value == value,
        orElse: () => EventCategory(value, value),
      )
      .label;
}

