import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleEditScreen extends StatefulWidget {
  static const routeName = '/ble-edit';

  @override
  _BleEditScreenState createState() => _BleEditScreenState();
}

class _BleEditScreenState extends State<BleEditScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _nameController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  //String? _name = '';
/*
  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    
    if (isValid) {
      _formKey.currentState!.save();
      
      widget.submitFn(
        _broker!.trim(),
        _clientid!.trim(),
        _user!.trim(),
        _password!.trim(),
        _topic!.trim(),
        context,
      );
      
    }
    
  }
  */

  @override
  Widget build(BuildContext context) {
    final c =
        ModalRoute.of(context)!.settings.arguments as BluetoothCharacteristic;
    void _read() async {
      List<int> value = await c.read();
      _nameController.text = utf8.decode(value);
      print('Name:' + _nameController.text);
    }

    void _write() async {
      await c.write(utf8.encode(_nameController.text));
      print('Name:' + utf8.encode(_nameController.text).toString());
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
              'BLE Edit 0x' + c.uuid.toString().toUpperCase().substring(4, 8)),
        ),
        body: Center(
          child: Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        key: ValueKey('name'),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        controller: _nameController,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 4) {
                            return 'Please enter at least 4 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Name of BLE-Device',
                        ),
                        onSaved: (value) {
                          //_name = value;
                        },
                      ),
                      //if (widget.isLoading) CircularProgressIndicator(),
                      //if (!widget.isLoading)
                      ElevatedButton(
                        child: Text('Read Name'),
                        onPressed: _read,
                      ),
                      ElevatedButton(
                        child: Text('Write Name'),
                        onPressed: _write,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
