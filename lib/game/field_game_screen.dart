// field_game_screen.dart
//
// "My Field" — an 8-week season simulation game for farmers.
// Farmer picks a crop, then makes weekly decisions (spray / ignore)
// when disease events hit, using REAL leaf photos from the dataset.
// At the end, they see their yield %, profit, and a badge.
//
// Farmer-friendly design: big buttons, icons, minimal typing (none
// required at all), short simple sentences, Urdu word alongside key
// actions (matching the style already used in your Tools section).

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'game_data.dart';
import 'game_service.dart';

enum _GameStage { setup, playing, finished }

class FieldGameScreen extends StatefulWidget {
  const FieldGameScreen({super.key});

  @override
  State<FieldGameScreen> createState() => _FieldGameScreenState();
}

class _FieldGameScreenState extends State<FieldGameScreen> {
  static const int totalWeeks = 8;
  static const int startingBudget = 50000;
  static const int sprayCost = 3000;

  final GameService _service = GameService();
  final Random _random = Random();

  _GameStage _stage = _GameStage.setup;
  String _crop = 'Cotton';

  int _week = 1;
  int _health = 100;
  int _budget = startingBudget;
  int _healthSum = 0; // used to compute average health -> yield
  GameEvent? _currentEvent;
  bool _awaitingDecision = false;
  String? _lastOutcomeMessage;

  GameResult? _result;

  // ---------------- Game logic ----------------

  void _startGame() {
    setState(() {
      _stage = _GameStage.playing;
      _week = 1;
      _health = 100;
      _budget = startingBudget;
      _healthSum = 0;
      _lastOutcomeMessage = null;
    });
    _generateWeekEvent();
  }

  void _generateWeekEvent() {
    final roll = _random.nextDouble();
    GameEvent event;

    if (roll < 0.45) {
      // Disease event
      final diseaseMap = GameData.diseaseImagesFor(_crop);
      final diseaseNames = diseaseMap.keys.toList();
      final chosenDisease = diseaseNames[_random.nextInt(diseaseNames.length)];
      final images = diseaseMap[chosenDisease]!;
      final chosenImage = images[_random.nextInt(images.length)];
      event = GameEvent(
        type: GameEventType.disease,
        diseaseName: chosenDisease,
        imagePath: chosenImage,
        title: 'Week $_week: Disease spotted!',
        description:
            'Your field shows signs of $chosenDisease. What do you do?',
      );
    } else if (roll < 0.65) {
      event = GameEvent(
        type: GameEventType.weatherGood,
        title: 'Week $_week: Good rain',
        description: 'Timely rainfall helped your crop this week.',
      );
    } else if (roll < 0.80) {
      event = GameEvent(
        type: GameEventType.weatherBad,
        title: 'Week $_week: Dry spell',
        description: 'Low rainfall stressed your field this week.',
      );
    } else {
      event = GameEvent(
        type: GameEventType.calm,
        title: 'Week $_week: All quiet',
        description: 'Nothing unusual happened this week. Field looks fine.',
      );
    }

    setState(() {
      _currentEvent = event;
      _awaitingDecision = event.type == GameEventType.disease;
      _lastOutcomeMessage = null;
    });

    // auto-apply non-decision events immediately
    if (event.type == GameEventType.weatherGood) {
      _applyHealthChange(6);
    } else if (event.type == GameEventType.weatherBad) {
      _applyHealthChange(-10);
    } else if (event.type == GameEventType.calm) {
      _applyHealthChange(2);
    }
  }

  void _applyHealthChange(int delta) {
    setState(() {
      _health = (_health + delta).clamp(0, 100);
    });
  }

  void _onSpray() {
    setState(() {
      _budget -= sprayCost;
      _health = (_health + 15).clamp(0, 100);
      _awaitingDecision = false;
      _lastOutcomeMessage =
          'You sprayed the field. Health improved, but it cost Rs. $sprayCost.';
    });
  }

  void _onIgnore() {
    final damage = 12 + _random.nextInt(14); // 12-25 damage
    setState(() {
      _health = (_health - damage).clamp(0, 100);
      _awaitingDecision = false;
      _lastOutcomeMessage =
          'You ignored it. The disease spread — health dropped by $damage.';
    });
  }

  void _nextWeek() {
    _healthSum += _health;
    if (_week >= totalWeeks) {
      _finishGame();
      return;
    }
    setState(() => _week += 1);
    _generateWeekEvent();
  }

