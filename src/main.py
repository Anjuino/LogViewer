import sys
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

from core.backend import Backend

def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    backend = Backend(engine)
    engine.rootContext().setContextProperty("Backend", backend)

    qml_path = Path(__file__).parent / "ui" / "App.qml"
    engine.load(QUrl.fromLocalFile(str(qml_path)))

    def cleanup():
        backend.stop_all_threads()  # Останавливаем все потоки
        print("Закрытие приложения")

    app.aboutToQuit.connect(cleanup)  # Подключаем очистку к сигналу завершения
    sys.exit(app.exec())


if __name__ == "__main__":
    main()