import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../camera_cubit.dart';
import '../models/cart_model.dart';
import '../models/catalog_model.dart';
import 'edit_action.dart';

class MyCatalog extends StatefulWidget {

  @override
  MyCatalogState createState() => MyCatalogState();
}

class MyCatalogState extends State<MyCatalog> {

  @override
  Widget build(BuildContext context) {
    var catalog = context.watch<CatalogModel>();
    readCatalogFromDevice(catalog);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MyAppBar(),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (context, index) => MyListItem(index, this),
              childCount: catalog.getLength()
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize),
              label: "Action Catalog"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions),
              label: "Current Actions"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          )
        ],
        currentIndex: 0,
        onTap: (index) {
          changePage(index, context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onAddActionButtonPressed(catalog);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> onAddActionButtonPressed(CatalogModel catalog) async {
    Item item = await showDialog(context: context, builder: (BuildContext context) {
      return EditAction();
    });
    // create the id for the item
    if (item != null) {
      item.id = catalog.uniqueID();
      catalog.addToCatalog(item);
      updateUI();
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Item Added')));
    }
  }

  void updateUI() {
    setState(() {});
  }

  void changePage(int index, BuildContext context) {
    if (index == 1)
      context.read<CameraCubit>().showActionList();
    else if (index == 2)
      context.read<CameraCubit>().showHome();
  }
}

void readCatalogFromDevice(CatalogModel catalog) async {
  try {
    // the directory of the app's files
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File file = File('$path/sdfsdf');
  } catch (e) {
    // prepopulate the catalog
  }
}

class AddButton extends StatelessWidget {
  final Item item;
  static const NUMBER_OF_ACTION_BUTTONS = 4;

  const AddButton({@required this.item});

  @override
  Widget build(BuildContext context) {
    // The context.select() method will let you listen to changes to
    // a *part* of a model. You define a function that "selects" (i.e. returns)
    // the part you're interested in, and the provider package will not rebuild
    // this widget unless that particular part of the model changes.
    //
    // This can lead to significant performance improvements.
    var isInCart = context.select<CartModel, bool>(
      // Here, we are only interested whether [item] is inside the cart.
          (cart) => cart.items.contains(item),
    );
    var items = context.watch<CartModel>().items.length;

    return TextButton(
      onPressed: isInCart || items >= NUMBER_OF_ACTION_BUTTONS
          ? null
          : () {
        // If the item is not in cart, we let the user add it.
        // We are using context.read() here because the callback
        // is executed whenever the user taps the button. In other
        // words, it is executed outside the build method.
        var cart = context.read<CartModel>();
        cart.add(item);
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Defer to the widget's default.
        }),
      ),
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}

class MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Action Catalog'),
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.read<CameraCubit>().showHome(),
        ),
      ],
    );
  }
}

class MyListItem extends StatelessWidget {
  final int index;
  final MyCatalogState state;

  const MyListItem(this.index, this.state);

  @override
  Widget build(BuildContext context) {
    var item = context.select<CatalogModel, Item>(
      // Here, we are only interested in the item at [index]. We don't care
      // about any other change.
          (catalog) => catalog.getByPosition(index),
    );
    var textTheme = Theme.of(context).textTheme.headline6;
    var catalog = context.watch<CatalogModel>();
    var cart = context.watch<CartModel>();

    // Users can remove items from the catalog
    return Dismissible(
      // unique key
      key: UniqueKey(),
      onDismissed: (direction) {
        // remove item if it is in the cart
        if (cart.items.contains(item))
          cart.remove(item);
        print("Item index: " + index.toString());
        catalog.removeFromCatalog(item);
        state.updateUI();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${item.name} Removed')));
      },
      background: Container(color: Colors.red),

      child: TextButton(
        onLongPress: () {editActionPressed(context, item);},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LimitedBox(
            maxHeight: 48,
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(item.name, style: textTheme),
                ),
                const SizedBox(width: 24),
                AddButton(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editActionPressed(BuildContext context, Item item) async {
    await showDialog(context: context, builder: (BuildContext context) {
      return EditAction(action: item);
    });
    state.updateUI();
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}