  Future<void> _finishGame() async {
    final avgHealth = (_healthSum / totalWeeks).round();
    final yieldPercent = avgHealth.clamp(0, 100);
    final profit =
        ((yieldPercent / 100) * 80000).round() - (startingBudget - _budget);

    String badge;
    if (yieldPercent >= 80) {
      badge = 'Master Farmer';
    } else if (yieldPercent >= 55) {
      badge = 'Getting There';
    } else {
      badge = 'Try Again Next Season';
    }

    final result = GameResult(
      crop: _crop,
      finalHealth: _health,
      finalBudget: _budget + profit,
      yieldPercent: yieldPercent,
      badge: badge,
    );

    await _service.saveResult(result);

    setState(() {
      _result = result;
      _stage = _GameStage.finished;
    });
  }

  void _playAgain() {
    setState(() {
      _stage = _GameStage.setup;
      _result = null;
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Field'),
      ),
      body: SafeArea(
        child: switch (_stage) {
          _GameStage.setup => _buildSetup(),
          _GameStage.playing => _buildPlaying(),
          _GameStage.finished => _buildFinished(),
        },
      ),
    );
  }

  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.agriculture_rounded,
              size: 72, color: AppColors.forest),
          const SizedBox(height: 16),
          Text(
            'Grow a Virtual Field',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage 8 weeks of your crop. Spray or wait when disease '
            'hits — see your final harvest!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text('Choose your crop / اپنی فصل منتخب کریں',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _cropOption('Cotton', Icons.grass_rounded),
              const SizedBox(width: 16),
              _cropOption('Rice', Icons.eco_rounded),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Season'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cropOption(String crop, IconData icon) {
    final selected = _crop == crop;
    return InkWell(
      onTap: () => setState(() => _crop = crop),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.forest.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.parchment,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32,
                color: selected ? AppColors.forest : AppColors.stone),
            const SizedBox(height: 8),
            Text(
              crop,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? AppColors.forest : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaying() {
    final event = _currentEvent;
    if (event == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusBar(),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(event.description,
                      style: Theme.of(context).textTheme.bodyMedium),
                  if (event.imagePath != null) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.asset(
                          event.imagePath!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  if (_lastOutcomeMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.parchment.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _lastOutcomeMessage!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_awaitingDecision) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _onSpray,
                    icon: const Icon(Icons.science_rounded),
                    label: const Text('Spray\n(سپرے کریں)',
                        textAlign: TextAlign.center),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.moss,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _onIgnore,
                    icon: const Icon(Icons.visibility_off_rounded),
                    label: const Text('Ignore\n(نظر انداز کریں)',
                        textAlign: TextAlign.center),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.clay),
                      foregroundColor: AppColors.clay,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _nextWeek,
                icon: Icon(_week >= totalWeeks
                    ? Icons.flag_rounded
                    : Icons.arrow_forward_rounded),
                label: Text(
                    _week >= totalWeeks ? 'See Results' : 'Next Week'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBar() {
    return Row(
      children: [
        Expanded(child: _statChip('Week', '$_week / $totalWeeks',
            Icons.calendar_today_rounded)),
        const SizedBox(width: 10),
        Expanded(
            child: _statChip('Health', '$_health%',
                Icons.favorite_rounded)),
        const SizedBox(width: 10),
        Expanded(
            child: _statChip(
                'Budget', 'Rs. $_budget', Icons.account_balance_wallet_rounded)),
      ],
    );
  }

  Widget _statChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.parchment),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.moss),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildFinished() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    final profitPositive = result.finalBudget >= startingBudget;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            result.yieldPercent >= 80
                ? Icons.emoji_events_rounded
                : Icons.agriculture_rounded,
            size: 72,
            color: AppColors.forest,
          ),
          const SizedBox(height: 12),
          Text(
            result.badge,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Season complete for ${result.crop}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                  child: _resultStat('Yield', '${result.yieldPercent}%')),
              const SizedBox(width: 12),
              Expanded(
                  child: _resultStat(
                      'Final Budget', 'Rs. ${result.finalBudget}')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profitPositive
                ? 'You made a profit this season!'
                : 'You lost money this season — try spraying earlier next time.',
            style: TextStyle(
              color: profitPositive ? AppColors.forest : AppColors.clay,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _playAgain,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Play Again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.parchment.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
