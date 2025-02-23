import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var devices = <BluetoothDevice>[].obs; //the result after scanning
  var connectedDevice = Rxn<BluetoothDevice>(); //the connected device
  var isScanning = false.obs; //scanning boolean

  @override
  void onInit() {
    super.onInit();
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }

  // Fungsi untuk scanning perangkat BLE
  void startScan() {
    if (isScanning.value) return;

    isScanning.value = true;
    devices.clear();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (!devices.contains(result.device)) {
          devices.add(result.device);
        }
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      FlutterBluePlus.stopScan();
      isScanning.value = false;
    });
  }

  // Fungsi untuk menghubungkan ke perangkat
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    connectedDevice.value = device;
  }

  // Fungsi untuk memutuskan koneksi perangkat
  Future<void> disconnectDevice() async {
    if (connectedDevice.value != null) {
      await connectedDevice.value!.disconnect();
      connectedDevice.value = null;
    }
  }
}
