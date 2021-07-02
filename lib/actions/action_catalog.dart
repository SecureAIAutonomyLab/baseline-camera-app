import 'package:camera_app/camera_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../camera_cubit.dart';
import '../models/cart_model.dart';
import '../models/catalog_model.dart';

class MyCatalog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var catalog = context.watch<CatalogModel>();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MyAppBar(),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (context, index) => MyListItem(index),
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
          SnackBar bar = SnackBar(content: Text("Implement"));
          ScaffoldMessenger.of(context).showSnackBar(bar);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void changePage(int index, BuildContext context) {
    if (index == 1)
      context.read<CameraCubit>().showActionList();
    else if (index == 2)
      context.read<CameraCubit>().showHome();
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

  const MyListItem(this.index);

  @override
  Widget build(BuildContext context) {
    var item = context.select<CatalogModel, Item>(
      // Here, we are only interested in the item at [index]. We don't care
      // about any other change.
          (catalog) => catalog.getByPosition(index),
    );
    var textTheme = Theme.of(context).textTheme.headline6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}