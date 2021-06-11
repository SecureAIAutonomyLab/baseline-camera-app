
import 'package:camera_app/auth/sign_up/sign_up_view.dart';
import 'package:flutter/cupertino.dart';
import 'auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/auth/login/login_view.dart';
import 'package:camera_app/main.dart';

class AuthNavigator extends StatelessWidget {

  AuthNavigator(BuildContext c) {
    this.homeContext = c;
  }
  BuildContext homeContext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Navigator(
        pages: [
          // show login
          if (state == AuthState.login) MaterialPage(child: LoginView(homeContext)),
          // show signup
          if (state == AuthState.signUp) MaterialPage(child: SignUpView()),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });

  }
}
