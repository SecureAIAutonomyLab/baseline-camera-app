import 'package:camera_app/models/catalog_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class EditAction extends StatefulWidget {
  Item action;

  EditAction({this.action});

  @override
  EditActionState createState() => EditActionState(editingAction: action);
}

class EditActionState extends State<EditAction> {
  final _formKey = GlobalKey<FormState>();
  Color pickerColor = Colors.black;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  Item editingAction;
  String buttonText;
  String title;

  EditActionState({this.editingAction}) {
    if (editingAction != null) {
      nameController.text = editingAction.name;
      descriptionController.text = editingAction.description;
      pickerColor = editingAction.color;
      buttonText = "Done";
      title = "Editing an Action";
    } else {
      buttonText = "Add";
      title = "Add an Action";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  icon: Icon(Icons.pending_actions),
                ),
                controller: nameController,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text("Description",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  icon: Icon(Icons.message),
                ),
                controller: descriptionController,
                minLines: 1,
                maxLines: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text("Color",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 50,
                      height: 50,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: pickerColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))))),
                  ElevatedButton(
                      onPressed: openColorPicker,
                      child: Text("Change Color")
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            child: Text(buttonText),
            onPressed: () {
              // create the new action
              final item = Item(
                  name: nameController.text,
                  color: pickerColor,
                  description: descriptionController.text
              );
              // copy over values
              if (editingAction != null) {
                editingAction.color = pickerColor;
                editingAction.description = descriptionController.text;
                editingAction.name = nameController.text;
              }
              // return the new item from the popup
              Navigator.pop(context, item);
            })
      ],
    );
  }

  void openColorPicker() {
    showDialog(
        context: context, builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select a Color"),
            content: MaterialPicker(
              onColorChanged: changeColor,
              pickerColor: pickerColor,
            ),
            actions: [
              ElevatedButton(onPressed: () {Navigator.pop(context);},
                  child: Text("Done"))
            ],
          );
    });
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
}
