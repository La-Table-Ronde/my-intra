class Notifications {
  final String id;
  final String title;
  final DateTime date;
  bool read;
  bool notifSent;

  Notifications(
      {required this.id,
      required this.title,
      required this.date,
      required this.read,
      required this.notifSent});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'read': read,
      'date': date.toString(),
      'notifSent': notifSent
    };
  }

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
        read: json['read'],
        notifSent: json['notifSent'] ?? true);
  }
}
