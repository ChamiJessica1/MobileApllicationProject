class Task {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String time;
  final bool isCompleted;
  final bool hasReminder;
  final String? reminderTime;
  final String priority; // 'low', 'medium', 'high'
  final String? category;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isCompleted = false,
    this.hasReminder = false,
    this.reminderTime,
    this.priority = 'medium',
    this.category,
    required this.createdAt,
  });

  // Convert Task to Map for API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'is_completed': isCompleted ? 1 : 0,
      'has_reminder': hasReminder ? 1 : 0,
      'reminder_time': reminderTime,
      'priority': priority,
      'category': category,
      'created_at': createdAt,
    };
  }

  // Convert Task to JSON for API
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // Create Task from API response
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: json['date'],
      time: json['time'],
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      hasReminder: json['has_reminder'] == true || json['has_reminder'] == 1,
      reminderTime: json['reminder_time'],
      priority: json['priority'] ?? 'medium',
      category: json['category'],
      createdAt: json['created_at'],
    );
  }

  // Create a copy with updated fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? time,
    bool? isCompleted,
    bool? hasReminder,
    String? reminderTime,
    String? priority,
    String? category,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, date: $date, time: $time, priority: $priority}';
  }
}
