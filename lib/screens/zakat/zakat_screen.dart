import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});
  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();
  final _stocksCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _debtsCtrl = TextEditingController();

  // Gold price per gram (NGN approx)
  static const double _goldPricePerGram = 95000;
  // Silver price per gram
  static const double _silverPricePerGram = 1100;
  // Nisab in grams: Gold 85g / Silver 595g
  static const double _nisabGold = 85;
  static const double _nisabSilver = 595;

  static const double _zakatRate = 0.025; // 2.5%

  double get _goldGrams => double.tryParse(_goldCtrl.text) ?? 0;
  double get _silverGrams => double.tryParse(_silverCtrl.text) ?? 0;
  double get _cash => double.tryParse(_cashCtrl.text) ?? 0;
  double get _stocks => double.tryParse(_stocksCtrl.text) ?? 0;
  double get _business => double.tryParse(_businessCtrl.text) ?? 0;
  double get _debts => double.tryParse(_debtsCtrl.text) ?? 0;

  double get _goldValue => _goldGrams * _goldPricePerGram;
  double get _silverValue => _silverGrams * _silverPricePerGram;
  double get _totalAssets => _goldValue + _silverValue + _cash + _stocks + _business;
  double get _netWorth => (_totalAssets - _debts).clamp(0, double.infinity);
  double get _nisabValueGold => _nisabGold * _goldPricePerGram;
  double get _zakatDue => _netWorth >= _nisabValueGold ? _netWorth * _zakatRate : 0;
  bool get _aboveNisab => _netWorth >= _nisabValueGold;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    for (final c in [_goldCtrl, _silverCtrl, _cashCtrl, _stocksCtrl, _businessCtrl, _debtsCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_goldCtrl, _silverCtrl, _cashCtrl, _stocksCtrl, _businessCtrl, _debtsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _reset() {
    for (final c in [_goldCtrl, _silverCtrl, _cashCtrl, _stocksCtrl, _businessCtrl, _debtsCtrl]) {
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFFFFDE7),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A3000), Color(0xFFF57F17), Color(0xFFFBC02D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Zakat Calculator',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text('2.5% of wealth above Nisab',
                                  style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () { HapticFeedback.lightImpact(); _reset(); },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Reset', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabs,
                    indicatorColor: Colors.white,
                    indicatorWeight: 2,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    tabs: const [
                      Tab(text: 'Calculator'),
                      Tab(text: 'About Zakat'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tabs ──
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildCalculator(isDark),
                _buildAbout(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculator(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Result card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _aboveNisab
                  ? const LinearGradient(
                      colors: [Color(0xFF4A3000), Color(0xFFF57F17)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : LinearGradient(
                      colors: [
                        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                        isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE),
                      ],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: _aboveNisab
                  ? [BoxShadow(color: const Color(0xFFF57F17).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 5))]
                  : [],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _aboveNisab ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: _aboveNisab ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _aboveNisab ? 'Zakat is Due' : 'Below Nisab',
                      style: TextStyle(
                        color: _aboveNisab ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w700, fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (_totalAssets > 0) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _ResultTile(
                        label: 'Net Wealth', value: _fmt(_netWorth),
                        isGold: _aboveNisab)),
                      const SizedBox(width: 8),
                      Expanded(child: _ResultTile(
                        label: 'Zakat Due', value: _fmt(_zakatDue),
                        isGold: _aboveNisab, big: true)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _ResultTile(
                        label: 'Nisab (Gold)', value: _fmt(_nisabValueGold),
                        isGold: _aboveNisab)),
                    const SizedBox(width: 8),
                    Expanded(child: _ResultTile(
                        label: 'Rate', value: '2.5%',
                        isGold: _aboveNisab)),
                  ]),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Enter your assets below to calculate',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _SectionHeader(label: 'Assets', icon: Icons.account_balance_wallet_rounded, isDark: isDark),
          const SizedBox(height: 10),
          _InputField(ctrl: _goldCtrl, label: 'Gold (grams)', icon: Icons.circle, color: const Color(0xFFFFD700), isDark: isDark,
              hint: '0', subtitle: _goldGrams > 0 ? '≈ ${_fmt(_goldValue)} NGN' : null),
          _InputField(ctrl: _silverCtrl, label: 'Silver (grams)', icon: Icons.circle_outlined, color: Colors.blueGrey, isDark: isDark,
              hint: '0', subtitle: _silverGrams > 0 ? '≈ ${_fmt(_silverValue)} NGN' : null),
          _InputField(ctrl: _cashCtrl, label: 'Cash & Bank Savings (NGN)', icon: Icons.payments_rounded, color: const Color(0xFF2E7D32), isDark: isDark, hint: '0'),
          _InputField(ctrl: _stocksCtrl, label: 'Stocks & Investments (NGN)', icon: Icons.trending_up_rounded, color: const Color(0xFF1565C0), isDark: isDark, hint: '0'),
          _InputField(ctrl: _businessCtrl, label: 'Business Inventory (NGN)', icon: Icons.storefront_rounded, color: const Color(0xFFE65100), isDark: isDark, hint: '0'),

          const SizedBox(height: 14),
          _SectionHeader(label: 'Deductions', icon: Icons.remove_circle_rounded, isDark: isDark),
          const SizedBox(height: 10),
          _InputField(ctrl: _debtsCtrl, label: 'Debts Owed (NGN)', icon: Icons.money_off_rounded, color: const Color(0xFFC62828), isDark: isDark, hint: '0'),

          const SizedBox(height: 14),
          // Nisab reference
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF57F17).withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF57F17).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFF57F17), size: 14),
                  SizedBox(width: 6),
                  Text('Current Nisab Reference', style: TextStyle(color: Color(0xFFF57F17), fontWeight: FontWeight.w700, fontSize: 11)),
                ]),
                const SizedBox(height: 6),
                Text('Gold: ${_nisabGold}g × ₦${_fmtShort(_goldPricePerGram)}/g = ₦${_fmtShort(_nisabValueGold)}',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                Text('Silver: ${_nisabSilver}g × ₦${_fmtShort(_silverPricePerGram)}/g = ₦${_fmtShort(_nisabSilver * _silverPricePerGram)}',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                const SizedBox(height: 4),
                Text('Zakat is calculated on gold Nisab standard by default.',
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(bool isDark) {
    const items = [
      ('What is Zakat?', 'Zakat is one of the Five Pillars of Islam. It is a mandatory annual charity paid on wealth that has been held for a full lunar year (Hawl) and exceeds the Nisab threshold.'),
      ('Who must pay Zakat?', 'Every adult Muslim who owns wealth above the Nisab for a full lunar year must pay Zakat. This applies to gold, silver, cash, business inventory, stocks, and similar assets.'),
      ('What is Nisab?', 'Nisab is the minimum threshold of wealth. It equals either 85 grams of gold OR 595 grams of silver. Most scholars use the gold Nisab.'),
      ('Rate of Zakat', 'The rate is 2.5% (1/40th) of the total zakatable wealth. It is calculated on net wealth after deducting debts that are currently due.'),
      ('When to pay?', 'Zakat becomes due after one full lunar year (354 days) has passed on your wealth exceeding Nisab. Many Muslims pay during Ramadan to multiply rewards.'),
      ('Who receives Zakat?', 'Allah (SWT) named 8 categories in Quran 9:60: the poor (Fuqara), the needy (Masakeen), Zakat collectors, those whose hearts are to be reconciled, freeing captives, debtors, in the way of Allah (fi sabilillah), and the stranded traveller.'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Quranic verse
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A3000), Color(0xFFF57F17)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppTheme.arabicFontFamily, fontSize: 18, height: 1.8, color: Color(0xFFFFECB3)),
              ),
              const SizedBox(height: 8),
              const Text(
                '"Indeed, Zakat is only for the poor, the needy, those employed to collect it..."',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              const Text('— Quran 9:60', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _AboutItem(title: item.$1, body: item.$2, isDark: isDark)),
      ],
    );
  }

  String _fmt(double v) =>
      '₦${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _fmtShort(double v) =>
      v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _ResultTile extends StatelessWidget {
  final String label, value;
  final bool isGold, big;
  const _ResultTile({required this.label, required this.value, required this.isGold, this.big = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isGold ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: isGold ? Colors.white70 : Colors.grey)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(
              fontSize: big ? 15 : 12,
              fontWeight: FontWeight.w700,
              color: isGold ? Colors.white : Colors.grey)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _SectionHeader({required this.label, required this.icon, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: const Color(0xFFF57F17)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF57F17))),
    ]);
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final Color color;
  final bool isDark;
  final String? subtitle;
  const _InputField({required this.ctrl, required this.label, required this.icon, required this.color, required this.isDark, required this.hint, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: ctrl,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final String title, body;
  final bool isDark;
  const _AboutItem({required this.title, required this.body, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF57F17).withValues(alpha: isDark ? 0.15 : 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFF57F17))),
          const SizedBox(height: 5),
          Text(body, style: TextStyle(fontSize: 12, height: 1.6, color: isDark ? Colors.white60 : const Color(0xFF555555))),
        ],
      ),
    );
  }
}
