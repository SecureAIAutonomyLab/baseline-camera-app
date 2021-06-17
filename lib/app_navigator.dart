
import 'package:camera_app/auth/auth_cubit.dart';
import 'package:camera_app/auth/auth_navigator.dart';
import 'package:camera_app/loading_view.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/session_state.dart';
import 'package:camera_app/sesssion_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AppNavigator extends StatelessWidget {
  BuildContext homeContext;

  AppNavigator(BuildContext c) {
    this.homeContext = c;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return Navigator(
        pages: [
          // show loading screen
          if (state is UnknownSessionState)
            MaterialPage(child: LoadingView()),

          // show the auth navigator
          if (state is Unauthenticated)
            MaterialPage(
              child: BlocProvider(
                create: (context) => AuthCubit(sessionCubit: context.read<SessionCubit>()),
                child: AuthNavigator(),
              ),
            ),

          // show the session
          if (state is Authenticated)
            MaterialPage(
                child: CameraExampleHome(
                  username: state.user.username,
                )
            ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
