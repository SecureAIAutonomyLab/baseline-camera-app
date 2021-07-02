/*
  Created By: Nathan Millwater
  Description: Holds the logic for
 */


import 'package:camera_app/actions/action_catalog.dart';
import 'package:camera_app/camera_example_home.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'actions/action_list.dart';
import 'camera_cubit.dart';
import 'models/cart_model.dart';
import 'models/catalog_model.dart';



/// App Navigator widget that handles navigation between login screens
/// and camera home screen
class CameraNavigator extends StatelessWidget {

  final home = CameraExampleHome(username: "do not use");

  /// standard build method that creates the widget
  @override
  Widget build(BuildContext context) {

    return BlocBuilder<CameraCubit, CameraState> (builder: (context, state) {
      return MultiProvider(
          providers: [
            // In this sample app, CatalogModel never changes, so a simple Provider
            // is sufficient.
            Provider(create: (context) => CatalogModel()),
            // CartModel is implemented as a ChangeNotifier, which calls for the use
            // of ChangeNotifierProvider. Moreover, CartModel depends
            // on CatalogModel, so a ProxyProvider is needed.
            ChangeNotifierProxyProvider<CatalogModel, CartModel>(
              create: (context) => CartModel(),
              update: (context, catalog, cart) {
                if (cart == null) throw ArgumentError.notNull('cart');
                cart.catalog = catalog;
                return cart;
              },
            ),
          ],
          child: Navigator(
            pages: [
              if (state == CameraState.actionList)
                MaterialPage(child: MyCart()),
              if (state == CameraState.actionCatalog)
                MaterialPage(child: MyCatalog()),
              if (state == CameraState.home)
                MaterialPage(child: home),
            ],
            onPopPage: (route, result) => route.didPop(result),
          )
      );
    });
  }
}
