

class Task {
  String id;
  String title;
  String description;
  bool isDone;
  DateTime? dueDate;
  int priority; 

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    this.dueDate,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0, 
      
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      isDone: map['isDone'] == 1, 
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      priority: map['priority'] as int,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}