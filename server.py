import json
import socket

from const import serverIp, serverPort
from sqlite3_helper import sqllite_helper

db_helper = sqllite_helper()

# Socket Stream Open
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
    server_socket.bind((serverIp, serverPort))
    server_socket.listen()

    def getCmd(cmd):
        cmd_json = json.loads(cmd)
        cmd = cmd_json["cmd"]
        if cmd == "add_alarm":
            time = cmd_json["time"]
            db_helper.addTime(time)
            print(f"server>> add alarm: {time}")
        if cmd == "get_alarm":
            alarm_data = json.dumps(db_helper.getTime())
            print("server>> send alarm data: " + alarm_data)
            client_socket.sendall(alarm_data.encode())
        if cmd == "set_alarm":
            index = cmd_json["index"]
            time = cmd_json["time"]
            db_helper.setTime(index, time)
            print(f"server>> set alarm {index}: {time}")
        if cmd == "remove_alarm":
            index = cmd_json["index"]
            db_helper.removeTime(index)
            print(f"server>> remove alarm: {index}")

    # 소켓 통신 대기
    while True:
        client_socket, client_addr = server_socket.accept()
        # 클라이언트로부터 전달 받은 명령어 해독
        cmd = client_socket.recv(1024).decode("utf-8")
        # 명령어 출력
        print(f"client>> {cmd}")
        # 명령어에 따른 명령 처리
        getCmd(cmd)
        # 클라이언트 소켓 닫음
        client_socket.close()
