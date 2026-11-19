import 'package:flutter/material.dart';

import '../data/auth.dart';
import '../data/joylashuv.dart';
import '../data/store.dart';
import '../i18n.dart';
import '../theme.dart';
import 'buyurtmalar_screen.dart';
import 'dokon_screen.dart';
import 'home_screen.dart';
import 'murojaat_screen.dart';
import 'profil_screen.dart';
import 'usta_anketa_screen.dart';
import 'ustalar_screen.dart';

/// Pastki menyuli asosiy oyna: Bosh sahifa, Ustalar, Buyurtmalar, Profil.
/// Har safar ochilganda geolokatsiyani tekshiradi.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  bool _oynaOchiq = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _joylashuvniTekshir();
    // "Ustaman" deb ro'yxatdan o'tgan, lekin anketani to'ldirmagan bo'lsa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (Auth.joriy.value?.ustami ?? false) && Repo.meningUstam == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UstaAnketaScreen()));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ilovaga qaytganda (masalan sozlamalardan) qayta tekshiramiz
    if (state == AppLifecycleState.resumed && Joylashuv.holat.value != JoylashuvHolat.tayyor) {
      _joylashuvniTekshir();
    }
  }

  Future<void> _joylashuvniTekshir() async {
    await Joylashuv.aniqlash();
    if (!mounted) return;
    final h = Joylashuv.holat.value;
    if (h == JoylashuvHolat.ochiqEmas || h == JoylashuvHolat.ruxsatYoq) {
      _yoqishniSora(h);
    }
  }

  Future<void> _yoqishniSora(JoylashuvHolat h) async {
    if (_oynaOchiq) return;
    _oynaOchiq = true;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.location_on, color: AppColors.primary, size: 36),
        title: Text(t('Joylashuvni yoqing')),
        content: Text(
          h == JoylashuvHolat.ochiqEmas
              ? t("Telefoningizda joylashuv (GPS) o'chiq. Yaqin atrofdagi ustalarni ko'rsatishimiz uchun uni yoqing.")
              : t("Yaqin atrofdagi ustalarni ko'rsatishimiz uchun ilovaga joylashuvdan foydalanishga ruxsat bering."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Keyinroq'))),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Joylashuv.sozlamalarniOch();
            },
            child: Text(t('Yoqish')),
          ),
        ],
      ),
    );
    _oynaOchiq = false;
  }

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const MurojaatTugmasi(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSeeAllUstalar: () => _goTo(1),
            onJoylashuvTap: _joylashuvniTekshir,
            onDokonTap: () => _goTo(3),
          ),
          const UstalarScreen(),
          const BuyurtmalarScreen(),
          const DokonScreen(),
          ProfilScreen(onOrdersTap: () => _goTo(2)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t('Bosh sahifa'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: t('Ustalar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: t('Buyurtmalar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: t("Do'kon"),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: t('Profil'),
          ),
        ],
      ),
    );
  }
}
