// runner_game_screen.dart
//
// "Field Runner" — Flame-powered 3-lane endless runner. The farmer
// auto-runs down crop rows; swipe left/right to switch lanes, swipe up
// to jump ground pests, swipe down to duck flying pests. Collect leaves
// for score, grab power-ups (shield / growth boost) for an edge.
//
// This file is intentionally "dumb" — all game state and rules live in
// FieldRunnerGame. This widget just hosts the GameWidget, translates
// swipes into calls on the game, and renders the three overlay screens
// (ready / paused / game over) as ordinary Flutter widgets driven by
// plain setState — no extra state-management machinery needed.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
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
    // Pick whichever axis had the stronger flick so a slightly-diagonal
    // swipe still reads as a clean directional input.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forest,
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
      top: 8,
      left: 8,
      child: SafeArea(
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
                ? Icons.pause_circle_filled_rounded
                : Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ReadyOverlay extends StatelessWidget {
  const _ReadyOverlay({required this.game, required this.onStart});
  final FieldRunnerGame game;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_run_rounded,
                size: 56,
                color: AppColors.leaf,
              ),
              const SizedBox(height: 12),
              const Text(
                'Field Runner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Swipe left/right to switch rows\n'
                'Swipe up to jump 🐛  •  Swipe down to duck 🦅\n'
                'Grab \u{1F6E1}\u{FE0F} shield and \u{1F9EA} growth boost power-ups',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Best score: ${game.best}',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Running'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.leaf,
                  foregroundColor: AppColors.forest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
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

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({required this.onResume});
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_filled_rounded,
                color: Colors.white, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.leaf,
                foregroundColor: AppColors.forest,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
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
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNewBest ? Icons.emoji_events_rounded : Icons.bug_report_rounded,
                size: 48,
                color: isNewBest ? AppColors.straw : AppColors.leaf,
              ),
              const SizedBox(height: 10),
              Text(
                isNewBest ? 'New Best Score!' : 'Game Over',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Best: ${game.best}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRunAgain,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Run Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.leaf,
                  foregroundColor: AppColors.forest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
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
