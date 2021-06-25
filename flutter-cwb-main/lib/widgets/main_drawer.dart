import 'package:cwb/screens/mqtt_config_screen.dart';
import 'package:cwb/screens/qrview_screen.dart';
import 'package:cwb/screens/ble_scan_screen.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(
      String title, IconData icon, void Function() tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          /*
          Container(
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor,
            child: Text(
              'Menu!',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          */
          SizedBox(
            height: 50,
          ),
          buildListTile('CWB Checkin', Icons.camera, () {
            Navigator.of(context).pushReplacementNamed(QRViewScreen.routeName);
          }),
          buildListTile('MQTT', Icons.settings_cell, () {
            Navigator.of(context)
                .pushReplacementNamed(MqttConfigScreen.routeName);
          }),
          buildListTile('BLE Devices', Icons.settings_cell, () {
            Navigator.of(context).pushReplacementNamed(BleScanScreen.routeName);
          }),
        ],
      ),
    );
  }
}
