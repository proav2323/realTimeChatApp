import 'package:bloc/bloc.dart';
import 'package:realtimechatapp/Chat.dart';
import 'package:realtimechatapp/User.dart';

/// {@template counter_cubit}
/// A [Cubit] which manages an [int] as its state.
/// {@endtemplate}
class ChatCubit extends Cubit<List<Chat>> {
  /// {@macro counter_cubit}
  ChatCubit() : super([]);

  /// Add 1 to the current state.
  void set(List<Chat> us) => emit(us);
}
