import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_credentials.dart';
import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:camera_app/auth/auth_credentials.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  LoginBloc({this.authRepo, this.authCubit}) : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // Username updated
    if (event is LoginUsernameChanged) {
      yield state.copyWith(username: event.username);

      // Password updated
    } else if (event is LoginPasswordChanged) {
      yield state.copyWith(password: event.password);

      // Form submitted
    } else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        final userId = await authRepo.login(
          username: state.username,
          password: state.password,
        );
        yield state.copyWith(formStatus: SubmissionSuccess());

        authCubit.launchSession(AuthCredentials(
          username: state.username,
          userId: userId,
        ));
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }

    } else if (event is LoginFacebook) {
      // facebook login
      print("facebook event");
      //yield state.copyWith(formStatus: FormSubmitting());

    } else if (event is LoginGoogle) {
      // google login
      print("google event");
      // yield state.copyWith(formStatus: FormSubmitting());
      //
      // try {
      //   var res = await Amplify.Auth.signInWithWebUI(provider: AuthProvider.google);
      //
      //   yield state.copyWith(formStatus: SubmissionSuccess());
      //
      //   String username = await _getUsername();
      //   String userId = await _getUserIdFromAttributes();
      //   authCubit.launchSession(AuthCredentials(
      //     username: username,
      //     userId: userId,
      //   ));
      // } on AmplifyException catch (e) {
      //   print(e.message);
      // }
    }
  }

  Future<String> _getUsername() async {
    try {
      final attributes = await Amplify.Auth.getCurrentUser();
      print(attributes.username);
      return attributes.username;
    } catch (e) {
      throw e;
    }
  }

  Future<String> _getUserIdFromAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final userId = attributes
          .firstWhere((element) => element.userAttributeKey == 'sub')
          .value;
      return userId;
    } catch (e) {
      throw e;
    }
  }
}
