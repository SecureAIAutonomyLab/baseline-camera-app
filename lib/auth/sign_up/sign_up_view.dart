/*
  Created By: Nathan Millwater
  Description: Holds all of the widgets that makeup the signup screen
 */

import 'package:camera_app/auth/sign_up/sign_up_bloc.dart';
import 'package:camera_app/auth/sign_up/sign_up_event.dart';
import 'package:camera_app/auth/sign_up/sign_up_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';

class SignUpView extends StatefulWidget {

  @override
  _SignUpViewState createState() => _SignUpViewState();
}


class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool showImage = true;

  /// Returns a widget that choose an appbar based on the platform
  Widget _chooseAppBar(String title, BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
      );
    }
    else {
      // android platform
      return AppBar(
        title: Text(title),
      );
    }
  }

  /// Initial build method of the stateless widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // sign up view appbar
      appBar: _chooseAppBar("Sign Up", context),
      backgroundColor: Colors.cyan[200],
      // bloc provider to provide access to auth cubit and repository
      body: BlocProvider(
        create: (context) => SignUpBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _signUpForm(),
            _showLoginButton(context),
            // display the open cloud image
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: showImage ? SizedBox(
                  width: 100,
                  height: 100,
                  child: Image(image: AssetImage("assets/open_cloud.jpeg"))
              ) : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a widget that holds the text fields for signing up
  Widget _signUpForm() {
    // A Listener to show error if one occurs
    return BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            _showSnackBar(context, formStatus.exception.toString());
          }
          // set back to initial state once error occurs
          state.formStatus = InitialFormStatus();
        },
        // form widget holds all text fields
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _usernameField(),
                _emailField(),
                _passwordField(),
                // spacing
                SizedBox(height: 5,),
                _signUpButton(),
              ],
            ),
          ),
        ));
  }

  /// Returns a text field widget that takes in a username
  Widget _usernameField() {
    // provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
        state.isValidUsername ? null : 'Username is too short',
        // Everytime user changes username, create an event
        onChanged: (value) => context.read<SignUpBloc>().add(
          SignUpUsernameChanged(username: value),
        ),
        // If text field is tapped, remove open cloud image
        onTap: () {setState(() {showImage = false;});},
        // Show image again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showImage = true;});
        },
      );
    });
  }

  /// Return the email field widget for the sign up form
  Widget _emailField() {
    // Provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Email',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) => state.isValidUsername ? null : 'Invalid email',
        // Everytime user changes email, create an event
        onChanged: (value) => context.read<SignUpBloc>().add(
          SignUpEmailChanged(email: value),
        ),
        // If text field is tapped, remove open cloud image
        onTap: () {setState(() {showImage = false;});},
        // Show image again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showImage = true;});
        },
      );
    });
  }

  Widget _passwordField() {
    // Provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Password',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
        state.isValidPassword ? null : 'Password is too short',
        // Everytime user changes password, create an event
        onChanged: (value) => context.read<SignUpBloc>().add(
          SignUpPasswordChanged(password: value),
        ),
        // If text field is tapped, remove open cloud image
        onTap: () {setState(() {showImage = false;});},
        // Show image again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showImage = true;});
        },
      );
    });
  }

  /// Returns the signup button widget that starts the signup process
  Widget _signUpButton() {
    // Provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      // Show wait indicator if form is still submitting
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
        onPressed: () {
          // make sure username and password are valid before submitting
          if (_formKey.currentState.validate()) {
            // Create the login submitted event
            context.read<SignUpBloc>().add(SignUpSubmitted());
          }
        },
        child: SizedBox(
          height: 45,
          width: 100,
          child: Center(child: Text('Sign Up',style: TextStyle(fontSize: 25),)))
      );
    });
  }

  /// Return the login button widget that takes the user to
  /// the login page
  Widget _showLoginButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text('Already have an account? Sign in.'),
        // tell auth navigator to show login page
        onPressed: () => context.read<AuthCubit>().showLogin(),
      ),
    );
  }

  /// Takes in a BuildContext and message and displays a snackbar
  /// at the bottom of the screen
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
