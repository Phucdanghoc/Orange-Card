import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/usecases/update_user_gold.dart';
import '../domain/usecases/update_user_point.dart';

part 'game_typing_state.dart';

class GameTypingCubit extends Cubit<GameTypingState> {
  final TypingUpdateUserPointUsecase updateUserPointUsecase;
  final TypingUpdateUserGoldUsecase updateUserGoldUsecase;

  GameTypingCubit(
    this.updateUserPointUsecase,
    this.updateUserGoldUsecase,
  ) : super(const GameTypingState(status: GameTypingStatus.initial));

  Future<void> calculateResult({
    required String uid,
    required int point,
    required int gold,
    required String topicId,

  }) async {
    emit(state.copyWith(status: GameTypingStatus.loading));

    final resultPoint = await updateUserPointUsecase((uid, point,topicId));
    await resultPoint.fold(
      (failure) async => emit(state.copyWith(
        status: GameTypingStatus.error,
        message: failure.message,
      )),
      (_) async {
        if (gold > 0) {
          final resultGold = await updateUserGoldUsecase((uid, gold));
          resultGold.fold(
            (failure) => emit(state.copyWith(
              status: GameTypingStatus.error,
              message: failure.message,
            )),
            (_) => emit(state.copyWith(status: GameTypingStatus.success)),
          );
        } else {
          emit(state.copyWith(status: GameTypingStatus.success));
        }
      },
    );
  }
}
