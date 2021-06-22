/*
  Created By: Nathan Millwater
  Description: Holds the possible events that may occur in
               the confirmation view
 */

abstract class ConfirmationEvent {}

class ConfirmationCodeChanged extends ConfirmationEvent {
  final String code;

  ConfirmationCodeChanged({this.code});
}

class ConfirmationSubmitted extends ConfirmationEvent {}
