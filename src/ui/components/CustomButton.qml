import QtQuick
import QtQuick.Controls

Button {
    property alias textColor: buttonText.color
    property alias buttonColor: backgroundRect.color

    background: Rectangle {
        id: backgroundRect
        color: "#FF5722"
        radius: 10
        border.width: 2
        border.color: "#E64A19"
    }

    contentItem: Text {
        id: buttonText
        text: parent.text
        color: "white"
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Анимация при наведении - ТОЛЬКО ДЛЯ ВНЕШНЕГО ВИДА
    onHoveredChanged: {
        if (hovered) {
            backgroundRect.color = "#E64A19"
        } else {
            backgroundRect.color = "#FF5722"
        }
    }

    onPressedChanged: {
        if (pressed) {
            backgroundRect.color = "#D32F2F"
        } else {
            backgroundRect.color = hovered ? "#E64A19" : "#FF5722"
        }
    }
}