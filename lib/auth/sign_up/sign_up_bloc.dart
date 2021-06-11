
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/auth/form_submission_status.dart';

import '../auth_cubit.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  SignUpBloc({
    this.authRepo,
    this.authCubit
  }) : super(SignUpState());

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    // username changed
    if (event is SignUpUsernameChanged) {
      yield state.copyWith(username: event.username);

      // password changed
    } else if (event is SignUpPasswordChanged) {
      yield state.copyWith(password: event.password);

      // form submitted
    } else if (event is SignUpSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        await authRepo.signUp(username: state.username, password: state.password);
        yield state.copyWith(formStatus: SubmissionSuccess());

        // Bring back to login page
        authCubit.showConfirmSignUp(username: state.username, password: state.password);
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    }
  }
}

