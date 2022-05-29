import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mcu/const/const.dart';

Future<String> sendSocketData(cmd) async {
  Socket socket = await Socket.connect(ipAddress, port);

  String rst = "";
  socket.write(cmd);
  var rsts = socket.listen(
    (Uint8List data) async {
      rst = String.fromCharCodes(data);
    },
    onError: (error) {
      socket.destroy();
    },
    onDone: () {
      socket.destroy();
    },
  );
  socket.close();
  await rsts.asFuture<void>();
  return rst;
}
