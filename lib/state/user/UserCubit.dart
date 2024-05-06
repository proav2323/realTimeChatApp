import 'package:bloc/bloc.dart';
import 'package:realtimechatapp/User.dart';

/// {@template counter_cubit}
/// A [Cubit] which manages an [int] as its state.
/// {@endtemplate}
class UserCubit extends Cubit<User?> {
  /// {@macro counter_cubit}
  UserCubit() : super(null);

  /// Add 1 to the current state.
  void login(User? us) => emit(us);

  /// Subtract 1 from the current state.
  void signUp(User? us) => emit(us);
}
