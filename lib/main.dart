import 'dart:async';
import 'package:flutter/material.dart';
import 'game/stack_tower_game.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: StackTowerScreen()));

class StackTowerScreen extends StatefulWidget {
  const StackTowerScreen({super.key});
  @override
  State<StackTowerScreen> createState() => _StackTowerScreenState();
}

class _StackTowerScreenState extends State<StackTowerScreen> {
  final game = StackTowerGame();
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted && !game.over) setState(() => game.tick(0.016));
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stack Tower'), actions: [
      IconButton(tooltip: 'Restart', icon: const Icon(Icons.refresh),
        onPressed: () => setState(game.reset))
    ]),
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(
        game.over ? 'Game over · Score: ${game.score}' : 'Stack height: ${game.score}',
        style: Theme.of(context).textTheme.headlineSmall)),
      Expanded(child: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final blockHeight = (h / 13).clamp(20.0, 52.0);
        final visible = game.widths.length < 10 ? game.widths.length : 10;
        return Stack(children: [
          for (var i = 0; i < visible; i++)
            Positioned(
              left: (game.centers[game.centers.length - visible + i] -
                  game.widths[game.widths.length - visible + i] / 2) * w,
              bottom: i * blockHeight,
              width: game.widths[game.widths.length - visible + i] * w,
              height: blockHeight - 2,
              child: ColoredBox(color: Colors.primaries[(game.score + i) % Colors.primaries.length])),
          if (!game.over)
            Positioned(left: (game.movingCenter - game.widths.last / 2) * w,
              bottom: visible * blockHeight,
              width: game.widths.last * w, height: blockHeight - 2,
              child: const ColoredBox(color: Colors.amber)),
        ]);
      })),
      Padding(padding: const EdgeInsets.all(24),
        child: FilledButton(
          onPressed: game.over ? () => setState(game.reset) : () => setState(game.drop),
          child: Text(game.over ? 'Play again' : 'Drop block'))),
      const Text('No ads required to play'),
      const SizedBox(height: 12),
    ])),
  );
}
