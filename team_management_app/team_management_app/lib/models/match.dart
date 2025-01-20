class Match {
  final int id;
  final String title;
  final String description;
  final DateTime datetimeStart;
  final DateTime datetimeEnd;

  Match({
    required this.id,
    required this.title,
    required this.description,
    required this.datetimeStart,
    required this.datetimeEnd,
  });

  // Convert JSON to Match object
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      datetimeStart: DateTime.parse(json['datetimeStart']),
      datetimeEnd: DateTime.parse(json['datetimeEnd']),
    );
  }

  // Convert Match object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'datetimeStart': datetimeStart.toIso8601String(),
      'datetimeEnd': datetimeEnd.toIso8601String(),
    };
  }
}
