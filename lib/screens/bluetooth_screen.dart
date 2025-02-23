import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';

class BluetoothScreen extends StatelessWidget {
  final BluetoothController controller = Get.put(BluetoothController());

  BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Scanner"),
        actions: [
          Obx(() => IconButton(
                icon: controller.isScanning.value
                    ? const Icon(Icons.stop)
                    : const Icon(Icons.search),
                onPressed: controller.startScan,
              ))
        ],
      ),
      body: Column(
        children: [
          // Menampilkan perangkat yang terhubung
          Obx(() {
            if (controller.connectedDevice.value != null) {
              return Container(
                color: Colors.green,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Connected to: ${controller.connectedDevice.value!.platformName}"),
                    ElevatedButton(
                      onPressed: controller.disconnectDevice,
                      child: const Text("Disconnect"),
                    )
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          }),

          // List perangkat yang ditemukan
          Expanded(
            child: Obx(() => controller.devices.isEmpty
                ? const Center(child: Text("No devices found"))
                : ListView.builder(
                    itemCount: controller.devices.length,
                    itemBuilder: (context, index) {
                      final device = controller.devices[index];
                      return ListTile(
                        title: Text(device.advName.isNotEmpty
                            ? device.advName
                            : "Unknown Device"),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: ElevatedButton(
                          onPressed: () => controller.connectToDevice(device),
                          child: const Text("Connect"),
                        ),
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }
}
