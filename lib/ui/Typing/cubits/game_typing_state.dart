// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'game_typing_cubit.dart';

enum GameTypingStatus { initial, loading, success, error }

class GameTypingState extends Equatable {
  final GameTypingStatus status;
  final String? message;

  const GameTypingState({required this.status, this.message});

  @override
  List<Object?> get props => [status, message];

  GameTypingState copyWith({
    GameTypingStatus? status,
    String? message,
  }) {
    return GameTypingState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
