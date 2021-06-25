import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cwb/mqtt/mqtt_config_form.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MqttConfig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mqtt',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Config(),
      routes: <String, WidgetBuilder>{
        NextPage.routeName: (context) => NextPage(),
      },
    );
  }
}

class Config extends StatefulWidget {
  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  var _broker = TextEditingController();
  var _clientid = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MQTT Config"),
      ),
      body: Column(
        children: [
          Text("MQTT Broker URL"),
          TextField(
              controller: _broker ),
          Text("ClientID"),
          TextField(
              controller: _clientid ),
          RaisedButton(
              child: Text("Connect to Broker"),
              onPressed: () {
                saveBroker();
                saveClientid();
                Navigator.of(context).pushNamed(NextPage.routeName);
              }),
        ],
      ),
    );
  }
  void saveBroker() {
    String broker = _broker.text;
    saveBrokerPreference(broker).then((bool committed) {});
  }
  void saveClientid() {
    String clientid = _clientid.text;
    saveClientidPreference(clientid).then((bool committed){});
  }
}

Future<bool> saveBrokerPreference(String broker) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("broker", broker);

  return prefs.commit();
}

Future<bool> saveClientidPreference(String clientid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("clientid", clientid);

  return prefs.commit();
}

Future<String> getBrokerPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String broker = prefs.getString ("broker");
  return broker;
}

Future<String> getClientidPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String clientid = prefs.getString ("broker");
  return clientid;
}


class NextPage extends StatefulWidget {
  static String routeName ="/nextPage";

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  String _broker = "";
  String _clientid = "";

  @override
  void initState() {
    getBrokerPreference().then(_updateBroker);
    getClientidPreference().then(_updateClientid);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MQTT Config Screen"),
      ),
      body: Column(
        children: [

          Text(_broker),
          Text("check"),
          Text(_clientid),
        ],
      ),
    );
  }

  void _updateBroker(String broker) {
    setState(() {
      this._broker = broker;
    });
  }

  void _updateClientid(String clientid) {
    setState(() {
      this._clientid = clientid;
    });
  }
}

