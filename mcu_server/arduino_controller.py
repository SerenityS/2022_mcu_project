import datetime
import re
import sys
import time

import serial


class ArduinoController:
    def __init__(self):
        try:
            self.ser = serial.Serial("COM21", 9600, timeout=1)
            time.sleep(1)
        except:
            print("Not Initialized")
            sys.exit(0)

        if self.ser.readable():
            print(self.ser.readline().decode())

        self.setDateTime()

    def __del__(self):
        self.ser.close()

    def setDateTime(self):
        now = datetime.datetime.now()
        dt = f"1,{now.year},{now.month},{now.day},{now.hour},{now.minute},{now.second}"
        self.ser.write(bytes(dt, "utf-8"))
        print(f"server>> Initialize RTC Time: {now}")

    def sendRemoteCmd(self, index):
        cmd = f"{index + 2}"
        self.ser.write(bytes(cmd, "utf-8"))
        print(f"server>> Send Remote Command")

    def getMessage(self):
        if self.ser.readable():
            return self.ser.readline().decode()