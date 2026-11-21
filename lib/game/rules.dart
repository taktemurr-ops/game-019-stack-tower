import 'package:studio_core/core/arcade.dart';
import 'package:studio_core/core/level_plan.dart';
import 'package:studio_core/core/missions.dart';
import 'package:studio_core/core/stats.dart';
import 'stack_engine.dart';

class StackRules extends ArcadeRules<StackLevel> {
  @override
  String get gameId => 'game-019-stack-tower';

  @override
  List<String> get optionalMechanics => const ['shrink', 'wind', 'fast', 'zigzag'];

  @override
  List<GameStat> get gameStats => const [
        GameStat('blocks_placed', 'Konan blok', 'Blocks placed', scale: 100),
        GameStat('perfects', 'Tam isabet', 'Perfect drops', scale: 30),
        GameStat('best_combo', 'En iyi kombo', 'Best combo', scale: 5),
      ];

  @override
  List<MissionTemplate> get missionTemplates => const [
        MissionTemplate('blocks_placed', 'blocks_placed', [33, 66, 100]),
        MissionTemplate('perfects', 'perfects', [10, 20, 30]),
      ];

  @override
  StackLevel generate(LevelSpec spec) => generateStackLevel(spec);

  @override
  ArcadeMeta metaOf(StackLevel l) => l.meta;

  @override
  ArcadeSim createSim(StackLevel l) => StackSim(l);

  @override
  ArcadeInput bot(ArcadeSim sim) => stackBot(sim);
}

ArcadeRules createRules() => StackRules();
