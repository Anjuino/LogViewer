import QtQuick
import QtQuick.Controls
import "../components"

Page {
    Column {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "СТАНДАРТНАЯ"
            onClicked: Backend.log("Стандартная кнопка!")
        }

        CustomButton {
            text: "КАСТОМНАЯ"
            onClicked: Backend.log("Кастомная кнопка нажата!")
        }
    }
}