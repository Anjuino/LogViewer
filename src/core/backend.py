from PySide6.QtCore import QObject, Slot, Signal
import serial.tools.list_ports
import random


class Backend(QObject):
    def __init__(self):
        super().__init__()
        self._combo_data = ["Python", "QML", "PySide6", "JavaScript", "C++"]

    @Slot(result=list)
    def get_com_ports(self):
        """Получить список доступных COM-портов"""
        ports = serial.tools.list_ports.comports()

        print("Доступные COM-порты:")
        for port in ports:
            print(f"Порт: {port.device}")
            print(f"Описание: {port.description}")
            print(f"Производитель: {port.manufacturer}")

        return ports


    # Сигнал для обновления UI
    dataUpdated = Signal()

    @Slot(str)
    def log(self, message):
        print(f"LOG: {message}")

    # Метод для получения данных комбо-бокса
    @Slot(result=list)
    def get_combo_data(self):
        return self._combo_data

    # Добавление нового элемента
    @Slot(str)
    def add_item(self, new_item):
        if new_item and new_item not in self._combo_data:
            self._combo_data.append(new_item)
            self.dataUpdated.emit()
            self.log(f"Добавлен элемент: {new_item}")

    # Удаление элемента по индексу
    @Slot(int)
    def remove_item(self, index):
        if 0 <= index < len(self._combo_data):
            removed_item = self._combo_data.pop(index)
            self.dataUpdated.emit()
            self.log(f"Удален элемент: {removed_item}")

    # Генерация случайных данных
    @Slot()
    def generate_random_data(self):
        random_items = ["Item_" + str(random.randint(1, 100)) for _ in range(5)]
        self._combo_data.extend(random_items)
        self.dataUpdated.emit()
        self.log("Сгенерированы случайные данные")

    # Очистка всех данных
    @Slot()
    def clear_data(self):
        self._combo_data.clear()
        self.dataUpdated.emit()
        self.log("Данные очищены")