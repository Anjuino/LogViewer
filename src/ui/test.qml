import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    visible: true
    width: 800
    height: 600
    title: "Test Page - PySide6 + QML"
    color: "#f0f0f0"

    // Главный контейнер
    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            // Заголовок
            Label {
                text: "🛠️ Тестовая страница"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                color: "#333"
            }

            // Разделитель
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: "#ddd"
            }

            // Секция выпадающего списка
            GroupBox {
                title: "📋 Выпадающий список"
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width

                    ComboBox {
                        id: comboBox
                        Layout.fillWidth: true
                        model: Backend.get_combo_data()
                        onCurrentTextChanged: {
                            if (currentText) {
                                Backend.log("Выбран: " + currentText)
                            }
                        }
                    }

                    RowLayout {
                        TextField {
                            id: newItemInput
                            Layout.fillWidth: true
                            placeholderText: "Введите новый элемент..."
                            onAccepted: addButton.clicked()
                        }

                        Button {
                            id: addButton
                            text: "➕ Добавить"
                            onClicked: {
                                if (newItemInput.text) {
                                    Backend.add_item(newItemInput.text)
                                    newItemInput.clear()
                                }
                            }
                        }
                    }
                }
            }

            // Секция управления данными
            GroupBox {
                title: "⚙️ Управление данными"
                Layout.fillWidth: true

                GridLayout {
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10

                    Button {
                        text: "🎲 Случайные данные"
                        Layout.fillWidth: true
                        onClicked: Backend.generate_random_data()
                    }

                    Button {
                        text: "🗑️ Очистить всё"
                        Layout.fillWidth: true
                        onClicked: Backend.clear_data()
                    }

                    Button {
                        text: "🔄 Обновить список"
                        Layout.fillWidth: true
                        onClicked: comboBox.model = Backend.get_combo_data()
                    }

                    Button {
                        text: "❌ Удалить выбранный"
                        Layout.fillWidth: true
                        onClicked: {
                            if (comboBox.currentIndex >= 0) {
                                Backend.remove_item(comboBox.currentIndex)
                            }
                        }
                    }
                }
            }

            // Секция лога
            GroupBox {
                title: "📝 Лог действий"
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollView {
                    anchors.fill: parent
                    TextArea {
                        id: logArea
                        readOnly: true
                        placeholderText: "Здесь будут отображаться логи..."
                        textFormat: TextEdit.PlainText
                    }
                }
            }

            // Стандартная кнопка
            Button {
                text: "🚀 СТАНДАРТНАЯ КНОПКА"
                Layout.fillWidth: true
                height: 50
                font.bold: true
                onClicked: {
                    Backend.log("Стандартная кнопка нажата!")
                    Backend.get_com_ports()
                }

                background: Rectangle {
                    color: parent.down ? "#4CAF50" :
                           parent.hovered ? "#66BB6A" : "#81C784"
                    radius: 8
                }
            }
        }
    }

    // Соединения для обновления UI
    Connections {
        target: Backend

        function onDataUpdated() {
            comboBox.model = Backend.get_combo_data()
            Backend.log("Данные обновлены в UI")
        }
    }

    // Перехват всех логов для отображения в TextArea
    function appendToLog(message) {
        logArea.text += new Date().toLocaleTimeString() + " - " + message + "\n"
        // Автопрокрутка вниз
        logArea.cursorPosition = logArea.text.length
    }

    Component.onCompleted: {
        // Перенаправляем вывод в текстовое поле
        var originalLog = Backend.log
        Backend.log = function(message) {
            originalLog(message)
            appendToLog(message)
        }

        appendToLog("Приложение запущено!")
    }
}