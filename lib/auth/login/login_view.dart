
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/auth/form_submission_status.dart';
import 'package:camera_app/auth/login/login_event.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_cubit.dart';
import 'login_bloc.dart';
import 'login_state.dart';

class LoginView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  // Only for navigating back to home

  @override
  Widget build(BuildContext context) {
    // provide repository for later use in the widget tree
      return MaterialApp(
        home: Scaffold(
          // check target platform
          appBar: Theme.of(context).platform == TargetPlatform.iOS ?
          CupertinoNavigationBar(
            middle: Text("Login View"),
          )
          : AppBar(
            title: Text("Login View"),
          ),
          /// Create bloc to change UI based on state
          body: BlocProvider (
            create: (context) => LoginBloc(
              authRepo: context.read<AuthRepository>(),
              authCubit: context.read<AuthCubit>(),
            ),
            child: Stack (
                children: [_loginForm(),
                  _signUpButton(context)
                ],
              alignment: Alignment.bottomCenter,
            )
          ),
          backgroundColor: Colors.cyan[200],
        ),
      );
  }

  Widget _loginForm() {
    // Listen for bloc event submission failed
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        final status = state.formStatus;
        // if submission failed print the message
        if (status is SubmissionFailed) {
          _showSnackBar(context, status.exception.toString());
        } else if (status is SubmissionSuccess) {
          _showSnackBar(context, "Login Success");
          // set form status back to initial
          state.formStatus = InitialFormStatus();
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _usernameField(),
              _passwordField(),
              _loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _usernameField() {
    // blocbuilder to update the state
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
       return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        // text field validation checking
        validator: (value) => state.isValidUsername ? null : 'Length must be greater than 3',
        // add an event to the login bloc
        onChanged: (value) {
          context.read<LoginBloc>().add(LoginUsernameChanged(username: value));
        },
      );
    });
  }


  Widget _passwordField() {
    return BlocBuilder<LoginBloc, LoginState> (builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Password',
        ),
        validator: (value) => state.isValidPassword ? null : 'Length must be greater than 6',
        onChanged: (value) {
          context.read<LoginBloc>().add(LoginPasswordChanged(password: value));
        },
      );
    });
  }

  Widget _loginButton() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return state.formStatus is FormSubmitting ? CircularProgressIndicator()
      : ElevatedButton(
        onPressed: () {
          // check if all forms are valid
          if (_formKey.currentState.validate()) {
            context.read<LoginBloc>().add(LoginSubmitted());
          }
        },
        child: Text("Login"),
      );
    });
  }

  Widget _signUpButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text("Don't have an account? Sign up."),
        onPressed: () => context.read<AuthCubit>().showSignUp(),
      ),
    );
  }

  /// displays a snackbar
  void _showSnackBar(BuildContext context, String message) {
    final bar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }
}


