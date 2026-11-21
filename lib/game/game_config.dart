import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:studio_core/app/arcade_stage.dart';
import 'package:studio_core/app/game_api.dart';
import 'package:studio_core/app/play_kit.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/arcade.dart';
import 'package:studio_core/core/game_rules.dart';
import 'stack_engine.dart';
import 'rules.dart';

void paintStack(Canvas c, ArcadeSim sim, ArcadePalette p, double t) {
  final s = sim as StackSim;
  // Camera: keep the moving block around y=520.
  final visible = 13;
  final base = math.max(0, s.height - visible + 4);
  double yOf(int level) => 1450 - (level - base) * kBlockH;
  Color col(int hue) => HSVColor.fromAHSV(1, (hue * 13.0 + 200) % 360, 0.55, 0.9).toColor();
  for (var i = base; i < s.tower.length; i++) {
    final b = s.tower[i];
    final r = Rect.fromLTWH(b.x, yOf(i) - kBlockH, b.w, kBlockH - 2);
    c.drawRect(r, Paint()..color = col(b.hue));
    c.drawRect(Rect.fromLTWH(b.x, r.top, b.w, 10), Paint()..color = Colors.white24);
  }
  if (!s.over) {
    final y = yOf(s.tower.length) - kBlockH;
    c.drawRect(Rect.fromLTWH(s.mx, y, s.mw, kBlockH - 2), Paint()..color = col(s.height + 1));
    // guide line of the top block edges
    final g = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3;
    c.drawLine(Offset(s.top.x, y - 20), Offset(s.top.x, y + kBlockH), g);
    c.drawLine(Offset(s.top.x + s.top.w, y - 20), Offset(s.top.x + s.top.w, y + kBlockH), g);
  }
  for (final f in s.debris) {
    final y = yOf(f.hue) - kBlockH + f.y;
    c.drawRect(Rect.fromLTWH(f.x, y, f.w, kBlockH - 2), Paint()..color = col(f.hue).withValues(alpha: 0.7));
  }
  paintText(c, '${s.height}', const Offset(kWorldW / 2, 200), 110, Colors.white70);
  if (s.combo >= 2) paintText(c, 'PERFECT x${s.combo}', const Offset(kWorldW / 2, 300), 48, const Color(0xFFFFD60A));
}

Sfx? stackSound(ArcadeSim sim) => switch ((sim as StackSim).lastEvent) {
      1 => Sfx.place,
      2 => Sfx.combo,
      3 => Sfx.error,
      _ => null,
    };

final gameConfig = GameConfig(
  gameId: 'game-019-stack-tower',
  title: const ['Kule Yığma', 'Stack Tower', 'Stapelturm', 'Torre Apilada', 'Tour Empilée'],
  tagline: const ['Doğru anda dokun, kuleyi yükselt!', 'Tap at the right time, build higher!', 'Im richtigen Moment tippen!', '¡Toca en el momento justo!', 'Touchez au bon moment !'],
  seedColor: const Color(0xFFF2E9E4),
  icon: Icons.layers,
  rules: StackRules(),
  buildPlay: (ctx) => ArcadeStage(
    ctx: ctx,
    create: () => StackSim((ctx.generated as GeneratedLevel<StackLevel>).puzzle),
    paint: paintStack,
    sound: stackSound,
    boosterIcon: Icons.open_in_full,
    boosterLabel: (l) => l == 'tr' ? 'Geniş blok' : 'Wide block',
    howTo: const [
      'Kayan blok alttakinin tam üstüne gelince dokun!',
      'Tap when the sliding block is right above the tower!',
      'Tippe, wenn der Block genau darüber ist!',
      '¡Toca cuando el bloque esté justo encima!',
      'Touchez quand le bloc est juste au-dessus !',
    ],
  ),
  tutorial: const [
    TutorialStep(Icons.touch_app, [
      'Dokun ya da boşluk: bloğu bırak. Taşan kısım kesilir.',
      'Tap or space: drop. The overhang is cut off.',
      'Tippen oder Leertaste: fallen lassen.',
      'Toca o espacio: soltar.',
      'Toucher ou espace : lâcher.',
    ]),
    TutorialStep(Icons.auto_awesome, [
      'Üst üste 3 tam isabet blok genişletir.',
      'Three perfect drops in a row widen the block.',
      'Drei perfekte Würfe verbreitern den Block.',
      'Tres perfectos seguidos ensanchan el bloque.',
      'Trois parfaits élargissent le bloc.',
    ]),
  ],
);
