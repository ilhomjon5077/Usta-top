import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n_data.dart';

/// Ilova tili: 'uz', 'en' yoki 'ru'.
final til = ValueNotifier<String>('uz');

/// Til hali tanlanmagan bo'lsa (ilova birinchi marta ochilganda) — true.
final tilTanlanmagan = ValueNotifier<bool>(true);

const tillar = [
  ('uz', "O'zbekcha", '🇺🇿'),
  ('en', 'English', '🇬🇧'),
  ('ru', 'Русский', '🇷🇺'),
];

Future<void> tilYukla() async {
  final p = await SharedPreferences.getInstance();
  final s = p.getString('til');
  til.value = s ?? 'uz';
  tilTanlanmagan.value = s == null;
}

Future<void> tilOrnat(String yangi) async {
  til.value = yangi;
  tilTanlanmagan.value = false;
  final p = await SharedPreferences.getInstance();
  await p.setString('til', yangi);
}

String tilNomi(String kod) {
  for (final x in tillar) {
    if (x.$1 == kod) return x.$2;
  }
  return kod;
}

/// O'zbekcha matnni tanlangan tilga o'giradi.
/// Tarjimasi bo'lmasa, o'zbekchasi qaytadi.
String t(String uz) {
  switch (til.value) {
    case 'ru':
      return ruTarjima[uz] ?? uz;
    case 'en':
      return enTarjima[uz] ?? uz;
    default:
      return uz;
  }
}

/// Uch tildagi matndan tanlangan tildagisini qaytaradi.
String t3(String uz, String en, String ru) {
  switch (til.value) {
    case 'ru':
      return ru;
    case 'en':
      return en;
    default:
      return uz;
  }
}
