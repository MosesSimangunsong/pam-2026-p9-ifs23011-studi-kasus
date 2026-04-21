class UserModel {
  final int id;
  final String username;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['id']         as int,
      username:  json['username']   as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'username':   username,
    'created_at': createdAt,
  };
}
