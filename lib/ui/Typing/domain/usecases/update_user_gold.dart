import '../../../../core/typedefs.dart';
import '../../../../core/usecases.dart';
import '../repositories/game_repository.dart';

class TypingUpdateUserGoldUsecase extends Usecases<void, (String, int)> {
  final TypingGameRepository _repository;

  TypingUpdateUserGoldUsecase(this._repository);

  @override
  FutureEither<void> call((String, int) params) async {
    return await _repository.updateUserGold(params.$1, params.$2);
  }
}
