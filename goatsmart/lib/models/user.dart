class User {
  final String carrer;
  final String email;
  final String username;
  final String password;
  final String id;
  final String number;
  final String imageUrl;
  final String name;
  final List<String> likedCategories; 

  User({
    required this.carrer,
    required this.email,
    required this.username,
    required this.password,
    required this.id,
    required this.number,
    required this.imageUrl,
    required this.name,
    required this.likedCategories, 
  });

  Map<String, dynamic> toMap() {
    return {
      'carrer': carrer,
      'email': email,
      'username': username,
      'password': password,
      'id': id,
      'number': number,
      'imageUrl': imageUrl,
      'name': name,
      'likedCategories': likedCategories, 
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      carrer: map['carrer'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
      id: map['id'],
      number: map['number'],
      imageUrl: map['imageUrl'],
      name: map['name'],
      likedCategories: List<String>.from(map['likedCategories']), 
    );
  }
}
