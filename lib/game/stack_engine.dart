import 'dart:math' as math;

import '../core/arcade.dart';
import '../core/level_plan.dart';

class StackLevel {
  final ArcadeMeta meta;
  final int target; // floors, 0 = endless
  final double speed;
  final double startWidth;
  final bool shrink;
  final bool wind;
  final bool zigzag;

  const StackLevel({
    required this.meta,
    required this.target,
    required this.speed,
    required this.startWidth,
    required this.shrink,
    required this.wind,
    required this.zigzag,
  });
}

StackLevel generateStackLevel(LevelSpec spec) {
  final m = ArcadeMeta.of(spec);
  final d = spec.difficulty;
  return StackLevel(
    meta: m,
    target: m.goal ? 15 + d * 4 : 0,
    speed: 5.0 + d * 0.5 + (spec.has('fast') ? 2 : 0),
    startWidth: (560 - d * 18).toDouble(),
    shrink: spec.has('shrink'),
    wind: spec.has('wind'),
    zigzag: spec.has('zigzag'),
  );
}

const double kBlockH = 70;
const double kPerfect = 7;

class Block {
  final double x, w;
  final int hue;
  const Block(this.x, this.w, this.hue);
}

class Falling {
  double x, y, w, vy;
  final int hue;
  Falling(this.x, this.y, this.w, this.vy, this.hue);
}

class StackSim extends ArcadeSim {
  final StackLevel level;
  final List<Block> tower = [];
  double mx = 0; // moving block left
  double mw = 0;
  int dir = 1;
  int combo = 0, bestCombo = 0, perfects = 0, placed = 0;
  final List<Falling> debris = [];
  int lastEvent = 0; // 1 place, 2 perfect, 3 miss

  StackSim(this.level) : super(level.meta) {
    tower.add(Block((kWorldW - level.startWidth) / 2, level.startWidth, 0));
    _spawn();
  }

  Block get top => tower.last;
  int get height => tower.length - 1;

  double get speed {
    var s = level.speed + height * 0.04;
    if (level.wind) s *= 1 + 0.35 * math.sin(ticks / 40);
    return s;
  }

  void _spawn() {
    mw = top.w;
    if (level.zigzag) {
      dir = height.isEven ? 1 : -1;
    } else {
      dir = rng.chance(0.5) ? 1 : -1;
    }
    mx = dir > 0 ? -mw * 0.3 : kWorldW - mw * 0.7;
  }

  void drop() {
    final t = top;
    final left = math.max(mx, t.x), right = math.min(mx + mw, t.x + t.w);
    final overlap = right - left;
    if (overlap <= 0) {
      debris.add(Falling(mx, 0, mw, 0, height + 1));
      combo = 0;
      lastEvent = 3;
      hit();
      if (!over) _spawn();
      return;
    }
    double nx, nw;
    if ((mx - t.x).abs() <= kPerfect) {
      nx = t.x;
      nw = t.w;
      combo++;
      perfects++;
      bestCombo = math.max(bestCombo, combo);
      if (combo >= 3) {
        nw = math.min(nw + 20, level.startWidth);
        nx = clampD(nx - 10, 0, kWorldW - nw);
      }
      score += 2 + combo;
      lastEvent = 2;
    } else {
      nx = left;
      nw = overlap;
      // The cut part falls.
      if (mx < t.x) {
        debris.add(Falling(mx, 0, t.x - mx, 0, height + 1));
      } else {
        debris.add(Falling(t.x + t.w, 0, mx + mw - (t.x + t.w), 0, height + 1));
      }
      combo = 0;
      score += 1;
      lastEvent = 1;
    }
    if (level.shrink) nw = math.max(30, nw * 0.985);
    tower.add(Block(nx, nw, height + 1));
    placed++;
    if (level.target > 0 && height >= level.target) {
      win();
      return;
    }
    _spawn();
  }

  @override
  void update(ArcadeInput input) {
    lastEvent = 0;
    for (final f in [...debris]) {
      f.vy += 0.8;
      f.y += f.vy;
      if (f.y > 1600) debris.remove(f);
    }
    mx += dir * speed;
    if (mx > kWorldW - mw * 0.3) dir = -1;
    if (mx < -mw * 0.7) dir = 1;
    if (input.tap || input.swipe == 2 || input.swipe == 0) drop();
  }

  @override
  void onLifeLost() {
    // Rescue: a too thin tower gets a wider slab.
    if (top.w < 60) tower.add(Block((kWorldW - 260) / 2, 260, height + 1));
  }

  @override
  bool useBooster() {
    // Widen the next block to the full start width.
    if (over) return false;
    mw = level.startWidth;
    tower.add(Block(clampD(top.x + top.w / 2 - mw / 2, 0, kWorldW - mw), mw, height + 1));
    placed++;
    if (level.target > 0 && height >= level.target) win();
    return true;
  }

  @override
  double get progress => level.target == 0 ? 0 : height / level.target;

  @override
  String get goalText => level.target == 0 ? '$height' : '$height/${level.target}';

  @override
  Map<String, int> get stats => {'blocks_placed': placed, 'perfects': perfects, 'best_combo': bestCombo};

  @override
  int get stars => lifeStars(this, 3);
}

ArcadeInput stackBot(ArcadeSim sim) {
  final s = sim as StackSim;
  // Predict the position on the next tick (input applies after the move).
  var nx = s.mx + s.dir * s.speed;
  if (nx > kWorldW - s.mw * 0.3 || nx < -s.mw * 0.7) nx = s.mx - s.dir * s.speed;
  final err = (nx - s.top.x).abs();
  final nextErr = (nx + s.dir * s.speed - s.top.x).abs();
  if (err <= kPerfect || (err < s.top.w * 0.5 && nextErr > err && err < s.speed)) {
    return const ArcadeInput(tap: true, down: true, x: 500, y: 800);
  }
  return ArcadeInput.idle;
}
