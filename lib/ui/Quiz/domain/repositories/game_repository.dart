import '../../../../core/typedefs.dart';

abstract class GameRepository {
  FutureEither<void> updateUserPoint(String uid, int point, String topicId);
  FutureEither<void> updateUserGold(String uid, int gold);
}
