class Event {
  final String? scolaryear;
  final String? codemodule;
  final String? codeinstance;
  final String? codeacti;
  final String? codeevent;
  final int semester;
  final String? instanceLocation;
  final String? titlemodule;
  final String? actiTitle;
  final int numEvent;
  DateTime start;
  DateTime end;
  final int totalStudentsRegistered;
  final String? title;
  final String? typeTitle;
  final String? typeCode;
  final String? isRdv;
  final String? nbHours;
  final DateTime allowedPlanningStart;
  final DateTime allowedPlanningEnd;
  final int nbGroup;
  final bool moduleAvailable;
  final bool moduleRegistered;
  final bool past;
  final bool allowRegister;
  final dynamic eventRegistered;
  final String? display;
  final String? rdvGroupRegistered;
  final dynamic rdvIndivRegistered;
  final bool allowToken;
  final bool registerStudent;
  final bool registerProf;
  final bool registerMonth;
  final bool inMoreThanOneMonth;
  final Map<String?, dynamic>? room;

  Event({
    required this.scolaryear,
    required this.codemodule,
    required this.codeinstance,
    required this.codeacti,
    required this.codeevent,
    required this.semester,
    required this.instanceLocation,
    required this.titlemodule,
    required this.actiTitle,
    required this.numEvent,
    required this.start,
    required this.end,
    required this.totalStudentsRegistered,
    required this.title,
    required this.typeTitle,
    required this.typeCode,
    required this.isRdv,
    required this.nbHours,
    required this.allowedPlanningStart,
    required this.allowedPlanningEnd,
    required this.nbGroup,
    required this.moduleAvailable,
    required this.moduleRegistered,
    required this.past,
    required this.allowRegister,
    required this.eventRegistered,
    required this.display,
    required this.rdvGroupRegistered,
    required this.rdvIndivRegistered,
    required this.allowToken,
    required this.registerStudent,
    required this.registerProf,
    required this.registerMonth,
    required this.inMoreThanOneMonth,
    required this.room,
  });

  factory Event.fromJson(Map<String?, dynamic> json) {
    return Event(
      scolaryear: json['scolaryear'],
      codemodule: json['codemodule'],
      codeinstance: json['codeinstance'],
      codeacti: json['codeacti'],
      codeevent: json['codeevent'],
      semester: json['semester'],
      instanceLocation: json['instance_location'],
      titlemodule: json['titlemodule'],
      actiTitle: json['acti_title'],
      numEvent: json['num_event'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      totalStudentsRegistered: json['total_students_registered'],
      title: json['title'],
      typeTitle: json['type_title'],
      typeCode: json['type_code'],
      isRdv: json['is_rdv'],
      nbHours: json['nb_hours'],
      allowedPlanningStart: DateTime.parse(json['allowed_planning_start']),
      allowedPlanningEnd: DateTime.parse(json['allowed_planning_end']),
      nbGroup: json['nb_group'],
      moduleAvailable: json['module_available'],
      moduleRegistered: json['module_registered'],
      past: json['past'],
      allowRegister: json['allow_register'],
      eventRegistered: json['event_registered'],
      display: json['display'],
      rdvGroupRegistered: json['rdv_group_registered'],
      rdvIndivRegistered: json['rdv_indiv_registered'],
      allowToken: json['allow_token'],
      registerStudent: json['register_student'],
      registerProf: json['register_prof'],
      registerMonth: json['register_month'],
      inMoreThanOneMonth: json['in_more_than_one_month'],
      room: json['room'] != null ? Map<String, dynamic>.from(json['room']) : {},
    );
  }
  Map<String?, dynamic> toJson() {
    return {
      'scolaryear': scolaryear,
      'codemodule': codemodule,
      'codeinstance': codeinstance,
      'codeacti': codeacti,
      'codeevent': codeevent,
      'semester': semester,
      'instance_location': instanceLocation,
      'titlemodule': titlemodule,
      'acti_title': actiTitle,
      'num_event': numEvent,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'total_students_registered': totalStudentsRegistered,
      'title': title,
      'type_title': typeTitle,
      'type_code': typeCode,
      'is_rdv': isRdv,
      'nb_hours': nbHours,
      'allowed_planning_start': allowedPlanningStart.toIso8601String(),
      'allowed_planning_end': allowedPlanningEnd.toIso8601String(),
      'nb_group': nbGroup,
      'module_available': moduleAvailable,
      'module_registered': moduleRegistered,
      'past': past,
      'allow_register': allowRegister,
      'event_registered': eventRegistered,
      'display': display,
      'rdv_group_registered': rdvGroupRegistered,
      'rdv_indiv_registered': rdvIndivRegistered,
      'allow_token': allowToken,
      'register_student': registerStudent,
      'register_prof': registerProf,
      'register_month': registerMonth,
      'in_more_than_one_month': inMoreThanOneMonth,
    };
  }
}
