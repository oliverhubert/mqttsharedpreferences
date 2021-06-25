import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../mqtt/mqtt_client.dart';
import 'package:flutter/services.dart';
import '../widgets/main_drawer.dart';

class QRViewScreen extends StatefulWidget {
  static const routeName = '/qrview';
  @override
  State<StatefulWidget> createState() => _QRViewScreenState();
}

enum ScanState {
  ticketScan,
  cwbScan,
  readyToSend,
}

class _QRViewScreenState extends State<QRViewScreen> {
  Barcode? result;
  String? _ticketNr = '';
  String? _cwbNr = '';
  String? _datetime = '';
  double _unixtime = 0;
  bool? _flashState = false;
  ScanState _scanState = ScanState.ticketScan;
  QRViewController? controller;
  var _mqttConnected = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void _sendResult() {
    if (!_mqttConnected) {
      print('mqttInit is not initialized!');
      //mqttInit(_onConnected, _onDisconnected);
      return;
    }
    print('mqttSend called!');
    _unixtime = DateTime.parse(_datetime!).millisecondsSinceEpoch / 1000;
    mqttSend(_unixtime.toString() + ',' + _ticketNr! + ',' + _cwbNr!,
        'CwbQrCode/qr-a51-1');
    setState(() {
      _scanState = ScanState.ticketScan;
      _ticketNr = '';
      _cwbNr = '';
      _datetime = '';
    });
    //FlutterRingtonePlayer.playNotification();
    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
  }

  void _onConnected() {
    setState(() {
      _mqttConnected = true;
    });
    print('MQTT::OnConnected callback - Client connection was sucessful');
    //mqttSend('Hallo taskit', 'Dart/Mqtt_client/testtopic');
  }

  void _onDisconnected() {
    setState(() {
      _mqttConnected = false;
    });
    print('MQTT::OnDisconnected callback - Client disconnection');
    //mqttSend('Hallo taskit', 'Dart/Mqtt_client/testtopic');
  }

  @override
  void initState() {
    super.initState();
    mqttInit(_onConnected, _onDisconnected);
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  void reassemble() {
    print('reassamble');
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Text('CWB Checkin     '),
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {},
              child: Icon(
                  _mqttConnected ? Icons.cloud_done_outlined : Icons.cloud_off),
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                await controller?.toggleFlash();
                final flash = await controller!.getFlashStatus();
                setState(() {
                  _flashState = flash;
                });
              },
              child: Icon(_flashState! ? Icons.flash_on : Icons.flash_off),
            ),
          ),
        ],
      )),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[
          Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
              ),
              Text('Ticket/User-Nr:'),
              ElevatedButton(
                onPressed: () {},
                child: Text(_ticketNr!),
              ),
              Container(
                margin: EdgeInsets.all(5),
              ),
              Text('CWB-Nr:'),
              ElevatedButton(
                onPressed: () {},
                child: Text(_cwbNr!),
              ),
              Container(
                margin: EdgeInsets.all(5),
              ),
              Text('Date/Time:'),
              ElevatedButton(
                onPressed: () {},
                child: Text(_datetime!),
              ),
              Container(
                margin: EdgeInsets.all(10),
              ),
            ],
          ),
          Expanded(flex: 4, child: _buildQrView(context)),
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: _scanState == ScanState.ticketScan
                        ? MaterialStateProperty.all<Color>(Colors.green)
                        : MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    setState(() {
                      _scanState = ScanState.ticketScan;
                      _ticketNr = '';
                      _cwbNr = '';
                      _datetime = '';
                    });
                  },
                  child: Text('Scan Ticket/User'),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: _scanState == ScanState.cwbScan
                        ? MaterialStateProperty.all<Color>(Colors.green)
                        : MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    if (_scanState == ScanState.readyToSend) {
                      setState(() {
                        _scanState = ScanState.cwbScan;
                        _cwbNr = '';
                        _datetime = '';
                      });
                    }
                  },
                  child: Text('Scan CWB'),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: _scanState == ScanState.readyToSend
                        ? MaterialStateProperty.all<Color>(Colors.green)
                        : MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    if (_scanState == ScanState.readyToSend) {
                      _sendResult();
                    }
                  },
                  child: Icon(Icons.send),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 400.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      print(scanData.code);
      setState(() {
        result = scanData;
        switch (_scanState) {
          case ScanState.ticketScan:
            if (_cwbNr != scanData.code) {
              _ticketNr = scanData.code;
              _scanState = ScanState.cwbScan;
              FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
              //FlutterRingtonePlayer.playNotification();
            }
            break;
          case ScanState.cwbScan:
            if (_ticketNr != scanData.code) {
              _cwbNr = scanData.code;
              _scanState = ScanState.readyToSend;
              _datetime = DateTime.now().toString();
              FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP2);
              //FlutterRingtonePlayer.playAlarm();
            }
            break;
          case ScanState.readyToSend:
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
