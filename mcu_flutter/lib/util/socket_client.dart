import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

Future<String> addAlarm(time) async {
  Socket socket = await Socket.connect("127.0.0.1", 8765);

  String rst = "";
  socket.write('{"cmd": "add_alarm", "time": "$time"}');
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

Future<String> getAlarm() async {
  Socket socket = await Socket.connect("127.0.0.1", 8765);

  String rst = "";
  socket.write('{"cmd": "get_alarm"}');
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

Future<String> setAlarm(index, time) async {
  Socket socket = await Socket.connect("127.0.0.1", 8765);

  String rst = "";
  socket.write('{"cmd": "set_alarm", "index": $index, "time": "$time"}');
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

Future<String> removeAlarm(index) async {
  Socket socket = await Socket.connect("127.0.0.1", 8765);

  String rst = "";
  socket.write('{"cmd": "remove_alarm", "index": $index}');
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

Future<String> getStudyData() async {
  Socket socket = await Socket.connect("1.253.35.224", 8765);

  String rst = "";
  socket.write('{"cmd": "get_study_data"}');
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
