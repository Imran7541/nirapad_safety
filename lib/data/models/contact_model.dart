class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String relation;
  final bool isPrimary;
  final bool canReceiveSms;
  final bool canReceiveCall;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relation = 'অভিভাবক',
    this.isPrimary = false,
    this.canReceiveSms = true,
    this.canReceiveCall = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relation': relation,
      'is_primary': isPrimary ? 1 : 0,
      'can_receive_sms': canReceiveSms ? 1 : 0,
      'can_receive_call': canReceiveCall ? 1 : 0,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      relation: (map['relation'] as String?) ?? 'অভিভাবক',
      isPrimary: (map['is_primary'] as int?) == 1,
      canReceiveSms: (map['can_receive_sms'] as int?) != 0,
      canReceiveCall: (map['can_receive_call'] as int?) != 0,
    );
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relation,
    bool? isPrimary,
    bool? canReceiveSms,
    bool? canReceiveCall,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relation: relation ?? this.relation,
      isPrimary: isPrimary ?? this.isPrimary,
      canReceiveSms: canReceiveSms ?? this.canReceiveSms,
      canReceiveCall: canReceiveCall ?? this.canReceiveCall,
    );
  }
}
