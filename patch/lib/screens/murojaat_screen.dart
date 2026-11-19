import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/auth.dart';
import '../i18n.dart';
import '../theme.dart';

/// Murojaatlar boradigan Telegram (@ belgisisiz).
const _telegram = 'Muhammadulloh77';

/// Bu oynadagi matnlar uch tilda.
String _m(String uz, String en, String ru) {
  switch (til.value) {
    case 'en':
      return en;
    case 'ru':
      return ru;
    default:
      return uz;
  }
}

class Murojaat {
  final String turi; // 'taklif' | 'shikoyat'
  final String matn;
  final DateTime vaqt;
  Murojaat(this.turi, this.matn, this.vaqt);

  Map<String, dynamic> toJson() => {'t': turi, 'm': matn, 'v': vaqt.toIso8601String()};
  static Murojaat fromJson(Map<String, dynamic> j) =>
      Murojaat(j['t'] as String, j['m'] as String, DateTime.parse(j['v'] as String));
}

/// Chap pastda turadigan "xabar" tugmasi.
class MurojaatTugmasi extends StatelessWidget {
  const MurojaatTugmasi({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'murojaat',
      tooltip: _m('Takliflar va shikoyatlar', 'Suggestions and complaints', 'Предложения и жалобы'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MurojaatScreen()),
      ),
      child: const Icon(Icons.sms_rounded),
    );
  }
}

class MurojaatScreen extends StatefulWidget {
  const MurojaatScreen({super.key});

  @override
  State<MurojaatScreen> createState() => _MurojaatScreenState();
}

class _MurojaatScreenState extends State<MurojaatScreen> {
  static const _kalit = 'murojaatlar_v1';
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  String _turi = 'taklif';
  List<Murojaat> _royxat = [];

  @override
  void initState() {
    super.initState();
    _yukla();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _yukla() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kalit);
    if (s == null) return;
    final l = (jsonDecode(s) as List).map((e) => Murojaat.fromJson(e as Map<String, dynamic>)).toList();
    if (mounted) setState(() => _royxat = l);
  }

  Future<void> _saqla() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kalit, jsonEncode(_royxat.map((e) => e.toJson()).toList()));
  }

  String _turNomi(String t) => t == 'taklif'
      ? _m('💡 Taklif', '💡 Suggestion', '💡 Предложение')
      : _m('⚠️ Shikoyat', '⚠️ Complaint', '⚠️ Жалоба');

  bool _yuborilmoqda = false;

  String _rahmat() => _m(
        '✅ Yozganingiz uchun rahmat! Tez orada operatorlarimiz javob yozishadi.',
        '✅ Thank you for writing! Our operators will reply soon.',
        '✅ Спасибо, что написали! Скоро наши операторы вам ответят.',
      );

  Future<void> _yubor() async {
    final matn = _ctrl.text.trim();
    if (matn.isEmpty || _yuborilmoqda) return;
    final turi = _turi;
    setState(() {
      _yuborilmoqda = true;
      _royxat.add(Murojaat(turi, matn, DateTime.now()));
      _ctrl.clear();
    });
    await _saqla();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    // Telegram chatini tayyor matn bilan ochamiz
    final u = Auth.joriy.value;
    final sarlavha = turi == 'taklif' ? '💡 TAKLIF' : '⚠️ SHIKOYAT';
    final kim = u != null ? '👤 ${u.toliqIsm}\n📞 ${u.telefonChiroyli}\n' : '';
    final text = '$sarlavha (Usta Top ilovasidan)\n$kim\n$matn';
    await Clipboard.setData(ClipboardData(text: text));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final url = Uri.parse('https://t.me/$_telegram?text=${Uri.encodeComponent(text)}');
    var ok = false;
    try {
      ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _yuborilmoqda = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_m(
          "Telegram ochilmadi. Xabaringiz nusxalandi — Telegram'da @$_telegram ga yuboring.",
          'Telegram did not open. Your message was copied — send it to @$_telegram on Telegram.',
          'Telegram не открылся. Сообщение скопировано — отправьте его @$_telegram в Telegram.',
        )),
      ));
    }
  }

  Widget _pufak(String matn, {required bool menDan, String? tepa, DateTime? vaqt}) {
    return Align(
      alignment: menDan ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: menDan ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(menDan ? 18 : 4),
            bottomRight: Radius.circular(menDan ? 4 : 18),
          ),
          border: menDan ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tepa != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(tepa,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: menDan ? Colors.white70 : AppColors.primary)),
              ),
            Text(matn, style: TextStyle(color: menDan ? Colors.white : AppColors.text, fontSize: 15, height: 1.35)),
            if (vaqt != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${vaqt.day.toString().padLeft(2, '0')}.${vaqt.month.toString().padLeft(2, '0')} '
                    '${vaqt.hour.toString().padLeft(2, '0')}:${vaqt.minute.toString().padLeft(2, '0')}  ✓',
                    style: TextStyle(fontSize: 11, color: menDan ? Colors.white70 : AppColors.subtle),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.support_agent, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usta Top', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  Text(_m('Takliflar va shikoyatlar uchun', 'For suggestions and complaints', 'Для предложений и жалоб'),
                      style: const TextStyle(fontSize: 12, color: AppColors.subtle)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              children: [
                _pufak(
                  _m(
                    "Assalomu alaykum! 👋\nBu bo'lim takliflar va shikoyatlar uchun.\n\nIlovani yaxshilash bo'yicha fikringiz yoki biror usta, buyurtma haqida shikoyatingiz bo'lsa — pastda turini tanlab, yozib yuboring. Har bir murojaat ko'rib chiqiladi.",
                    "Hello! 👋\nThis section is for suggestions and complaints.\n\nIf you have an idea to improve the app or a complaint about a craftsman or an order, choose the type below, write it and send. Every message is reviewed.",
                    "Здравствуйте! 👋\nЭтот раздел — для предложений и жалоб.\n\nЕсли у вас есть идея по улучшению приложения или жалоба на мастера или заказ, выберите тип ниже, напишите и отправьте. Каждое обращение рассматривается.",
                  ),
                  menDan: false,
                  tepa: 'Usta Top',
                ),
                for (final m in _royxat) ...[
                  _pufak(m.matn, menDan: true, tepa: _turNomi(m.turi), vaqt: m.vaqt),
                  _pufak(_rahmat(), menDan: false, tepa: 'Usta Top'),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      for (final tur in ['taklif', 'shikoyat'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_turNomi(tur)),
                            selected: _turi == tur,
                            onSelected: (_) => setState(() => _turi = tur),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          minLines: 1,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: _m('Xabaringizni yozing...', 'Type your message...', 'Напишите сообщение...'),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _yuborilmoqda ? null : _yubor,
                        icon: _yuborilmoqda
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
