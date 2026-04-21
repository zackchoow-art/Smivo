import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileForm extends _$ProfileForm {
  @override
  Map<String, String> build() {
    return {
      'fullName': 'Alex Smith',
      'displayName': 'alexsmith',
      'major': 'Computer Science',
      'gradYear': '2025',
    };
  }

  void updateField(String key, String value) {
    state = {...state, key: value};
  }

  void save() {
    // Save logic
  }
}
