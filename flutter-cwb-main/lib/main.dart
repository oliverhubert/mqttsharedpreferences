// @dart=2.9

import 'package:cwb/screens/ble_edit_screen.dart';
import 'package:flutter/material.dart';

import 'screens/mqtt_config_screen.dart';
import 'screens/qrview_screen.dart';
import 'screens/ble_scan_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'taskit CWB',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.amber,
        canvasColor: Color.fromRGBO(255, 254, 229, 1),
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
            bodyText2: TextStyle(
              color: Color.fromRGBO(20, 51, 51, 1),
            ),
            bodyText1: TextStyle(
              color: Color.fromRGBO(20, 51, 51, 1),
            ),
            headline6: TextStyle(
              fontSize: 20,
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
            )),
      ),
      // home: CategoriesScreen(),
      initialRoute: QRViewScreen.routeName,
      routes: {
        //'/': (ctx) => QRViewScreen(),
        QRViewScreen.routeName: (ctx) => QRViewScreen(),
        MqttConfigScreen.routeName: (ctx) => MqttConfigScreen(),
        BleScanScreen.routeName: (ctx) => BleScanScreen(),
        BleEditScreen.routeName: (ctx) => BleEditScreen(),
        //FiltersScreen.routeName: (ctx) => FiltersScreen(_filters, _setFilters),
      },
      onGenerateRoute: (settings) {
        print(settings.arguments);
        // if (settings.name == '/meal-detail') {
        //   return ...;
        // } else if (settings.name == '/something-else') {
        //   return ...;
        // }
        // return MaterialPageRoute(builder: (ctx) => CategoriesScreen(),);
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => QRViewScreen(),
        );
      },
    );
  }
}
