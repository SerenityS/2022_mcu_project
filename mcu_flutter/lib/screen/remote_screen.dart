import 'package:flutter/material.dart';
import 'package:mcu/util/socket_client.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({Key? key}) : super(key: key);

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final elements = [
    const Icon(Icons.fast_rewind, color: Colors.white, size: 40),
    const Icon(Icons.fast_forward, color: Colors.white, size: 40),
    const Icon(Icons.play_arrow, color: Colors.white, size: 40),
    const Icon(Icons.remove, color: Colors.white, size: 40),
    const Icon(Icons.add, color: Colors.white, size: 40),
    const Icon(Icons.pause, color: Colors.white, size: 40),
    for (int i = 1; i < 9; i++)
      Text(
        i.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
    const Icon(Icons.power_settings_new, color: Colors.white, size: 40)
  ];

  final bgColor = [
    Colors.cyan,
    Colors.cyan,
    Colors.green,
    Colors.blue,
    Colors.blue,
    Colors.green,
    for (int i = 1; i < 9; i++) const Color.fromARGB(75, 0, 0, 0),
    Colors.red
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1 / 1.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return ElevatedButton(
              onPressed: () {
                sendSocketData('{"cmd": "remote", "index": $index}');
              },
              style: ElevatedButton.styleFrom(
                primary: bgColor[index],
                shape: const CircleBorder(),
              ),
              child: elements[index],
            );
          },
        ),
      ),
    );
  }
}
