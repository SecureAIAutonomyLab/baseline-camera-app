// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';

/// A proxy of the catalog of items the user can buy.
///
/// In a real app, this might be backed by a backend and cached on device.
/// In this sample app, the catalog is procedurally generated and infinite.
///
/// For simplicity, the catalog is expected to be immutable (no products are
/// expected to be added, removed or changed during the execution of the app).
class CatalogModel {
  static List<String> itemNames = [
    'Control Flow',
    'Interpreter',
    'Recursion',
    'Sprint',
    'Heisenbug',
    'Spaghetti',
    'Hydra Code',
    'Off-By-One',
    'Scope',
    'Callback',
    'Closure',
    'Automata',
    'Bit Shift',
    'Currying',
  ];

  int uniqueID() {
    final rng = Random();
    bool equal; int id;
    do {
      id = rng.nextInt(10000);
      equal = false;
      for (Item item in catalog) {
        if (item.id == id) {
          equal = true; break;
        }
      }
    } while (equal);
    return id;
  }

  List<Item> catalog;

  // initialize the model
  CatalogModel() {
    catalog = [];
    for (int i = 0; i < itemNames.length; i++) {
      int temp = uniqueID();
      final item = Item(temp, itemNames[i]);
      catalog.add(item);
    }
  }

  List<Item> getCatalog() => catalog;

  void addToCatalog(Item item) {
    this.catalog.add(item);
  }

  void removeFromCatalog(Item item) {
    this.catalog.remove(item);
  }

  /// Get item by [id].
  Item getById(int id) => catalog[id];

  int getLength() => catalog.length;

  /// Get item by its position in the catalog.
  Item getByPosition(int position) {
    // In this simplified case, an item's position in the catalog
    // is also its id.
    return getById(position);
  }
}

class Item {
  final int id;
  final String name;
  final Color color;

  Item(this.id, this.name)
  // To make the sample app look nicer, each item is given one of the
  // Material Design primary colors.
      : color = Colors.primaries[id % Colors.primaries.length];

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Item && other.id == id;
}