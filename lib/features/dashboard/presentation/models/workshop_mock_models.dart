/// Local mock models (keyin API bilan almashtiriladi).
class PersonAttendance {
  const PersonAttendance({
    required this.id,
    required this.name,
    required this.present,
    this.checkInTime,
  });

  final String id;
  final String name;
  final bool present;
  final String? checkInTime;

  PersonAttendance copyWith({
    String? id,
    String? name,
    bool? present,
    String? checkInTime,
    bool clearTime = false,
  }) {
    return PersonAttendance(
      id: id ?? this.id,
      name: name ?? this.name,
      present: present ?? this.present,
      checkInTime: clearTime ? null : (checkInTime ?? this.checkInTime),
    );
  }
}

class WorkshopTaskItem {
  const WorkshopTaskItem({
    required this.id,
    required this.title,
    required this.assigneeId,
    required this.assigneeName,
  });

  final String id;
  final String title;
  final String assigneeId;
  final String assigneeName;
}
