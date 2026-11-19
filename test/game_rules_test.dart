import 'package:flutter_test/flutter_test.dart';
import 'package:game_019_stack_tower/core/level_plan.dart';
import 'package:game_019_stack_tower/game/rules.dart';
import 'package:game_019_stack_tower/game/stack_engine.dart';

void main() {
  final rules = StackRules();
  final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: rules.optionalMechanics);

  test('overhang is cut off', () {
    final s = StackSim(rules.build(planner.spec(1)).puzzle);
    s.mx = s.top.x + 100;
    s.dir = 0;
    s.drop();
    expect(s.top.w, closeTo(s.tower[0].w - 100, 0.001));
    expect(s.debris.length, 1);
  });

  test('perfect drops keep the width and build a combo', () {
    final s = StackSim(rules.build(planner.spec(1)).puzzle);
    for (var i = 0; i < 3; i++) {
      s.mx = s.top.x + 3;
      s.drop();
    }
    expect(s.combo, 3);
    expect(s.perfects, 3);
    expect(s.top.w, greaterThanOrEqualTo(s.tower[0].w - 0.001));
  });

  test('a complete miss costs a life', () {
    final s = StackSim(rules.build(planner.spec(1)).puzzle);
    s.mx = s.top.x + s.top.w + 50;
    s.drop();
    expect(s.lives, 2);
    expect(s.height, 0);
  });
}
