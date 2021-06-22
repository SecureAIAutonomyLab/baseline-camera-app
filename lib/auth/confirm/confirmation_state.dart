/*
  Created By: Nathan Millwater
  Description: Holds the current state of the confirmation form. Includes
               the current confirmation code with the form submission status
 */

import '../form_submission_status.dart';

class ConfirmationState {
  final String code;
  // getter
  bool get isValidCode => code.length == 6;

  FormSubmissionStatus formStatus;

  ConfirmationState({
    this.code = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// Create a new ConfirmationState object and copy over the
  /// old values and any new values that changed
  ConfirmationState copyWith({
    String code,
    FormSubmissionStatus formStatus,
  }) {
    return ConfirmationState(
      code: code ?? this.code,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
