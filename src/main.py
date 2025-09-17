import sys
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

from core.backend import Backend
import serial.tools.list_ports

def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("Backend", backend)

    #qml_path = Path(__file__).parent / "ui" / "main.qml"
    qml_path = Path(__file__).parent / "ui" / "test.qml"
    engine.load(QUrl.fromLocalFile(str(qml_path)))

    '''
    if not engine.rootObjects():
        print("❌ Ошибка загрузки QML!")
        sys.exit(-1)

    print("✅ Приложение запущено!")
    '''
    sys.exit(app.exec())


if __name__ == "__main__":
    main()