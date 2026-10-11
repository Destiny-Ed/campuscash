enum GigType {
  microTask,
  tutoring,
  notes,
  campusGig,
  projectWriting, // essays, reports, research, proposals
  skillGig,       // design, coding, video, etc.
}

class Gig {
  final String id;
  final String title;
  final String description;
  final GigType type;
  final double budget;
  final String currency;
  final String postedBy;
  final String? courseCode;
  final String universityId;
  final String status; // open, in_progress, completed, cancelled
  final DateTime? deadline;
  final List<String> tags;
  final DateTime createdAt;

  Gig({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.budget,
    this.currency = 'USD',
    required this.postedBy,
    this.courseCode,
    required this.universityId,
    this.status = 'open',
    this.deadline,
    this.tags = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'budget': budget,
        'currency': currency,
        'postedBy': postedBy,
        'courseCode': courseCode,
        'universityId': universityId,
        'status': status,
        'deadline': deadline?.toIso8601String(),
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
      };
}
