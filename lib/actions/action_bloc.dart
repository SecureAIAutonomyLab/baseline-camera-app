/*
  Created By: Nathan Millwater
  Description: Holds the logic for handling login events
 */

import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_state.dart';

/// Holds the logic for handling the event and changing the state
class ActionBloc extends Bloc<ActionEvent, ActionState> {

  // constructor
  ActionBloc() : super(ActionState());

  /// This function maps a LoginEvent to a LoginState
  /// Parameters: A login event that needs to be handled
  /// Returns: An updated LoginState according to the login event
  @override
  Stream<ActionState> mapEventToState(ActionEvent event) async* {

    if (event is CatalogItemAddedEvent) {
      yield state.copyWith(addItem: event.item);
      // save to device

    } else if (event is CatalogItemRemovedEvent) {
      yield state.copyWith(removeItem: event.item);
      // save to device

    }

  }
}

