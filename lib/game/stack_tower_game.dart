import 'dart:math';

class StackTowerGame {
  static const double width = 1.0;
  final List<double> widths = [width];
  final List<double> centers = [0.5];
  double movingCenter = 0.2;
  double direction = 1;
  double speed = 0.35;
  int score = 0;
  bool over = false;

  void reset() {
    widths..clear()..add(width);
    centers..clear()..add(0.5);
    movingCenter = 0.2;
    direction = 1;
    speed = 0.35;
    score = 0;
    over = false;
  }

  void tick(double seconds) {
    if (over || !seconds.isFinite || seconds <= 0) return;
    final next = movingCenter + direction * speed * min(seconds, 0.05);
    if (next >= 1) { movingCenter = 1; direction = -1; }
    else if (next <= 0) { movingCenter = 0; direction = 1; }
    else { movingCenter = next; }
  }

  bool drop() {
    if (over) return false;
    final previousWidth = widths.last;
    final previousCenter = centers.last;
    final left = max(previousCenter - previousWidth / 2, movingCenter - previousWidth / 2);
    final right = min(previousCenter + previousWidth / 2, movingCenter + previousWidth / 2);
    final overlap = right - left;
    if (overlap <= 0.0001) { over = true; return false; }
    widths.add(overlap);
    centers.add((left + right) / 2);
    movingCenter = score.isEven ? 0.1 : 0.9;
    direction = score.isEven ? 1 : -1;
    score++;
    speed = min(0.85, 0.35 + score * 0.018);
    return true;
  }
}
