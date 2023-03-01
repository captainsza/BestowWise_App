import 'dart:convert';

class UserData {
  final String email;
  final String name;
  final String city;
  final String? image;

  UserData({
    required this.email,
    required this.name,
    required this.city,
    this.image,
  });

  UserData copyWith({
    String? email,
    String? name,
    String? city,
    String? image,
  }) {
    return UserData(
      email: email ?? this.email,
      name: name ?? this.name,
      city: city ?? this.city,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'city': city,
      'image': image,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      email: map['email'] as String,
      name: map['name'] as String,
      city: map['city'] as String,
      image: map['image'] != null ? map['image'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(email: $email, name: $name, city: $city, image: $image)';
  }

  @override
  bool operator ==(covariant UserData other) {
    if (identical(this, other)) return true;

    return other.email == email &&
        other.name == name &&
        other.city == city &&
        other.image == image;
  }

  @override
  int get hashCode {
    return email.hashCode ^ name.hashCode ^ city.hashCode ^ image.hashCode;
  }
}
