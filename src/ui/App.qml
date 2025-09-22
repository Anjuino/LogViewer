import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window


Window {
    id: root
    visible: true
    width: 1024
    height: 768
    maximumWidth: 1024
    maximumHeight: 768
    title: "LogViewer"
    color: "#f0f0f0"

    function update_tag_list(newTag) {
        // Проверяем есть ли уже такой тег
        for (var i = 0; i < tagListModel.count; i++) {
            if (tagListModel.get(i).text === newTag) {
                return // Уже есть, выходим
            }
        }

        // Добавляем новый тег
        statusArea.append("Появился новый тег: " + newTag + "\n")
        tagLabel.text = "Теги: (" + tagListModel.count + ")"
        tagListModel.append({text: newTag})
    }

    function print_data_from_com_port(message) {
        if (message) {
            var timestamp = new Date().toLocaleTimeString()
            logArea.append(message + "\n")
            logArea.cursorPosition = logArea.length    // Автопрокрутка вниз
        }
    }

    property alias connectButton: buttonConnection
    function set_status_com_port(message) {
        var timestamp = new Date().toLocaleTimeString()

        if (message == "True") {
            connectButton.text = "Отключиться"
            connectButton.background.color = "#ee0404"
            statusArea.append(timestamp + " Подключился" + "\n")
        }

        else if (message == "False") {
            connectButton.text = "Подключиться"
            connectButton.background.color = "#1db91b"
            statusArea.append(timestamp + " Отключился" + "\n")
        }

    }
    function log_app(message) {
        var timestamp = new Date().toLocaleTimeString()
        if (message) {
            statusArea.append(timestamp + " " + message + "\n")
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
                    spacing: 10

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

                    RowLayout {
                        id: connection
                        visible: false // Скрыто при старте

                        ColumnLayout {

                            Layout.alignment: Qt.AlignTop

                            CheckBox {
                                id: checkbox_file
                                enabled: true

                                text: "Сохранять логи в файл"
                                onCheckedChanged: {
                                    Backend.save_log_to_file(checked)
                                }
                            }

                            Button {
                                id: buttonConnection
                                property bool connected_to_com_port: false

                                text: "Подключиться"
                                width: 150 // Фиксированная ширина
                                height: 40 // Фиксированная высота

                                Layout.alignment: Qt.AlignTop

                                background: Rectangle {
                                    id: bgRect
                                    color: "#1db91b"
                                    radius: 2
                                    border.width: 2
                                    border.color: "black"
                                }

                                onClicked: {
                                    if (connected_to_com_port) {
                                        // Отключаемся
                                        Backend.disconnect_com_port()
                                        connected_to_com_port = false
                                        comboBox.enabled = true
                                        speedComboBox.enabled = true
                                        checkbox_file.enabled = true
                                        levelSettings.visible = false
                                        button_clear.visible = false
                                    } else {
                                        // Подключаемся
                                        var Port = comboBox.currentText
                                        var Speed = speedComboBox.currentText
                                        Backend.connect_com_port(Port, Speed)
                                        connected_to_com_port = true
                                        comboBox.enabled = false
                                        speedComboBox.enabled = false
                                        checkbox_file.enabled = false
                                        levelSettings.visible = true
                                        button_clear.visible = true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: "lightgray"
                        }

                        ColumnLayout {
                            id: levelSettings
                            visible: false

                            RowLayout {
                                Label {
                                    text: "Отображаемый уровень логирования: "
                                    Layout.preferredWidth: 210
                                }

                                ComboBox {
                                    id: levelComboBox
                                    Layout.preferredWidth: 150
                                    model: ["Все","Warning", "Error", "Info", "Debug", "Verbose"]
                                    currentIndex: 0

                                    onCurrentTextChanged: {
                                        if (currentText) {
                                            Backend.set_log_level(currentText)
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Label {
                                    id: tagLabel
                                    Layout.preferredWidth: 210
                                }

                                ComboBox {
                                    id: tagComboBox
                                    property bool block: false
                                    Layout.preferredWidth: 150
                                    model: ListModel {
                                        id: tagListModel
                                        ListElement { text: "Все" }
                                    }

                                    onCurrentTextChanged: {
                                        if (currentText&& !block) {
                                            Backend.set_current_tag(currentText)
                                        }
                                    }

                                    Component.onCompleted: {
                                        tagLabel.text = "Теги:"
                                    }
                                }
                            }

                            RowLayout {
                                visible: true
                                Layout.alignment: Qt.AlignTop
                                Button {
                                    id: button_clear

                                    text: "Очистить лог"
                                    width: 150 // Фиксированная ширина
                                    height: 40 // Фиксированная высота

                                    Layout.alignment: Qt.AlignTop

                                    onClicked: {
                                        log_app("Очистка логов")
                                        logArea.text = ""
                                        Backend.clear_log()
                                    }
                                }
                            }

                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 5

                    // Первое поле с рамкой
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.7
                        border.color: "#ccc"
                        border.width: 1
                        color: "transparent"

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 2

                            TextArea {
                                id: logArea
                                readOnly: true
                                textFormat: TextEdit.PlainText
                                font.pointSize: 9
                                font.family: "Consolas, Monaco, Courier New, monospace"
                                topPadding: 1
                                bottomPadding: 1
                            }
                        }
                    }

                    // Второе поле с рамкой - ТАК ЖЕ ОБЕРНУТЬ В Rectangle
                    Rectangle {
                        Layout.preferredWidth: parent.width * 0.3
                        Layout.preferredHeight: 150
                        Layout.alignment: Qt.AlignTop
                        border.color: "#ccc"  // РАМКА
                        border.width: 1       // ТОЛЩИНА
                        color: "transparent"  // ПРОЗРАЧНЫЙ ФОН

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 2  // ОТСТУП ОТ РАМКИ

                            TextArea {
                                id: statusArea
                                readOnly: true
                                textFormat: TextEdit.PlainText
                                font.pointSize: 9
                                font.family: "Consolas, Monaco, Courier New, monospace"
                                topPadding: 1
                                bottomPadding: 1
                            }
                        }
                    }
                }
            }
        }
    }
}