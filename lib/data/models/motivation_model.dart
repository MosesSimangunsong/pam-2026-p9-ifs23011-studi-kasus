class Motivation {
  final int id;
  final String text;
  final String createdAt;

  Motivation({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory Motivation.fromJson(Map<String, dynamic> json) {
    return Motivation(
      id: json['id'],
      text: json['text'],
      createdAt: json['created_at'],
    );
  }
}