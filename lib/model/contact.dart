class Contact {
  Contact(this.name, this.phoneNumber, this.email);
  String name;
  String phoneNumber;
  String email;

  Map<String, dynamic> toJson() {
    return {
      'name': this.name == null ? "" : this.name,
      'phoneNumber': this.phoneNumber == null ? "" : this.phoneNumber,
      'email': this.email == null ? "" : this.email,
    };
  }
}
