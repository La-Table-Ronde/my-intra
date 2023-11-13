class Projects {
  final String title;
  final DateTime endDate;
  final String module;
  final bool registered;
  final bool registrable;
  final String registerUrl;
  final String filesUrl;

  Projects(
      {required this.title,
      required this.endDate,
      required this.module,
      required this.registered,
      required this.registrable,
      required this.registerUrl,
      required this.filesUrl});
}
