import QtQuick
import QtQuick.Controls

Page {
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
        }
    }
}