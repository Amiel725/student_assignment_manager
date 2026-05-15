class Assignment {
  final int id;
  final int userId;
  String title;
  String body;
  bool isCompleted;
  String subject;
  String dueDate;

  Assignment({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isCompleted = false,
    this.subject = 'Math',
    this.dueDate = '',
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    final subjects = ['Math', 'Science', 'English', 'Amharic', 'Art', 'Physics', 'CTE'];
    final dueDates = ['2026-05-20', '2026-05-21', '2026-05-22', '2026-05-25', '2026-05-26'];

    return Assignment(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      isCompleted: (json['id'] as int) % 3 == 0, // simulate some completed
      subject: subjects[(json['id'] as int) % subjects.length],
      dueDate: dueDates[(json['id'] as int) % dueDates.length],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  Assignment copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    bool? isCompleted,
    String? subject,
    String? dueDate,
  }) {
    return Assignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isCompleted: isCompleted ?? this.isCompleted,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}