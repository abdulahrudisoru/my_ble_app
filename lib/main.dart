import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  //FlutterBluePlus.setlogLevel() >> mengatur level log
  /**
   * none >> Tidak menampilkan log sama sekali.
   * error >> Menampilkan hanya pesan error.
   * warning >> Menampilkan pesan error & peringatan.
   * info >> Menampilkan pesan error, peringatan, dan informasi umum.
   * debug >> Menampilkan lebih banyak detail debugging.
   * verbose >> Menampilkan semua log (paling detail).
   */
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyBleApp());
}

class MyBleApp extends StatefulWidget {
  const MyBleApp({super.key});

  @override
  State<MyBleApp> createState() => _MyBleAppState();
}

class _MyBleAppState extends State<MyBleApp> {
  //BluetoothAdapterState >> enum yg mempresentasikan status bluetooth di device (sendiri).
  //BluetoothAdapterState.unknown >> Status awal (default), artinya status Bluetooth belum diketahui sebelum dicek.
  /**
   * unknown >> Status Bluetooth belum diketahui.
   * unavailable >> Bluetooth tidak tersedia di perangkat (misalnya perangkat tidak mendukung BLE).
   * unauthorized >>	Aplikasi tidak memiliki izin untuk menggunakan Bluetooth.
   * turningOn >> Bluetooth sedang dinyalakan.
   * on >>	Bluetooth dalam keadaan aktif.
   * turningOff >>	Bluetooth sedang dimatikan.
   * off >> Bluetooth dalam keadaan mati.
   */
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(color: Colors.lightBlue, home: screen, navigatorObservers: [],);
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}