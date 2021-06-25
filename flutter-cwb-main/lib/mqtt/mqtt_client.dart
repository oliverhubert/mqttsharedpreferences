import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

//final client = MqttServerClient('test.mosquitto.org', '');
final client = MqttServerClient('hip-assistant.cloudmqtt.com', '');

Future<int> mqttInit(final void Function() onConnected,
    final void Function() onDisconnected) async {
  client.logging(on: false);

  client.keepAlivePeriod = 20;

  client.onDisconnected = onDisconnected;

  client.onConnected = onConnected;

  client.onSubscribed = onSubscribed;

  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('A51-1')
      .withWillTopic('willtopic') // If you set this you must set a will message
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('MQTT::Mosquitto client connecting....');
  client.connectionMessage = connMess;

  try {
    await client.connect('CwbQrCode', '12345678');
  } on NoConnectionException catch (e) {
    print('MQTT::client exception - $e');
    client.disconnect();
  } on SocketException catch (e) {
    print('MQTT::socket exception - $e');
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('MQTT::Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    print(
        'MQTT::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  /// Ok, lets try a subscription
  //print('MQTT::Subscribing to the test/lol topic');
  // const topic = 'test/lol'; // Not a wildcard topic
  // client.subscribe(topic, MqttQos.atMostOnce);

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print(
        'MQTT::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
  });

  /// If needed you can listen for published messages that have completed the publishing
  /// handshake which is Qos dependant. Any message received on this stream has completed its
  /// publishing handshake with the broker.
  client.published!.listen((MqttPublishMessage message) {
    print(
        'MQTT::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
  });

  /// Lets publish to our topic
  /// Use the payload builder rather than a raw buffer
  /// Our known topic to publish to
  const pubTopic = 'Dart/Mqtt_client/testtopic';
  //final builder = MqttClientPayloadBuilder();
  //builder.addString('Hello from mqtt_client');

  /// Subscribe to it
  print('MQTT::Subscribing to the Dart/Mqtt_client/testtopic topic');
  client.subscribe(pubTopic, MqttQos.exactlyOnce);

  /// Publish it
  //print('MQTT::Publishing our topic');
  //client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

  //print('MQTT::Sleeping....');
  //await MqttUtilities.asyncSleep(10);

  //print('MQTT::Unsubscribing');
  //client.unsubscribe(topic);

  //await MqttUtilities.asyncSleep(2);
  //print('MQTT::Disconnecting');
  //client.disconnect();
  print('MQTT::Return');
  return 0;
}

void mqttSend(String message, String topic) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(message);
  client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
}

/// The subscribed callback
void onSubscribed(String topic) {
  print('MQTT::Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
/*void onDisconnected() {
  print('MQTT::OnDisconnected client callback - Client disconnection');
  if (client.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    print('MQTT::OnDisconnected callback is solicited, this is correct');
  }
  exit(-1);
}
*/

/// The successful connect callback
//void onConnected() {
//  print(
//      'MQTT::OnConnected client callback - Client connection was sucessful');
//  mqttSend('Hallo taskit', 'Dart/Mqtt_client/testtopic');
//}

/// Pong callback
void pong() {
  print('MQTT::Ping response client callback invoked');
}
