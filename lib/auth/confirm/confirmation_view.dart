/*
  Created By: Nathan Millwater
  Description: Holds all of the widgets that makeup the confirmation screen
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'confirmation_bloc.dart';
import 'confirmation_event.dart';
import 'confirmation_state.dart';

class ConfirmationView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

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
      // confirmation view appbar
      appBar: _chooseAppBar("Confirm Signup", context),
      backgroundColor: Colors.cyan[200],
      // bloc provider to provide access to auth cubit and repository
      body: BlocProvider(
        create: (context) => ConfirmationBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: _confirmationForm(),
      ),
    );
  }

  /// Returns a widget that holds the text fields for confirming
  Widget _confirmationForm() {
    // A Listener to show error if one occurs
    return BlocListener<ConfirmationBloc, ConfirmationState>(
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
                _codeField(),
                // spacing
                SizedBox(height: 5,),
                _confirmButton(),
                Text("Note: You must confirm your email address for "
                    "your account to be activated", textAlign: TextAlign.center,),
              ],
            ),
          ),
        ));
  }

  /// Returns a text field widget that takes in the confirmation code
  Widget _codeField() {
    // provide access to confirmation bloc and confirmation state
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(
        builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Confirmation Code',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
            state.isValidCode ? null : 'Invalid confirmation code',
        // Every time the user changes the code, create an event
        onChanged: (value) => context.read<ConfirmationBloc>().add(
              ConfirmationCodeChanged(code: value),
            ),
      );
    });
  }

  /// Returns the confirm button widget that starts the confirmation logic
  Widget _confirmButton() {
    // provide access to confirmation bloc and confirmation state
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(builder: (context, state) {
          // Show wait indicator if form is still submitting
          return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () {
                // make sure code is valid before submitting
                if (_formKey.currentState.validate()) {
                  // create the confirmation submitted event
                  context.read<ConfirmationBloc>().add(ConfirmationSubmitted());
                }
              },
              child: SizedBox(
                height: 45,
                width: 100,
                child: Center(child: Text('Confirm',style: TextStyle(fontSize: 25),))
              ),
            );
    });
  }

  /// Takes in a BuildContext and message and displays a snackbar
  /// at the bottom of the screen
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
