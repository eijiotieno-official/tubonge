import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';

final phoneNumberProvider =
    StateProvider.autoDispose<PhoneModel?>((ref) => null);
