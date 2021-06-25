/*
  Created By: Nathan Millwater
  Description: Holds the possible events that may occur in
               the confirmation view
 */

abstract class ConfirmationEvent {}

/// Event when user changes the text in the confirmation code field
class ConfirmationCodeChanged extends ConfirmationEvent {
  final String code;

  ConfirmationCodeChanged({this.code});
}

/// Event when confirm button is pressed
class ConfirmationSubmitted extends ConfirmationEvent {}
