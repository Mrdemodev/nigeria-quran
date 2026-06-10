import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/quiz_data.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

enum _Difficulty { easy, medium, hard }

const _easyCategories = ['Pillars', 'Prayer', 'Prophets'];
const _hardCategories = ['Arabic', 'Angels', 'History'];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  bool _started = false;
  bool _finished = false;
  _Difficulty _difficulty = _Difficulty.medium;
  bool _timedMode = true;

  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  Timer? _timer;
  int _secondsLeft = 30;
  List<Map<String, dynamic>> _history = [];

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  int get _timeLimit => _difficulty == _Difficulty.easy ? 45 : _difficulty == _Difficulty.medium ? 30 : 20;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('quiz_history') ?? [];
    if (!mounted) return;
    setState(() {
      _history = raw.map((e) {
        final parts = e.split(',');
        return {'score': int.parse(parts[0]), 'total': int.parse(parts[1]), 'difficulty': parts[2], 'date': parts[3]};
      }).toList();
    });
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('quiz_history') ?? [];
    final now = DateTime.now();
    raw.insert(0, '$_score,${_questions.length},${_difficulty.name},${now.day}/${now.month}/${now.year}');
    if (raw.length > 5) raw.removeLast();
    await prefs.setStringList('quiz_history', raw);
    await _loadHistory();
  }

  void _loadQuestions() {
    List<QuizQuestion> pool;
    switch (_difficulty) {
      case _Difficulty.easy:
        pool = kQuizQuestions.where((q) => _easyCategories.contains(q.category)).toList();
        if (pool.length < 5) pool = kQuizQuestions.toList();
        break;
      case _Difficulty.hard:
        pool = kQuizQuestions.where((q) => _hardCategories.contains(q.category)).toList();
        if (pool.length < 5) pool = kQuizQuestions.toList();
        break;
      case _Difficulty.medium:
        pool = List<QuizQuestion>.from(kQuizQuestions);
        break;
    }
    pool.shuffle(Random());
    _questions = pool.take(10).toList();
    _slideCtrl.forward(from: 0);
  }

  void _startQuiz() {
    setState(() {
      _started = true;
      _finished = false;
      _index = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
    });
    _loadQuestions();
    if (_timedMode) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _timeLimit);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        if (!_answered) _autoFail();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _autoFail() {
    HapticFeedback.heavyImpact();
    setState(() { _answered = true; _selectedAnswer = null; });
  }

  void _select(int option) {
    if (_answered) return;
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _selectedAnswer = option;
      _answered = true;
      if (option == _questions[_index].correctIndex) _score++;
    });
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() { _index++; _selectedAnswer = null; _answered = false; });
      _slideCtrl.forward(from: 0);
      if (_timedMode) _startTimer();
    } else {
      _timer?.cancel();
      _saveScore();
      setState(() => _finished = true);
    }
  }

  void _restart() {
    _timer?.cancel();
    setState(() { _started = false; _finished = false; });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    if (!_started) {
      return _StartScreen(
        isDark: isDark, difficulty: _difficulty, timedMode: _timedMode, history: _history,
        onDifficulty: (d) => setState(() => _difficulty = d),
        onTimedMode: (v) => setState(() => _timedMode = v),
        onStart: _startQuiz,
        onExit: () => Navigator.pop(context),
      );
    }

    if (_finished) {
      return _ResultScreen(score: _score, total: _questions.length, difficulty: _difficulty, isDark: isDark, onRestart: _restart, onExit: () => Navigator.pop(context));
    }

    final q = _questions[_index];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () { _timer?.cancel(); Navigator.pop(context); },
                          child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close_rounded, color: Colors.white, size: 20)),
                        ),
                        Expanded(
                          child: Column(children: [
                            const Text('Islamic Quiz', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            Text(_difficulty.name.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, letterSpacing: 1.0)),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Question ${_index + 1} of ${_questions.length}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                        if (_timedMode)
                          Row(children: [
                            Icon(Icons.timer_outlined, size: 14, color: _secondsLeft <= 10 ? Colors.redAccent : Colors.white70),
                            const SizedBox(width: 4),
                            Text('${_secondsLeft}s', style: TextStyle(color: _secondsLeft <= 10 ? Colors.redAccent : Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                          ]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_index + 1) / _questions.length,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  if (_timedMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _secondsLeft / _timeLimit,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(_secondsLeft <= 10 ? Colors.redAccent : Colors.white54),
                          minHeight: 3,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16)],
                      ),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(q.category, style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 16),
                        Text(q.question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.6, color: isDark ? Colors.white : const Color(0xFF1A1A1A)), textAlign: TextAlign.center),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    ...q.options.asMap().entries.map((e) {
                      final i = e.key;
                      final opt = e.value;
                      final isCorrect = i == q.correctIndex;
                      final isSelected = i == _selectedAnswer;
                      final timeOut = _answered && _selectedAnswer == null;

                      Color bg, fg, border;
                      IconData? icon;

                      if (!_answered) {
                        bg = isDark ? AppTheme.darkCard : Colors.white;
                        fg = isDark ? Colors.white : const Color(0xFF1A1A1A);
                        border = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
                        icon = null;
                      } else if (isCorrect || (timeOut && isCorrect)) {
                        bg = AppTheme.primaryGreen; fg = Colors.white; border = AppTheme.primaryGreen; icon = Icons.check_circle_rounded;
                      } else if (isSelected) {
                        bg = Colors.redAccent; fg = Colors.white; border = Colors.redAccent; icon = Icons.cancel_rounded;
                      } else {
                        bg = isDark ? AppTheme.darkCard : Colors.white;
                        fg = isDark ? Colors.white38 : Colors.black38;
                        border = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
                        icon = null;
                      }

                      return GestureDetector(
                        onTap: () => _select(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                          child: Row(children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(color: fg.withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: Center(child: Text(String.fromCharCode(65 + i), style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(opt, style: TextStyle(color: fg, fontWeight: FontWeight.w500, fontSize: 14))),
                            if (icon != null) Icon(icon, color: fg, size: 20),
                          ]),
                        ),
                      );
                    }),

                    if (_answered) ...[
                      const SizedBox(height: 16),
                      if (_selectedAnswer == null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))),
                          child: const Row(children: [
                            Icon(Icons.timer_off_rounded, color: Colors.redAccent, size: 18),
                            SizedBox(width: 8),
                            Expanded(child: Text("Time's up! See the correct answer above.", style: TextStyle(color: Colors.redAccent, fontSize: 12))),
                          ]),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: isDark ? 0.12 : 0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2))),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.gold, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(q.explanation, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12, height: 1.5))),
                          ]),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: Text(_index < _questions.length - 1 ? 'Next Question →' : 'See Results', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Start Screen ──────────────────────────────────────────

class _StartScreen extends StatelessWidget {
  final bool isDark;
  final _Difficulty difficulty;
  final bool timedMode;
  final List<Map<String, dynamic>> history;
  final ValueChanged<_Difficulty> onDifficulty;
  final ValueChanged<bool> onTimedMode;
  final VoidCallback onStart;
  final VoidCallback onExit;

  const _StartScreen({required this.isDark, required this.difficulty, required this.timedMode, required this.history, required this.onDifficulty, required this.onTimedMode, required this.onStart, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(children: [
                  GestureDetector(onTap: onExit, child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close_rounded, color: Colors.white, size: 20))),
                  const Expanded(child: Column(children: [
                    Text('Islamic Quiz', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('اختبار إسلامي', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppTheme.arabicFontFamily)),
                  ])),
                  const SizedBox(width: 36),
                ]),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DIFFICULTY', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _DiffChip(label: 'Easy', color: AppTheme.primaryGreen, isSelected: difficulty == _Difficulty.easy, onTap: () => onDifficulty(_Difficulty.easy)),
                    const SizedBox(width: 8),
                    _DiffChip(label: 'Medium', color: AppTheme.quranBlue, isSelected: difficulty == _Difficulty.medium, onTap: () => onDifficulty(_Difficulty.medium)),
                    const SizedBox(width: 8),
                    _DiffChip(label: 'Hard', color: Colors.redAccent, isSelected: difficulty == _Difficulty.hard, onTap: () => onDifficulty(_Difficulty.hard)),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    difficulty == _Difficulty.easy ? 'Pillars, Prayer & Prophets · 45s per question' : difficulty == _Difficulty.medium ? 'All topics · 30s per question' : 'Arabic, Angels & History · 20s per question',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isDark ? AppTheme.darkCard : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04))),
                    child: Row(children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.timer_outlined, color: AppTheme.gold, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Timed Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                        Text('Countdown timer per question', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                      ])),
                      Switch(value: timedMode, onChanged: onTimedMode, activeColor: AppTheme.primaryGreen),
                    ]),
                  ),

                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('RECENT SCORES', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    ...history.map((h) {
                      final pct = (h['score'] as int) / (h['total'] as int);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: isDark ? AppTheme.darkCard : Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Text(pct >= 0.9 ? '🏆' : pct >= 0.7 ? '⭐' : pct >= 0.5 ? '👍' : '📚', style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${h['score']}/${h['total']} · ${(pct * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                            Text('${h['difficulty']} · ${h['date']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                          ])),
                          Container(
                            width: 48, height: 6,
                            decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(3)),
                            child: FractionallySizedBox(
                              widthFactor: pct, alignment: Alignment.centerLeft,
                              child: Container(decoration: BoxDecoration(color: pct >= 0.7 ? AppTheme.primaryGreen : pct >= 0.5 ? AppTheme.gold : Colors.redAccent, borderRadius: BorderRadius.circular(3))),
                            ),
                          ),
                        ]),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 4),
                      child: const Text('Start Quiz  →', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _DiffChip({required this.label, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}

// ── Result Screen ─────────────────────────────────────────

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final _Difficulty difficulty;
  final bool isDark;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _ResultScreen({required this.score, required this.total, required this.difficulty, required this.isDark, required this.onRestart, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    final emoji = pct >= 0.9 ? '🏆' : pct >= 0.7 ? '⭐' : pct >= 0.5 ? '👍' : '📚';
    final msg = pct >= 0.9 ? 'Excellent!' : pct >= 0.7 ? 'Very Good!' : pct >= 0.5 ? 'Good effort!' : 'Keep learning!';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  Text(msg, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(style: const TextStyle(fontSize: 18, color: Colors.white70), children: [
                      TextSpan(text: '$score', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 48)),
                      TextSpan(text: ' / $total', style: const TextStyle(color: Colors.white70, fontSize: 24)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Text('${(pct * 100).toInt()}% correct · ${difficulty.name}', style: const TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRestart,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: onExit, child: const Text('Exit', style: TextStyle(color: Colors.white60))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
