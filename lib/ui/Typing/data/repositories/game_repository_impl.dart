import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../../../../core/typedefs.dart';
import '../../domain/repositories/game_repository.dart';
import '../data_sources/game_remote_data_source.dart';

class TypingGameRepositoryImpl implements TypingGameRepository {
  final TypingGameRemoteDataSource _remoteDataSource;

  TypingGameRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<void> updateUserPoint(
      String uid, int point, String topicId) async {
    try {
      return Right(
        await _remoteDataSource.updateUserPoint(
            uid,
            {
              'typing_point': FieldValue.increment(point),
            },
            topicId,
            point),
      );
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(e.message ?? 'FirebaseFailure: updateUserPoint'),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> updateUserGold(String uid, int gold) async {
    try {
      return Right(
        await _remoteDataSource.updateUserGold(uid, {
          'typing_gold': FieldValue.increment(gold),
        }),
      );
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(e.message ?? 'FirebaseFailure: updateUserGold'),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
