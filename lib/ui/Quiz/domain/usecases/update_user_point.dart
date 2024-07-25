import '../../../../core/typedefs.dart';
import '../../../../core/usecases.dart';
import '../repositories/game_repository.dart';

class UpdateUserPointUsecase extends Usecases<void, (String, int, String)> {
  final GameRepository repository;

  UpdateUserPointUsecase(this.repository);

  @override
  FutureEither<void> call((String, int, String) params) async {
    return await repository.updateUserPoint(params.$1, params.$2, params.$3);
  }
}
