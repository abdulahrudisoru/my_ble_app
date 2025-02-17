import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BluetoothScreen(),
  ));
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  bool isScanning = false;

  void startScan() {
    if (isScanning) return;
    setState(() {
      isScanning = true;
      devices.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      FlutterBluePlus.stopScan();
      setState(() => isScanning = false);
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() => connectedDevice = device);
  }

  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() => connectedDevice = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: startScan,
          )
        ],
      ),
      body: Column(
        children: [
          if (connectedDevice != null)
            Container(
              color: Colors.green,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Connected to: ${connectedDevice!.name}"),
                  ElevatedButton(
                    onPressed: disconnectDevice,
                    child: const Text("Disconnect"),
                  )
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices[index].name.isNotEmpty
                      ? devices[index].name
                      : "Unknown Device"),
                  subtitle: Text(devices[index].id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => connectToDevice(devices[index]),
                    child: const Text("Connect"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
