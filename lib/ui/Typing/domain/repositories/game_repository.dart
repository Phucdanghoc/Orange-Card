import '../../../../core/typedefs.dart';

abstract class TypingGameRepository {
  FutureEither<void> updateUserPoint(String uid, int point,String topicId);
  FutureEither<void> updateUserGold(String uid, int gold);
}
