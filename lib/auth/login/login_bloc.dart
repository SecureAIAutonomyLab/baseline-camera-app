
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/auth/form_submission_status.dart';

import '../auth_cubit.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  LoginBloc({this.authRepo, this.authCubit}) : super(LoginState());

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
        final userID = await authRepo.login(username: state.username, password: state.password);
        yield state.copyWith(formStatus: SubmissionSuccess());

        authCubit.launchSession(AuthCredentials(username: state.username, userId: userID));
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    }
  }
}

