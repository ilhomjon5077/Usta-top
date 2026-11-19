import 'package:flutter/material.dart';

import '../data/auth.dart';
import '../data/joylashuv.dart';
import '../data/sample_data.dart';
import '../data/store.dart';
import '../i18n.dart';
import '../models/usta.dart';
import '../theme.dart';
import '../widgets/shoshilinch_sheet.dart';
import '../widgets/usta_widgets.dart';
import 'ustalar_screen.dart';
import 'xarita_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onSeeAllUstalar,
    required this.onJoylashuvTap,
    required this.onDokonTap,
  });

  final VoidCallback onSeeAllUstalar;
  final VoidCallback onJoylashuvTap;
  final VoidCallback onDokonTap;

  void _openUstalar(BuildContext context, {Kategoriya? kategoriya, String? qidiruv}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UstalarScreen(kategoriya: kategoriya, qidiruv: qidiruv)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder<List<Usta>>(
        valueListenable: Repo.ustalar,
        builder: (context, ustalar, _) {
          final topUstalar = Repo.saralangan(ustalar).take(8).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              // --- Sarlavha ---
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<Foydalanuvchi?>(
                      valueListenable: Auth.joriy,
                      builder: (context, u, _) => Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                            child: Text(u?.initsiallar ?? '',
                                style: const TextStyle(
                                    color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 17)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t('Xayrli kun,'),
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
                                Text(u?.toliqIsm ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const XaritaScreen()),
                    ),
                    tooltip: t('Xaritada ustalar'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      fixedSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.map_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Joylashuv va asosiy sarlavha ---
              _JoylashuvQatori(onTap: onJoylashuvTap),
              const SizedBox(height: 6),
              Text(
                t('Uyingiz uchun ishonchli usta toping'),
                style: const TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, letterSpacing: -0.4),
              ),
              const SizedBox(height: 18),

              // --- Qidiruv ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => _openUstalar(context, qidiruv: v),
                      decoration: InputDecoration(
                        hintText: t('Usta yoki xizmatni qidiring'),
                        prefixIcon: const Icon(Icons.search, color: AppColors.subtle),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: () => _openUstalar(context),
                    tooltip: t('Filtrlar'),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(54, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Shoshilinch usta ---
              Material(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => showShoshilinchSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFB91C1C), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.bolt, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t('Shoshilinch usta'),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text(t('Quvur yorildimi, tok o\'chdimi? Eng yaqin ustani chaqiring'),
                                  style: const TextStyle(color: Color(0xFFFEE2E2), fontSize: 13, height: 1.3)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // --- Kategoriyalar ---
              SectionTitle(t('Kategoriyalar'), onSeeAll: onSeeAllUstalar),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kategoriyalar.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, i) {
                  final k = kategoriyalar[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openUstalar(context, kategoriya: k),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: AppDecor.card(radius: 18),
                          child: Icon(k.icon, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t(k.nom),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // --- Top ustalar ---
              SectionTitle(t('Top ustalar'), onSeeAll: onSeeAllUstalar),
              const SizedBox(height: 8),
              if (topUstalar.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: AppDecor.card(),
                  child: Column(
                    children: [
                      const Icon(Icons.engineering_outlined, size: 40, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        t3(
                          "Hozircha ustalar yo'q",
                          'No craftsmen yet',
                          'Пока нет мастеров',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t3(
                          "Ustalar ilovada ro'yxatdan o'tgach, shu yerda ko'rinadi.",
                          'Craftsmen will appear here once they register in the app.',
                          'Мастера появятся здесь после регистрации в приложении.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: topUstalar.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => TopUstaCard(usta: topUstalar[i]),
                ),
              ),
              const SizedBox(height: 22),

              // --- Do'kon ---
              Material(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onDokonTap,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, color: Color(0xFFFBBF24), size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t('Ehtiyot qismlar do\'koni'),
                                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                              Text(t('Kran, smesitel, kabel, rozetka va boshqalar'),
                                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bosh sahifadagi "qayerdasiz" qatori.
class _JoylashuvQatori extends StatelessWidget {
  const _JoylashuvQatori({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JoylashuvHolat>(
      valueListenable: Joylashuv.holat,
      builder: (context, h, _) {
        final String matn;
        Color rang = AppColors.muted;
        switch (h) {
          case JoylashuvHolat.tayyor:
            matn = Joylashuv.manzil.value ?? t('Joylashuv aniqlandi');
          case JoylashuvHolat.aniqlanmoqda:
            matn = t('Joylashuv aniqlanmoqda...');
          case JoylashuvHolat.ochiqEmas:
          case JoylashuvHolat.ruxsatYoq:
          case JoylashuvHolat.xato:
            matn = t('Joylashuv yoqilmagan — yoqish uchun bosing');
            rang = AppColors.danger;
        }
        return InkWell(
          onTap: h == JoylashuvHolat.tayyor || h == JoylashuvHolat.aniqlanmoqda ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(h == JoylashuvHolat.tayyor ? Icons.location_on : Icons.location_off_outlined,
                    size: 16, color: h == JoylashuvHolat.tayyor ? AppColors.primary : rang),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(matn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: rang, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
