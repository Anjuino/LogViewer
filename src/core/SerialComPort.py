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
    new_tag = Signal(str)

    def __init__(self):
        super().__init__()
        self.data_queue = queue.Queue()     # Очередь для сырых данных
        self.running = True
        self.log_level = 'A'                # По умолчанию все логи выводятся

        self.tags_list = []
        self.current_tag = 'Все'

    def set_tag(self, tag):
        self.current_tag = tag

    def set_log_level(self, log_level):
        self.log_level = log_level

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

        # Ищем тег - код уровня всегда есть, берем слово после него
        current_code = None
        for code in level_map.keys():
            if filtered_data.startswith(f"{code} "):
                current_code = code
                break

        # Извлекаем тег (слово после кода уровня)
        without_code = filtered_data[len(current_code):].strip()
        tag = without_code.split(' ', 1)[0]

        # Убираем двоеточие если есть
        if tag.endswith(':'):
            tag = tag[:-1]

        # Добавляем тег в список если его нет
        if tag not in self.tags_list:
            self.tags_list.append(tag)
            self.new_tag.emit(tag)

        # ПРОВЕРЯЕМ ТЕГ ФИЛЬТРА
        if self.current_tag != 'Все' and self.current_tag != tag:
            return None  # Пропускаем если тег не совпадает

        # Продолжаем обработку как раньше
        if current_code:
            if self.log_level == 'A':
                filtered_data = filtered_data.replace(f"{current_code} ", f"{level_map[current_code]} ", 1)
            elif current_code == self.log_level:
                filtered_data = filtered_data.replace(f"{current_code} ", f"{level_map[current_code]} ", 1)
            else:
                return None

        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
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
