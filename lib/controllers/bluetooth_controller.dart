import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var devices = <BluetoothDevice>[].obs; // Hasil scanning
  var connectedDevice = Rxn<BluetoothDevice>(); // Perangkat yang terhubung
  var isScanning = false.obs; // Status scanning
  var connectingDevices = <String, bool>{}.obs; // Status koneksi perangkat

  // UUID ESP32
  final String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  final String characteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

  BluetoothCharacteristic? targetCharacteristic; // Karakteristik BLE

  @override
  void onInit() {
    super.onInit();
    FlutterBluePlus.setLogLevel(LogLevel.info, color: true);
  }

  // 🔍 Fungsi untuk scanning perangkat BLE
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

  // 🔌 Fungsi untuk menghubungkan ke perangkat
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      connectingDevices[device.remoteId.toString()] = true;
      connectingDevices.refresh();

      await device.connect().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Connection timed out");
        },
      );

      connectedDevice.value = device;
      print("Connected to device: $device");

      // Cari karakteristik setelah terhubung
      await discoverServices(device);

      if (targetCharacteristic == null) {
        print("No characteristic found!");
        Get.snackbar("Error", "No characteristic found",
            snackPosition: SnackPosition.BOTTOM);
      }

      Get.snackbar("Success", "Connected to device: ${device.remoteId}",
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print("Connection failed: $e");
      Get.snackbar("Error", "Failed to connect: ${device.remoteId}",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      connectingDevices[device.remoteId.toString()] = false;
      connectingDevices.refresh();
    }
  }

  // 🔍 Fungsi untuk menemukan layanan & karakteristik BLE
  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() ==
              characteristicUuid.toLowerCase()) {
            targetCharacteristic = characteristic;
            // print("Characteristic ditemukan: ${characteristic.uuid}");
            Get.snackbar("Info", "Characteristic found: ${characteristic.uuid}",
                snackPosition: SnackPosition.TOP);
            return;
          }
        }
      }
    }
  }

  // 🔴 Fungsi untuk memutuskan koneksi perangkat
  Future<void> disconnectDevice() async {
    if (connectedDevice.value != null) {
      await connectedDevice.value!.disconnect();
      connectedDevice.value = null;
      targetCharacteristic = null; // Hapus karakteristik
      Get.snackbar("Disconnect", "Disconnected from device",
          snackPosition: SnackPosition.TOP);
    }
  }

  // 📡 Fungsi untuk mengirim data ke ESP32
  Future<void> sendData(String data) async {
    if (targetCharacteristic == null) {
      Get.snackbar("Error", "No characteristic found. Please reconnect.",
          snackPosition: SnackPosition.BOTTOM);
      print("No characteristic found, cannot send data.");
      return;
    }

    List<int> bytes = utf8.encode(data);
    await targetCharacteristic!.write(bytes);
    print("Data terkirim: $data");
    Get.snackbar("Sent", "Data sent: $data", snackPosition: SnackPosition.TOP);
  }
}
