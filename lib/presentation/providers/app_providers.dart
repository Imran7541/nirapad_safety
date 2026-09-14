import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/local_db.dart';
import '../../data/local/prefs_manager.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/incident_model.dart';
import '../../data/models/medical_profile_model.dart';
import '../../data/models/safety_mode.dart';
import '../../domain/services/sos_engine.dart';

// 1. Singletons and Core
final localDbProvider = Provider<LocalDb>((ref) => LocalDb.instance);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

final prefsManagerProvider = Provider<PrefsManager>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PrefsManager(prefs);
});

// 2. SOS Engine StateNotifier
class SOSEngineNotifier extends StateNotifier<SOSState> {
  final SOSEngine engine;

  SOSEngineNotifier(this.engine) : super(engine.state) {
    engine.addListener(_onEngineUpdate);
  }

  void _onEngineUpdate() {
    state = engine.state;
  }

  void trigger({SafetyMode? mode, String reason = 'ইউজার ট্রিগার', bool bypassCountdown = false}) {
    engine.triggerSOS(mode: mode, reason: reason, bypassCountdown: bypassCountdown);
  }

  Future<bool> cancelOrDuress(String pin) {
    return engine.cancelOrDuress(pin);
  }

  void resolve() {
    engine.resolveEmergency();
  }

  @override
  void dispose() {
    engine.removeListener(_onEngineUpdate);
    super.dispose();
  }
}

final sosEngineProvider = StateNotifierProvider<SOSEngineNotifier, SOSState>((ref) {
  final db = ref.watch(localDbProvider);
  final prefs = ref.watch(prefsManagerProvider);
  final engine = SOSEngine(localDb: db, prefsManager: prefs);
  return SOSEngineNotifier(engine);
});

final rawSosEngineProvider = Provider<SOSEngine>((ref) {
  return ref.watch(sosEngineProvider.notifier).engine;
});

// 3. Current Active Safety Mode
class SafetyModeNotifier extends StateNotifier<SafetyMode> {
  final PrefsManager _prefs;

  SafetyModeNotifier(this._prefs) : super(_prefs.currentMode);

  Future<void> setMode(SafetyMode mode) async {
    state = mode;
    await _prefs.setMode(mode);
  }
}

final safetyModeProvider = StateNotifierProvider<SafetyModeNotifier, SafetyMode>((ref) {
  final prefs = ref.watch(prefsManagerProvider);
  return SafetyModeNotifier(prefs);
});

// 4. Contacts Provider
class ContactsNotifier extends StateNotifier<AsyncValue<List<ContactModel>>> {
  final LocalDb _db;

  ContactsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      final list = await _db.getContacts();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addContact(ContactModel contact) async {
    await _db.insertContact(contact);
    await loadContacts();
  }

  Future<void> updateContact(ContactModel contact) async {
    await _db.updateContact(contact);
    await loadContacts();
  }

  Future<void> deleteContact(String id) async {
    await _db.deleteContact(id);
    await loadContacts();
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, AsyncValue<List<ContactModel>>>((ref) {
  final db = ref.watch(localDbProvider);
  return ContactsNotifier(db);
});

// 5. Medical Profile Provider
class MedicalProfileNotifier extends StateNotifier<AsyncValue<MedicalProfileModel>> {
  final LocalDb _db;

  MedicalProfileNotifier(this._db) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _db.getMedicalProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(MedicalProfileModel profile) async {
    await _db.saveMedicalProfile(profile);
    state = AsyncValue.data(profile);
  }
}

final medicalProfileProvider = StateNotifierProvider<MedicalProfileNotifier, AsyncValue<MedicalProfileModel>>((ref) {
  final db = ref.watch(localDbProvider);
  return MedicalProfileNotifier(db);
});

// 6. Incident History Provider
final incidentHistoryProvider = FutureProvider<List<IncidentModel>>((ref) async {
  final db = ref.watch(localDbProvider);
  return await db.getIncidents();
});
