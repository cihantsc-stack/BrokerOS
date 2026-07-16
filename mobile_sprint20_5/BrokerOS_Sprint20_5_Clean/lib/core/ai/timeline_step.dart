class AiTimelineStep {
  final String time;
  final String title;
  final String description;
  final bool isCritical;

  const AiTimelineStep({
    required this.time,
    required this.title,
    required this.description,
    this.isCritical = false,
  });
}