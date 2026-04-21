class RecommendationModel {
  final int id;
  final int userId;
  final String mood;
  final List<String> exercise;
  final List<String> activities;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const RecommendationModel({
    required this.id,
    required this.userId,
    required this.mood,
    required this.exercise,
    required this.activities,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    return RecommendationModel(
      id:         json['id']         as int,
      userId:     json['user_id']    as int,
      mood:       json['mood']       as String,
      exercise:   parseList(json['exercise']),
      activities: parseList(json['activities']),
      notes:      json['notes']      as String?,
      createdAt:  json['created_at'] as String,
      updatedAt:  json['updated_at'] as String,
    );
  }

  RecommendationModel copyWith({String? notes}) {
    return RecommendationModel(
      id:         id,
      userId:     userId,
      mood:       mood,
      exercise:   exercise,
      activities: activities,
      notes:      notes ?? this.notes,
      createdAt:  createdAt,
      updatedAt:  updatedAt,
    );
  }
}
