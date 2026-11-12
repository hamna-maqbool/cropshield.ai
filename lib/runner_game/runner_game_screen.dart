// Field Runner screen. Game rules live in FieldRunnerGame.
// This file hosts the game view and the ready / pause / game over screens.

import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'field_runner_game.dart';
import 'models/runner_enums.dart';

class RunnerGameScreen extends StatefulWidget {
  const RunnerGameScreen({super.key});

  @override
  State<RunnerGameScreen> createState() => _RunnerGameScreenState();
}

class _RunnerGameScreenState extends State<RunnerGameScreen> {
  late final FieldRunnerGame _game;

  int _lastScore = 0;
  bool _lastWasNewBest = false;

  @override
  void initState() {
    super.initState();
    _game = FieldRunnerGame(
      onGameOver: (score, isNewBest) {
        if (!mounted) return;
        setState(() {
          _lastScore = score;
          _lastWasNewBest = isNewBest;
        });
      },
    );
  }

  void _handleSwipe(DragEndDetails details) {
    final v = details.velocity.pixelsPerSecond;
    // Prefer the stronger axis so a slight diagonal swipe still works.
    if (v.dx.abs() > v.dy.abs()) {
      if (v.dx > 250) {
        _game.moveLane(1);
      } else if (v.dx < -250) {
        _game.moveLane(-1);
      }
    } else {
      if (v.dy < -250) {
        _game.jump();
      } else if (v.dy > 250) {
        _game.duck();
      }
    }
  }

  void _startGame() {
    _game.startGame();
    setState(() {});
  }

  void _togglePause() {
    _game.togglePause();
    setState(() {});
  }

  bool get _isMenu =>
      _game.state == RunnerGameState.ready ||
      _game.state == RunnerGameState.paused ||
      _game.state == RunnerGameState.gameOver;

  @override
  Widget build(BuildContext context) {
    // GameWidget must stay mounted so Flame can load player / hud.
    // Ready screen just covers it with a light overlay.
    return Scaffold(
      backgroundColor: _isMenu ? Colors.white : AppColors.forest,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onPanEnd: _handleSwipe,
              child: GameWidget(game: _game),
            ),
            _buildTopBar(),
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    switch (_game.state) {
      case RunnerGameState.ready:
        return _ReadyOverlay(game: _game, onStart: _startGame);
      case RunnerGameState.paused:
        return _PausedOverlay(onResume: _togglePause);
      case RunnerGameState.gameOver:
        return _GameOverOverlay(
          game: _game,
          score: _lastScore,
          isNewBest: _lastWasNewBest,
          onRunAgain: _startGame,
        );
      case RunnerGameState.playing:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 4,
      left: 4,
      child: IconButton(
        onPressed: () {
          if (_game.state == RunnerGameState.playing ||
              _game.state == RunnerGameState.paused) {
            _togglePause();
          } else {
            Navigator.of(context).pop();
          }
        },
        icon: Icon(
          _game.state == RunnerGameState.playing
              ? CupertinoIcons.pause_circle_fill
              : CupertinoIcons.back,
          color: _isMenu ? AppColors.textPrimary : Colors.white,
        ),
      ),
    );
  }
}

ButtonStyle get _pillMoss => FilledButton.styleFrom(
      backgroundColor: AppColors.moss,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );

class _ReadyOverlay extends StatelessWidget {
  const _ReadyOverlay({required this.game, required this.onStart});
  final FieldRunnerGame game;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.person_crop_circle,
                size: 56,
                color: AppColors.moss,
              ),
              const SizedBox(height: 14),
              Text(
                'Field Runner',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Swipe left or right to switch rows\n'
                'Swipe up to jump, swipe down to duck\n'
                'Collect shields and growth boosts',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                'Best score: ${game.best}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.moss,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(CupertinoIcons.play_fill, size: 18),
                label: const Text('Start Running'),
                style: _pillMoss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({required this.onResume});
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.96),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.pause_circle,
              color: AppColors.moss,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Paused',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(CupertinoIcons.play_fill, size: 18),
              label: const Text('Resume'),
              style: _pillMoss,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.game,
    required this.score,
    required this.isNewBest,
    required this.onRunAgain,
  });

  final FieldRunnerGame game;
  final int score;
  final bool isNewBest;
  final VoidCallback onRunAgain;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.96),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNewBest
                    ? CupertinoIcons.rosette
                    : CupertinoIcons.flag,
                size: 48,
                color: AppColors.moss,
              ),
              const SizedBox(height: 12),
              Text(
                isNewBest ? 'New Best Score!' : 'Game Over',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Best: ${game.best}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onRunAgain,
                icon: const Icon(CupertinoIcons.refresh, size: 18),
                label: const Text('Run Again'),
                style: _pillMoss,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(CupertinoIcons.home, size: 18),
                label: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.moss,
                  side: const BorderSide(color: AppColors.moss),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
