import QtQuick
import QtQuick.Controls

Page {
    Button {
        text: "Перейти к кнопкам"
        anchors.centerIn: parent
        onClicked: appWindow.navigateTo(appWindow.appPage)
    }
}