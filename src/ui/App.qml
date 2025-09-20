import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    visible: true
    width: 800
    height: 600
    title: "LogViewer"
    color: "#f0f0f0"

    function print_data_from_com_port(message) {
        var timestamp = new Date().toLocaleTimeString()
        logArea.append(message + "\n")

        logArea.cursorPosition = logArea.length    // Автопрокрутка вниз
    }

    property alias connectButton: buttonConnection
    function set_status_com_port(message) {
        if (message == "True") {
            connectButton.text = "Отключиться"
            logArea.append("Подключился" + "\n")
        }
        else {
            connectButton.text = "Подключиться"
            logArea.append("Отключился" + "\n")
        }
    }

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
                text: "Просмотр логов"
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

            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width

                    // Заголовок для ComboBox
                    Label {
                        text: "Выбрать COM порт"
                        font.bold: true
                    }

                    ComboBox {
                        id: comboBox
                        Layout.fillWidth: true
                        model: Backend.get_com_ports()
                        currentIndex: -1
                        Component.onCompleted: {
                            enabled = count > 0
                        }

                        onCurrentTextChanged: {
                            if (currentText) {
                                //Backend.log("Выбран: " + currentText)
                                speedSelection.visible = true
                            } else {
                                // Скрываем если порт не выбран
                                speedSelection.visible = false
                            }
                        }
                    }

                    ColumnLayout {
                        id: speedSelection
                        visible: false // Скрыто при старте
                        width: parent.width

                        Label {
                            text: "Выбрать скорость"
                            font.bold: true
                        }

                        ComboBox {
                            id: speedComboBox
                            Layout.fillWidth: true
                            model: [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600]
                            currentIndex: -1

                            onCurrentTextChanged: {
                                if (currentText) {
                                    connection.visible = true
                                    //Backend.log("Выбрана скорость: " + currentText)
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        id: connection
                        visible: false // Скрыто при старте
                        width: parent.width

                        Button {
                            id: buttonConnection

                            property bool connected_to_com_port: false

                            text: "Подключиться"
                            Layout.fillWidth: true
                            onClicked: {
                                if (connected_to_com_port) {
                                    // Отключаемся
                                    Backend.disconnect_com_port()
                                    connected_to_com_port = false
                                    comboBox.enabled = true
                                    speedComboBox.enabled = true
                                } else {
                                    // Подключаемся
                                    var Port = comboBox.currentText
                                    var Speed = speedComboBox.currentText
                                    Backend.connect_com_port(Port, Speed)
                                    connected_to_com_port = true
                                    comboBox.enabled = false
                                    speedComboBox.enabled = false
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollView {
                    anchors.fill: parent
                    TextArea {
                        id: logArea
                        readOnly: true
                        placeholderText: "Здесь будут отображаться логи после подключения"
                        textFormat: TextEdit.PlainText
                    }
                }
            }
        }
    }

}