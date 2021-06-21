import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:camera_app/models/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'login_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginView extends StatefulWidget {

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool rememberSession = false;
  bool showIcon = true;

  @override
  void initState() {
    super.initState();
    _storeRememberSession();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Widget _chooseAppBar(String title) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _chooseAppBar("Login"),
      backgroundColor: Colors.cyan[200],
      body: BlocProvider(
        create: (context) => LoginBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _loginForm(),
            _showSignUpButton(context),
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image(image: AssetImage("assets/open_cloud.jpeg"))
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 560),
              child: showIcon ? Icon(Icons.camera_alt, size: 200, color: Colors.grey[600],) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginForm() {
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            if (formStatus.exception is UserNotFoundException) {
              _showSnackBar(context, "Invalid Username or Password");
            } else {
              _showSnackBar(context, formStatus.exception.toString());
            }
            // set to initial state
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
                //_googleLogin(),
                _facebookLogin(),
                _usernameField(),
                _passwordField(),
                SizedBox(height: 5,),
                _loginButton(),
                _checkBox(),

              ],
            ),
          ),
        ));
  }

  Widget _checkBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 85),
      child: CheckboxListTile(
          secondary: Text("Remember Me"),
          controlAffinity: ListTileControlAffinity.leading,
          value: rememberSession,
          onChanged: (bool changed) {
            setState(() {
              rememberSession = changed;
            });
            // save info on device
            _storeRememberSession();
          }
      ),
    );
  }

  /// Store the value from the remember session checkbox
  Future<void> _storeRememberSession() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File file = File('$path/rememberSession.txt');
    file.writeAsString(rememberSession.toString());
    // print(await file.readAsString());
  }

  Widget _googleLogin() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextButton(
        onPressed: () => context.read<LoginBloc>().add(LoginGoogle()),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Image(
                    image: AssetImage("assets/google.png"),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Sign In with Google",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _facebookLogin() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextButton(
        onPressed: () => context.read<LoginBloc>().add(LoginFacebook()),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Image(
                    image: AssetImage("assets/facebook.png"),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Sign In with Facebook",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _usernameField() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        validator: (value) =>
        state.isValidUsername ? null : 'Username is too short',
        onChanged: (value) => context.read<LoginBloc>().add(
          LoginUsernameChanged(username: value),
        ),
        onTap: () {setState(() {showIcon = false;});},
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showIcon = true;});
        },
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Password',
        ),
        validator: (value) =>
        state.isValidPassword ? null : 'Password is too short',
        onChanged: (value) => context.read<LoginBloc>().add(
          LoginPasswordChanged(password: value),
        ),
        onTap: () {setState(() {showIcon = false;});},
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showIcon = true;});
        },
      );
    });
  }

  Widget _loginButton() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            context.read<LoginBloc>().add(LoginSubmitted());
          }
        },
        child: SizedBox(
          height: 45,
            width: 80,
            child: Center(child: Text('Login',style: TextStyle(fontSize: 25),))
        ),
      );
    });
  }

  Widget _showSignUpButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text('Don\'t have an account? Sign up.'),
        onPressed: () => context.read<AuthCubit>().showSignUp(),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
