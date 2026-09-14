class MedicalProfileModel {
  final String fullName;
  final int age;
  final String bloodGroup; // A+, A-, B+, B-, AB+, AB-, O+, O-
  final String chronicConditions;
  final String allergies;
  final String regularMedications;
  final String emergencyDoctorPhone;
  final String preferredHospital;
  final bool isOrganDonor;

  const MedicalProfileModel({
    this.fullName = '',
    this.age = 0,
    this.bloodGroup = 'O+',
    this.chronicConditions = '',
    this.allergies = '',
    this.regularMedications = '',
    this.emergencyDoctorPhone = '',
    this.preferredHospital = '',
    this.isOrganDonor = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'age': age,
      'blood_group': bloodGroup,
      'chronic_conditions': chronicConditions,
      'allergies': allergies,
      'regular_medications': regularMedications,
      'emergency_doctor_phone': emergencyDoctorPhone,
      'preferred_hospital': preferredHospital,
      'is_organ_donor': isOrganDonor ? 1 : 0,
    };
  }

  factory MedicalProfileModel.fromMap(Map<String, dynamic> map) {
    return MedicalProfileModel(
      fullName: (map['full_name'] as String?) ?? '',
      age: (map['age'] as int?) ?? 0,
      bloodGroup: (map['blood_group'] as String?) ?? 'O+',
      chronicConditions: (map['chronic_conditions'] as String?) ?? '',
      allergies: (map['allergies'] as String?) ?? '',
      regularMedications: (map['regular_medications'] as String?) ?? '',
      emergencyDoctorPhone: (map['emergency_doctor_phone'] as String?) ?? '',
      preferredHospital: (map['preferred_hospital'] as String?) ?? '',
      isOrganDonor: (map['is_organ_donor'] as int?) == 1,
    );
  }

  MedicalProfileModel copyWith({
    String? fullName,
    int? age,
    String? bloodGroup,
    String? chronicConditions,
    String? allergies,
    String? regularMedications,
    String? emergencyDoctorPhone,
    String? preferredHospital,
    bool? isOrganDonor,
  }) {
    return MedicalProfileModel(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      regularMedications: regularMedications ?? this.regularMedications,
      emergencyDoctorPhone: emergencyDoctorPhone ?? this.emergencyDoctorPhone,
      preferredHospital: preferredHospital ?? this.preferredHospital,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
    );
  }

  String toSmsSummary() {
    final buffer = StringBuffer();
    if (bloodGroup.isNotEmpty) buffer.write('রক্ত: $bloodGroup | ');
    if (chronicConditions.isNotEmpty) buffer.write('রোগ: $chronicConditions | ');
    if (allergies.isNotEmpty) buffer.write('এলার্জি: $allergies');
    return buffer.toString().trim();
  }
}
