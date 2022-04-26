import 'dart:convert';

class User {
  int place, xp;
  String name;

  User({
    required this.place,
    required this.name,
    required this.xp,
  });

  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(
      place: jsonData['place'],
      name: jsonData['name'],
      xp: jsonData['xp'],
    );
  }

  static Map<String, dynamic> toMap(User user) => {
        'place': user.place,
        'name': user.name,
        'xp': user.xp,
      };

  static String encode(List<User> users) => json.encode(
        users.map<Map<String, dynamic>>((user) => User.toMap(user)).toList(),
      );

  static List<User> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<User>((item) => User.fromJson(item))
          .toList();
}
