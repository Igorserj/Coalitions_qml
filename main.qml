import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: window
    property alias comfortaa: comfortaa
    width: 640
    height: 480
    visible: true
    title: qsTr("Коаліції")

    UserInterface {
        id: ui
    }
    Scripts {
        id: scripts
    }

    FontLoader {
        id: comfortaa
        name: "Comfortaa"
        source: "static/Comfortaa-Medium.ttf"
    }
}
