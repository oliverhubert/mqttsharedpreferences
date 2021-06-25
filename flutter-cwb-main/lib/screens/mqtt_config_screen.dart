import 'package:flutter/material.dart';
import '../mqtt/mqtt_config_form.dart';
import '../widgets/main_drawer.dart';
//import '../mqtt/mqtt_client.dart';

class MqttConfigScreen extends StatefulWidget {
  static const routeName = '/mqtt-config';
  @override
  _MqttConfigScreenState createState() => _MqttConfigScreenState();
}

class _MqttConfigScreenState extends State<MqttConfigScreen> {
  var _isLoading = false;

  void _submitMqttConfigForm(
    String server,
    String clientid,
    String user,
    String password,
    String topic,
    BuildContext ctx,
  ) {
    setState(() {
      _isLoading = true;
    });
    //mqttInit(_onConnected);
    //mqttSend('Hallo taskit', 'Dart/Mqtt_client/testtopic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Config'),
      ),
      drawer: MainDrawer(),
      body: MqttConfigForm(
        _submitMqttConfigForm,
        _isLoading,
      ),
    );
  }
}
