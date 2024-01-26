class File {
  final String name;
  final String url;
  final String mime;
  File({required this.name, required this.url, required this.mime});

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'mime': mime};
  }

  factory File.fromJson(Map<String, dynamic> json) {
    return File(name: json['title'], url: json['fullpath'], mime: json['mime']);
  }
}
