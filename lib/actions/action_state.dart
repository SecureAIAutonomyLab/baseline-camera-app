/*
  Created By: Nathan Millwater
  Description:
 */


import 'package:camera_app/models/catalog_model.dart';


class ActionState {
  List<Item> catalog;

  ActionState({
    this.catalog
  });


  ActionState copyWith({
    Item addItem,
    Item removeItem,
  }) {
    if (addItem != null) {
      catalog.add(addItem);
      return ActionState(
        catalog: this.catalog
      );
    } else if (removeItem != null) {
      catalog.remove(removeItem);
      return ActionState(
        catalog: this.catalog
      );
    }
  }
}

abstract class ActionEvent {}

class CatalogItemAddedEvent extends ActionEvent {
  final Item item;

  CatalogItemAddedEvent({this.item});
}

class CatalogItemRemovedEvent extends ActionEvent {
  final Item item;

  CatalogItemRemovedEvent({this.item});
}