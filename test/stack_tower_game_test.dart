import 'package:flutter_test/flutter_test.dart';
import 'package:game_019_stack_tower/game/stack_tower_game.dart';

void main() {
  test('initial state has full base', () {
    final game = StackTowerGame();
    expect(game.score, 0);
    expect(game.widths.single, 1);
    expect(game.over, false);
  });
  test('aligned drop increases height', () {
    final game = StackTowerGame()..movingCenter = 0.5;
    expect(game.drop(), true);
    expect(game.score, 1);
    expect(game.widths.last, 1);
  });
  test('partial overlap trims width', () {
    final game = StackTowerGame()..movingCenter = 0.7;
    expect(game.drop(), true);
    expect(game.widths.last, closeTo(0.8, 0.00001));
  });
  test('miss ends run without score', () {
    final game = StackTowerGame()..movingCenter = 1.6;
    expect(game.drop(), false);
    expect(game.over, true);
    expect(game.score, 0);
  });
  test('reset clears game over and score', () {
    final game = StackTowerGame()..movingCenter = 1.6;
    game.drop();
    game.reset();
    expect(game.over, false);
    expect(game.score, 0);
  });
  test('invalid tick does not alter position', () {
    final game = StackTowerGame();
    game.tick(-1);
    expect(game.movingCenter, 0.2);
  });
}
