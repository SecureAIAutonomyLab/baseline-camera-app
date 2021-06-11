
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/auth/form_submission_status.dart';

import 'login_event.dart';
import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;

  LoginBloc({this.authRepo}) : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // username changed
    if (event is LoginUsernameChanged) {
      yield state.copyWith(username: event.username);

      // password changed
    } else if (event is LoginPasswordChanged) {
      yield state.copyWith(password: event.password);

      // form submitted
    } else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        await authRepo.login();
        yield state.copyWith(formStatus: SubmissionSuccess());
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    }
  }
}

