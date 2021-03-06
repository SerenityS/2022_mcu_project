# Include Libraries
import json
import socket
import threading
import time as time_lib

from arduino_controller import ArduinoController
from const import serverIp, serverPort
from sqlite3_helper import sqllite_helper

ard_ctl = ArduinoController()
db_helper = sqllite_helper()


# Alert Alarm
def alertAlarm():
    global latest_alarm

    now = time_lib.strftime("%H:%M", time_lib.localtime(time_lib.time()))
    for alarm in alarm_data:
        if alarm[1] == now and alarm[1] != latest_alarm and alarm[2] == "N":
            print("server>> alert Alarm!")
            latest_alarm = now
            ard_ctl.sendSerialCmd(15)
        elif alarm[1] == now and alarm[1] != latest_alarm and alarm[2] == "Y":
            print("server>> Sleep")
            latest_alarm = now
            ard_ctl.sendSerialCmd(16)
    threading.Timer(1, alertAlarm).start()


# Get Command from Serial Commnincation
def getSerialCmd():
    response = ard_ctl.getSerialCmd()
    if response != "":
        print(f"arduino>> {response}", end="")
        if response[0] == "S":
            _, start, end = response.split(",")
            db_helper.addStudyData(start, end.replace("\r\n", ""))
            print("server>> Add Study data")

    threading.Timer(1, getSerialCmd).start()


if __name__ == "__main__":
    # Define global variables
    global alarm_data
    global latest_alarm

    # For Alarm Function
    alarm_data = db_helper.getTime()
    latest_alarm = time_lib.strftime("%H:%M", time_lib.localtime(time_lib.time()))

    # Thread Control
    alertAlarm()
    getSerialCmd()

    # Socket Stream Open
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        server_socket.bind((serverIp, serverPort))
        server_socket.listen()

        def getSocketCmd(cmd):
            global alarm_data
            cmd_json = json.loads(cmd)
            cmd = cmd_json["cmd"]

            # Alarm Related Functions
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

            # Calander Related Function
            elif cmd == "get_study_data":
                study_data = db_helper.getStudyData()
                study_data_json = json.dumps(study_data)
                print(f"server>> send calendar data: {study_data_json}")
                client_socket.sendall(study_data_json.encode())

            # Remote Related Function
            elif cmd == "remote":
                index = cmd_json["index"]
                ard_ctl.sendSerialCmd(index)

        # Wait Socket Commnunication
        while True:
            client_socket, client_addr = server_socket.accept()
            # Decode Command
            cmd = client_socket.recv(1024).decode("utf-8")
            # Print command
            print(f"client>> {cmd}")
            # Run Command
            getSocketCmd(cmd)
            # Close Client Socket
            client_socket.close()
