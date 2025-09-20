from PySide6.QtCore import QObject, Slot, QThread, Signal
import serial
import time
from datetime import datetime
import queue
import re

level_map = {
    'W': 'WARNING',
    'E': 'ERROR',
    'I': 'INFO',
    'D': 'DEBUG',
    'V': 'VERBOSE'
}

# Поток обработки данных
class ParseData(QThread):
    data_ready = Signal(str)

    def __init__(self):
        super().__init__()
        self.data_queue = queue.Queue()     # Очередь для сырых данных
        self.running = True

    # Добавить полученные данные в очередь на обработку
    def add_raw_data(self, raw_data):
        self.data_queue.put(raw_data)

    def run(self):
        while self.running:
            try:
                raw_data = self.data_queue.get(timeout=0.1)   # Вытаскиваю из очереди сырые данные

                data = self.handler_data(raw_data)

                self.data_ready.emit(data)

            except queue.Empty:
                if not self.running:  # Выходим если остановили
                    break

                continue

    def handler_data(self, raw_data):
        # Обрабатываем данные
        filtered_data = re.sub(r'\(\d+\)', '', raw_data, count=1)
        filtered_data = re.sub(r'\s+', ' ', filtered_data).strip()

        # Заменяем уровень логирования если он есть в начале строки
        for code, level in level_map.items():
            if filtered_data.startswith(f"{code} "):
                filtered_data = filtered_data.replace(f"{code} ", f"{level}: ", 1)
                break

        # Добавляем время
        current_time = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")

        return f"{current_time} {filtered_data}"

# Поток получения даннх с com порта
class Serial(QThread):
    raw_data_ready = Signal(str)  # Сигнал с сырыми данными (в обработку)
    status = Signal(str)          # Сигнал статуса (в GUI)

    def __init__(self, port = 0, speed = 0):
        super().__init__()
        self.port = port
        self.speed = speed
        self.running = True

    def run(self):
        try:
            com_port = serial.Serial(self.port, self.speed, timeout=0)

            #self.status.emit(f"Подключено к {self.port}")

            self.status.emit(str(com_port.is_open))

            while self.running:
                if com_port.in_waiting > 0:
                    line = com_port.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        self.raw_data_ready.emit(line)  # Отправляем сырые данные в обработчик

                time.sleep(0.01)

                if not self.running:  # Выходим если остановили
                    break

            com_port.close()
            self.status.emit(str(com_port.is_open))

        except Exception as e:
            self.status.emit(f"Ошибка {self.port}: {str(e)}")
