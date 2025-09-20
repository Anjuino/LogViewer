from PySide6.QtCore import QObject, Slot, Signal
import serial.tools.list_ports
from core.SerialComPort import Serial, ParseData


#Поток интерфейса
class Backend(QObject):

    def __init__(self, qml_engine):
        super().__init__()
        self.qml_engine = qml_engine  # Ссылка на QML engine

        self.parser = ParseData()     # Объект обработчика данных
        self.serial_com = Serial()    # Объект com порта

        self.parser.data_ready.connect(self.data_completed)     # Связываю обработчик данных в парсере с интерфейсом

    # Вызов функции из qml
    def call_qml_function(self, function_name, *args):
        root_object = self.qml_engine.rootObjects()[0]
        if hasattr(root_object, function_name):
            getattr(root_object, function_name)(*args)

    # Остановить все потоки
    def stop_all_threads(self):
        if hasattr(self.parser, 'running'):
            self.parser.running = False
            self.parser.wait()

        if hasattr(self.serial_com, 'running'):
            self.serial_com.running = False

        print("Все потоки остановлены")

    def status(self, data):
        #print(data)
        self.call_qml_function("set_status_com_port", data)

    def data_completed(self, data):
        #print(data)
        self.call_qml_function("print_data_from_com_port", f"{data}")


    # Получить список COM портов
    @Slot(result=list)
    def get_com_ports(self):
        ports = serial.tools.list_ports.comports()
        return [port.device for port in ports]

    @Slot(str, str)
    def connect_com_port(self, port, speed):

        self.parser.start()            # Запуск обработки данных

        thread = Serial(port, speed)   # Поток для получения данных с COM порта

        # Подключаю сигналы:
        thread.raw_data_ready.connect(self.parser.add_raw_data)   # Сырые данные в обработчик

        thread.status.connect(self.status)                        # Статус потока

        thread.start()            # Запуск потока COM порта

        self.serial_com = thread  # Сохраняю указатель на поток, чтобы не было удаления сборкой мусора

    @Slot()
    def disconnect_com_port(self):
        self.stop_all_threads()

    # Логирование с qml
    @Slot(str)
    def log(self, message):
        print(f"Front: {message}")

