import os
import sqlite3


class sqllite_helper:
    # Initalize SQLite3
    def __init__(self):
        # Connect without thread check
        self.conn = sqlite3.connect(
            os.getcwd() + "/mcu_server/db/mcu.db", check_same_thread=False
        )
        self.cur = self.conn.cursor()

    def addStudyData(self, start, end):
        self.cur.execute(
            f"INSERT INTO calendar (start_time, end_time) VALUES ('{start}', '{end}')"
        )
        self.conn.commit()

    def getStudyData(self):
        self.cur.execute("SELECT * FROM calendar")
        rows = self.cur.fetchall()

        study_data = []
        for row in rows:
            study_data.append(row)
        return study_data

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
