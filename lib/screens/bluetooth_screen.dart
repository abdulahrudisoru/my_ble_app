import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';

class BluetoothScreen extends StatelessWidget {
  final BluetoothController controller = Get.put(BluetoothController());
  final TextEditingController dataController =
      TextEditingController(); // Controller untuk input data

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

          // Menampilkan input dan tombol kirim jika perangkat terhubung
          Obx(() {
            if (controller.connectedDevice.value != null) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextField(
                      controller: dataController,
                      decoration: InputDecoration(
                        labelText: "Enter Data to Send",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (dataController.text.isNotEmpty) {
                          controller.sendData(dataController.text);
                        } else {
                          Get.snackbar("Error", "Input cannot be empty",
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      child: const Text("Send Data"),
                    ),
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
                        title: Text(device.platformName.isNotEmpty
                            ? device.platformName
                            : "Unknown Device"),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: Obx(() {
                          bool isLoading = controller.connectingDevices[
                                  device.remoteId.toString()] ??
                              false;

                          return isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () =>
                                      controller.connectToDevice(device),
                                  child: const Text("Connect"),
                                );
                        }),
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }
}
