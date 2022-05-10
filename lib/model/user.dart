import 'dart:convert';

class User {
  int place, xp;
  String name;
  bool isUser = false;

  User({
    required this.place,
    required this.name,
    required this.xp,
    required this.isUser,
  });

  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(
      place: jsonData['place'],
      name: jsonData['name'],
      xp: jsonData['xp'],
      isUser: jsonData['isUser'],
    );
  }

  static Map<String, dynamic> toMap(User user) => {
        'place': user.place,
        'name': user.name,
        'xp': user.xp,
        'isUser': user.isUser,
      };

  static String encode(List<User> users) => json.encode(
        users.map<Map<String, dynamic>>((user) => User.toMap(user)).toList(),
      );

  static List<User> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<User>((item) => User.fromJson(item))
          .toList();

  @override
  String toString() {
    return 'User{place: $place, xp: $xp, name: $name, isUser: $isUser}';
  }
}
