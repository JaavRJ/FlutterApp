class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  String subject;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.subject,
    this.isCompleted = false,
  });
}

