enum SafetyMode {
  women,
  biker,
  elderly,
}

extension SafetyModeExtension on SafetyMode {
  String get titleBn {
    switch (this) {
      case SafetyMode.women:
        return 'নারী ও শিক্ষার্থী মোড';
      case SafetyMode.biker:
        return 'বাইকার ও হাইওয়ে মোড';
      case SafetyMode.elderly:
        return 'প্রবীণ ও মেডিকেল মোড';
    }
  }

  String get titleEn {
    switch (this) {
      case SafetyMode.women:
        return 'Women & Student Safety';
      case SafetyMode.biker:
        return 'Biker & Highway Safety';
      case SafetyMode.elderly:
        return 'Elderly & Medical ID';
    }
  }

  String get descriptionBn {
    switch (this) {
      case SafetyMode.women:
        return 'সিক্রেট প্যানিক অ্যালার্ট, ফেক কল ও লাইভ রুট শেয়ারিং';
      case SafetyMode.biker:
        return 'ক্র্যাশ ডিটেকশন, স্পিডোমিটার ও দুর্ঘটনা অটো এসওএস';
      case SafetyMode.elderly:
        return 'বিগ-বাটন ওয়ান-ট্যাপ এসওএস, ফল ডিটেকশন ও মেডিকেল কার্ড';
    }
  }
}
