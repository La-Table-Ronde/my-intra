class Notifications {
  final String id;
  final String title;
  final DateTime date;
  final bool read;

  Notifications(
      {required this.id,
      required this.title,
      required this.date,
      required this.read});

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'read': read, 'date': date.toString()};
  }

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
        read: json['read']);
  }
}
