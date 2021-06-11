
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/auth/form_submission_status.dart';
import 'package:camera_app/auth/login/login_event.dart';
import 'package:camera_app/auth/sign_up/sign_up_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_cubit.dart';
import 'sign_up_bloc.dart';
import 'sign_up_state.dart';

class SignUpView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // provide repository for later use in the widget tree
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: MaterialApp(
        home: Scaffold(
          // check target platform
          appBar: Theme.of(context).platform == TargetPlatform.iOS ?
          CupertinoNavigationBar(
            middle: Text("Sign up View"),
          )
          : AppBar(
            title: Text("Sign up View"),
          ),
          /// Create bloc to change UI based on state
          body: BlocProvider (
            create: (context) => SignUpBloc(
              authRepo: context.read<AuthRepository>(),
              authCubit: context.read<AuthCubit>(),
            ),
            child: Stack (
                children: [
                  _SignUpForm(),
                  _LoginButton(context)
                ],
              alignment: Alignment.bottomCenter,
            )
          ),
          backgroundColor: Colors.cyan[200],
        ),
      ),
    );
  }

  Widget _SignUpForm() {
    // Listen for bloc event submission failed
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        final status = state.formStatus;
        // if submission failed print the message
        if (status is SubmissionFailed) {
          _showSnackBar(context, status.exception.toString());
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
              _signUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _usernameField() {
    // blocbuilder to update the state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
       return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        // text field validation checking
        validator: (value) => state.isValidUsername ? null : 'Length must be greater than 3',
        // add an event to the login bloc
        onChanged: (value) {
          context.read<SignUpBloc>().add(SignUpUsernameChanged(username: value));
        },
      );
    });
  }


  Widget _passwordField() {
    return BlocBuilder<SignUpBloc, SignUpState> (builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Password',
        ),
        validator: (value) => state.isValidPassword ? null : 'Length must be greater than 6',
        onChanged: (value) {
          context.read<SignUpBloc>().add(SignUpPasswordChanged(password: value));
        },
      );
    });
  }

  Widget _signUpButton() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return state.formStatus is FormSubmitting ? CircularProgressIndicator()
      : ElevatedButton(
        onPressed: () {
          // check if all forms are valid
          if (_formKey.currentState.validate()) {
            context.read<SignUpBloc>().add(SignUpSubmitted());
          }
        },
        child: Text("Sign Up"),
      );
    });
  }

  Widget _LoginButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text("Already have an account? Sign in."),
        onPressed: () => context.read<AuthCubit>().showLogin(),
      ),
    );
  }

  /// displays a snackbar
  void _showSnackBar(BuildContext context, String message) {
    final bar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }
}


