import 'package:flutter/material.dart';

import '../data/store.dart';
import '../i18n.dart';
import '../models/usta.dart';
import '../theme.dart';
import '../widgets/usta_widgets.dart';
import 'xarita_screen.dart';

enum UstaFiltr { hammasi, yaqin, reyting, bosh, kafolat }

extension on UstaFiltr {
  String get nom => switch (this) {
        UstaFiltr.hammasi => t('Hammasi'),
        UstaFiltr.yaqin => t('Yaqin atrofda'),
        UstaFiltr.reyting => t('Reyting 4.5+'),
        UstaFiltr.bosh => t("Hozir bo'sh"),
        UstaFiltr.kafolat => t('Kafolatli'),
      };
}

class UstalarScreen extends StatefulWidget {
  const UstalarScreen({super.key, this.kategoriya, this.qidiruv});

  final Kategoriya? kategoriya;
  final String? qidiruv;

  @override
  State<UstalarScreen> createState() => _UstalarScreenState();
}

class _UstalarScreenState extends State<UstalarScreen> {
  UstaFiltr _filtr = UstaFiltr.hammasi;
  late final TextEditingController _qidiruv = TextEditingController(text: widget.qidiruv ?? '');

  @override
  void dispose() {
    _qidiruv.dispose();
    super.dispose();
  }

  List<Usta> _royxat(List<Usta> hammasi) {
    final q = _qidiruv.text.trim().toLowerCase();
    var list = hammasi
        .where((u) => widget.kategoriya == null || u.kategoriyaId == widget.kategoriya!.id)
        .where((u) =>
            q.isEmpty ||
            u.ism.toLowerCase().contains(q) ||
            u.kasb.toLowerCase().contains(q) ||
            t(u.kasb).toLowerCase().contains(q) ||
            u.xizmatlar.any((x) => x.nom.toLowerCase().contains(q)))
        .toList();
    list = Repo.saralangan(list);

    switch (_filtr) {
      case UstaFiltr.yaqin:
        list = list.where((u) => Repo.masofa(u) <= 3).toList()
          ..sort((a, b) => Repo.masofa(a).compareTo(Repo.masofa(b)));
      case UstaFiltr.reyting:
        list = list.where((u) => u.reyting >= 4.5).toList();
      case UstaFiltr.bosh:
        list = list.where((u) => u.bosh).toList();
      case UstaFiltr.kafolat:
        list = list.where((u) => u.kafolat).toList();
      case UstaFiltr.hammasi:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Usta>>(
      valueListenable: Repo.ustalar,
      builder: (context, hammasi, _) {
        final list = _royxat(hammasi);
        final title = widget.kategoriya == null ? t('Barcha ustalar') : t(widget.kategoriya!.nom);
        return Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  '${list.length} ${t('ta usta topildi')}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: t('Xaritada ustalar'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => XaritaScreen(kategoriyaId: widget.kategoriya?.id)),
                ),
                icon: const Icon(Icons.map_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              TextField(
                controller: _qidiruv,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: t("Ism yoki xizmat bo'yicha qidirish"),
                  prefixIcon: const Icon(Icons.search, color: AppColors.subtle),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    for (final f in UstaFiltr.values) ...[
                      ChoiceChip(
                        label: Text(f.nom),
                        selected: _filtr == f,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _filtr = f),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _filtr == f ? Colors.white : AppColors.text,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(color: _filtr == f ? AppColors.primary : AppColors.border),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    Repo.ustalar.value.isEmpty
                        ? t3(
                            "Hozircha ro'yxatdan o'tgan ustalar yo'q. Ustalar qo'shilgach, shu yerda ko'rinadi.",
                            'No registered craftsmen yet. They will appear here once they join.',
                            'Пока нет зарегистрированных мастеров. Они появятся здесь, когда присоединятся.',
                          )
                        : t("Bu filtr bo'yicha usta topilmadi."),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
              for (final u in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: UstaCard(usta: u),
                ),
            ],
          ),
        );
      },
    );
  }
}
