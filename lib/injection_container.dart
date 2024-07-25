import 'package:cloud_firestore/cloud_firestore.dart';
import "package:connectivity_plus/connectivity_plus.dart";
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:get_it/get_it.dart";
import 'package:orange_card/ui/Quiz/cubits/game_quiz_cubit.dart';
import 'package:orange_card/ui/Quiz/data/data_sources/game_remote_data_source.dart';
import 'package:orange_card/ui/Quiz/data/repositories/game_repository_impl.dart';
import 'package:orange_card/ui/Quiz/domain/repositories/game_repository.dart';
import 'package:orange_card/ui/Quiz/domain/usecases/update_user_gold.dart';
import 'package:orange_card/ui/Quiz/domain/usecases/update_user_point.dart';
import 'package:orange_card/ui/Typing/cubits/game_typing_cubit.dart';
import 'package:orange_card/ui/Typing/data/data_sources/game_remote_data_source.dart';
import 'package:orange_card/ui/Typing/data/repositories/game_repository_impl.dart';
import 'package:orange_card/ui/Typing/domain/repositories/game_repository.dart';
import 'package:orange_card/ui/Typing/domain/usecases/update_user_gold.dart';
import 'package:orange_card/ui/Typing/domain/usecases/update_user_point.dart';
import "package:shared_preferences/shared_preferences.dart";

final sl = GetIt.instance;

Future<void> setUpServiceLocator() async {
  //! External
  sl.registerLazySingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  await sl.isReady<SharedPreferences>();
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  //! Feature - game Quiz
  // Data source
  sl.registerLazySingleton<GameRemoteDataSource>(
    () => GameRemoteDataSourceImpl(sl()),
  );
  // Repository
  sl.registerLazySingleton<GameRepository>(() => GameRepositoryImpl(sl()));
  // Usecase
  sl.registerLazySingleton(() => UpdateUserPointUsecase(sl()));
  sl.registerLazySingleton(() => UpdateUserGoldUsecase(sl()));
  // Cubit
  sl.registerFactory(() => GameQuizCubit(sl(), sl()));

  //! Feature - game Typing
  // Data source
  sl.registerLazySingleton<TypingGameRemoteDataSource>(
    () => TypingGameRemoteDataSourceImpl(sl()),
  );
  // Repository
  sl.registerLazySingleton<TypingGameRepository>(() => TypingGameRepositoryImpl(sl()));
  // Usecase
  sl.registerLazySingleton(() => TypingUpdateUserPointUsecase(sl()));
  sl.registerLazySingleton(() => TypingUpdateUserGoldUsecase(sl()));
  // Cubit
  sl.registerFactory(() => GameTypingCubit(sl(), sl()));
}
