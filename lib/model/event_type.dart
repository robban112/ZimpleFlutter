enum EventType { vacation, event, sickness }

EventType stringToEventType(String? string) {
  return EventType.values
      .firstWhere((t) => t.toString() == string, orElse: () => EventType.event);
}
