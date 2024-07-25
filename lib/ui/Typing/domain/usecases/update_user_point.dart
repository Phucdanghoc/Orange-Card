import '../../../../core/typedefs.dart';
import '../../../../core/usecases.dart';
import '../repositories/game_repository.dart';

class TypingUpdateUserPointUsecase extends Usecases<void, (String, int, String)> {
  final TypingGameRepository repository;

  TypingUpdateUserPointUsecase(this.repository);

  @override
  FutureEither<void> call((String, int, String) params) async {
    return await repository.updateUserPoint(params.$1, params.$2, params.$3);
  }
}
