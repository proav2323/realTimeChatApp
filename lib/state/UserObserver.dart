import 'package:bloc/bloc.dart';

class StateObserver extends BlocObserver {
  /// {@macro counter_observer}
  const StateObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
  }
}
