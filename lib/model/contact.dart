class Contact {
  Contact(this.id, this.name, this.phoneNumber, this.email);
  String id;
  String name;
  String phoneNumber;
  String? email;

  Map<String, dynamic> toJson() {
    return {
      'name': this.name == null ? "" : this.name,
      'phoneNumber': this.phoneNumber == null ? "" : this.phoneNumber,
      'email': this.email == null ? "" : this.email,
    };
  }

  static Contact fromJson(String id, Map<String, dynamic> json) {
    String name = json['name'];
    String phoneNumber = json['phoneNumber'];
    String email = json['email'];
    return Contact(id, name, phoneNumber, email);
  }
}
