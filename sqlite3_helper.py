import os
import sqlite3


class sqllite_helper:
    def __init__(self):
        self.conn = sqlite3.connect(os.getcwd() + "/mcu_server/db/alarm.db")
        self.cur = self.conn.cursor()

    def addTime(self, time):
        self.cur.execute(f"INSERT INTO alarm (time) VALUES ('{time}')")
        self.conn.commit()

    def getTime(self):
        self.cur.execute("SELECT * FROM alarm")
        rows = self.cur.fetchall()

        alarm_data = []

        for row in rows:
            alarm_data.append([row[0], row[1]])

        return alarm_data

    def setTime(self, index, time):
        self.cur.execute(f"UPDATE alarm SET time = '{time}' WHERE no = '{index}'")
        self.conn.commit()

    def removeTime(self, index):
        self.cur.execute(f"DELETE FROM alarm WHERE no = '{index}'")
        self.conn.commit()
