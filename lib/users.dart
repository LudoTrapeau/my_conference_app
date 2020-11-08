class User {

  final String email;
  final String role;
  static final String columnEmail = "email";
  static final String columnRole = "role";

  User({this.email, this.role});

  Map toMap() {
    Map<String, dynamic> map = {
      columnEmail: email,
      columnRole: role
    };

    return map;
  }

  static User fromMap(Map map) {
    return new User(
        email: map[columnEmail],
        role: map[columnRole]);
  }

}