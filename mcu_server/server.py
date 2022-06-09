import json
import socket
import threading
import time as time_lib

from arduino_controller import ArduinoController
from const import serverIp, serverPort
from sqlite3_helper import sqllite_helper

ard_ctl = ArduinoController()
db_helper = sqllite_helper()


def alertAlarm():
    global latest_alarm

    now = time_lib.strftime("%H:%M", time_lib.localtime(time_lib.time()))
    for alarm in alarm_data:
        if alarm[1] == now and alarm[1] != latest_alarm:
            print("server>> alert Alarm!")
            latest_alarm = now
    threading.Timer(1, alertAlarm).start()


if __name__ == "__main__":
    global alarm_data
    global latest_alarm

    alarm_data = db_helper.getTime()
    latest_alarm = time_lib.strftime("%H:%M", time_lib.localtime(time_lib.time()))

    alertAlarm()

    # Socket Stream Open
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        server_socket.bind((serverIp, serverPort))
        server_socket.listen()

        def getCmd(cmd):
            global alarm_data

            cmd_json = json.loads(cmd)
            cmd = cmd_json["cmd"]
            if cmd == "add_alarm":
                time = cmd_json["time"]
                db_helper.addTime(time)
                print(f"server>> add alarm: {time}")
            elif cmd == "get_alarm":
                alarm_data = db_helper.getTime()
                alarm_data_json = json.dumps(alarm_data)
                print(
                    f"server>> send alarm data & update local alarm data: {alarm_data_json}"
                )
                client_socket.sendall(alarm_data_json.encode())
            elif cmd == "set_alarm":
                index = cmd_json["index"]
                time = cmd_json["time"]
                db_helper.setTime(index, time)
                print(f"server>> set alarm {index}: {time}")
            elif cmd == "remove_alarm":
                index = cmd_json["index"]
                db_helper.removeTime(index)
                print(f"server>> remove alarm: {index}")

            elif cmd == "get_study_data":
                study_data = db_helper.getStudyData()
                study_data_json = json.dumps(study_data)
                print(f"server>> send calendar data: {study_data_json}")
                client_socket.sendall(study_data_json.encode())

            elif cmd == "remote":
                index = cmd_json["index"]
                ard_ctl.sendRemoteCmd(index)

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
