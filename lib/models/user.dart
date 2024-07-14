enum Gender { male, female, other }

class User {
  String? id;
  int? schemaVersion;
  String firstName;
  String lastName;
  int mobileNumber;
  String emailId;
  String? uniqueId;
  DateTime dob;
  Gender gender;

  User({
    required this.id,
    required this.schemaVersion,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.emailId,
    required this.dob,
    required this.gender,
    required this.uniqueId,
  });

  // Factory constructor for creating a new User instance from a map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      schemaVersion: json['schemaVersion'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      mobileNumber: json['mobileNumber'],
      emailId: json['emailID'],
      dob: DateTime.parse(json['dob']),
      gender: _genderFromString(json['gender']),
      uniqueId: json['uniqueID'],
    );
  }

  // Helper method to convert gender string to Gender enum
  static Gender _genderFromString(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
}

// Method to convert User instance to a map, excluding specific fields
Map<String, dynamic> toJson(User user) {
  return {
    '_id': user.id,
    'schemaVersion': user.schemaVersion,
    'firstName': user.firstName,
    'lastName': user.lastName,
    'mobileNumber': user.mobileNumber,
    'emailID': user.emailId,
    'dob': user.dob.toIso8601String(),
    'gender': genderToString(user.gender),
    'uniqueID': user.uniqueId,
  };
}

// Helper method to convert Gender enum to string
String genderToString(Gender gender) {
  switch (gender) {
    case Gender.male:
      return 'Male';
    case Gender.female:
      return 'Female';
    case Gender.other:
      return 'Other';
  }
}
