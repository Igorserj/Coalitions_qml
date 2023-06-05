import QtQuick 2.15
import QtQuick.Controls 2.15

ScrollView {
    property alias tableLoader: tableLoader
    property alias tableComponent: tableComponent
    property alias allParticipants: allParticipants
    //    property alias noteRect: noteRect
    property alias content: content
    property var namesCache: []
    property var particCache: []
    anchors.fill: parent
    anchors.margins: 0.01 * window.width

    Column {
        id: content
        x: (window.width - width) / 2
        spacing: 0.05 * window.height
        Row {
            spacing: 0.02 * window.width
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                color: "transparent"
                width: accept.width * 1.5
                height: accept.height
                Text {
                    font.family: "Comfortaa"
                    anchors.fill: parent
                    anchors.margins: window.width * 0.01
                    font.pointSize: 100
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: "Кількість партій"
                }
            }
            TextField {
                id: nParties
                font.family: "Comfortaa"
                text: "2"
                validator: RegExpValidator {
                    regExp: /[0-9]+/
                }
                Component.onCompleted: confirm()
                onAccepted: confirm()
            }
            Button {
                id: accept
                font.family: "Comfortaa"
                text: "Підтвердити"
                onClicked: confirm()
            }
        }
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            Row {
                spacing: 0.02 * window.width
                Repeater {
                    model: parties.model
                           > 0 ? ["№ партії", "Назва партії", "Кількість учасників"] : 0
                    Rectangle {
                        color: "transparent"
                        width: parties.itemAt(0).children[index].width
                        height: parties.itemAt(0).children[index].height
                        Text {
                            font.family: "Comfortaa"
                            anchors.fill: parent
                            text: modelData
                            font.pointSize: 100
                            fontSizeMode: Text.Fit
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            Repeater {
                id: parties
                Row {
                    spacing: 0.02 * window.width
                    Rectangle {
                        id: partyRect
                        color: "transparent"
                        width: partyName.width / 2
                        height: partyName.height
                        Text {
                            font.family: "Comfortaa"
                            anchors.fill: parent
                            anchors.margins: window.width * 0.01
                            font.pointSize: 100
                            fontSizeMode: Text.Fit
                            horizontalAlignment: Text.AlignHCenter
                            text: index + 1
                        }
                    }
                    TextField {
                        id: partyName
                        font.family: "Comfortaa"
                        onTextEdited: namesCache[index] = text
                        Component.onCompleted: !!namesCache[index] ? text = namesCache[index] : {}
                    }
                    TextField {
                        id: partyN
                        font.family: "Comfortaa"
                        onTextEdited: particCache[index] = text
                        validator: RegExpValidator {
                            regExp: /[0-9]+/
                        }
                        Component.onCompleted: !!particCache[index] ? text = particCache[index] : {}
                    }
                }
            }
        }
        Row {
            spacing: 0.02 * window.width
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id: progressBarShow
                text: "Відображати прогрес"
                ToolTip.visible: down
                ToolTip.text: "Відображення прогресу може сповільнити швидкість"
                visible: calcButton.visible
                onHoveredChanged: hovered ? ToolTip.show(
                                                ToolTip.text) : ToolTip.hide()
                //                 progressBarShow.hovered
                state: "default"
                onClicked: state === "default" ? state = "alternative" : state = "default"
                states: [
                    State {
                        name: "default"
                        PropertyChanges {
                            target: progressBarShow
                            text: "Відображати прогрес"
                        }
                    },
                    State {
                        name: "alternative"
                        PropertyChanges {
                            target: progressBarShow
                            text: "Приховати прогрес"
                        }
                    }
                ]
            }
            Button {
                id: calcButton
                text: "Розрахувати"
                font.family: "Comfortaa"
                visible: false
                onClicked: {
                    calculations()
                }
            }
            Rectangle {
                color: "transparent"
                height: calcButton.height
                width: allParticipants.text === "" ? 0 : calcButton.width
                Text {
                    id: allParticipants
                    font.family: "Comfortaa"
                    anchors.fill: parent
                    anchors.margins: 2
                    font.pointSize: 100
                    fontSizeMode: Text.Fit
                    //                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        BusyIndicator {
            visible: progressBarShow.state
                     === "default" ? tableLoader.status === Loader.Loading : false
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ProgressBar {
            id: pbar
            property int progress: 0
            value: progress / ((scripts.coalitions.length + 2) * (scripts.partyNames.length + 2))
            visible: progressBarShow.state
                     === "default" ? false : tableLoader.status === Loader.Loading
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Loader {
            id: tableLoader
            asynchronous: true
            visible: status === Loader.Ready
            //            sourceComponent: tableComponent
            x: width > window.width ? -content.x : 0
            anchors.horizontalCenter: width > window.width ? undefined : parent.horizontalCenter
        }
        Component {
            id: tableComponent
            Row {
                id: row
                Repeater {
                    id: coalitions
                    model: scripts.coalitions
                    Column {
                        id: col
                        property int colIndex: index
                        Repeater {
                            id: rep
                            model: scripts.partyNames.length + 2
                            onItemAdded: progressBarShow.state === "default" ? {} : pbar.progress++
                            Rectangle {
                                color: "transparent"
                                width: colIndex === 0 ? height * 2.5 : height
                                height: 70
                                TextField {
                                    id: boxText
                                    font.family: "Comfortaa"
                                    anchors.fill: parent
                                    wrapMode: Text.WordWrap
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    readOnly: true
                                    color: coloring()
                                    text: textPopulation()
                                    function textPopulation() {
                                        if (colIndex === 0 && index === 0) {
                                            return "Коаліція / Політична сила"
                                        } else if (colIndex === 0
                                                   && index !== rep.model - 1) {
                                            return scripts.partyNames[index - 1]
                                        } else if (index === rep.model - 1
                                                   && colIndex === 0) {
                                            return "Суми голосів"
                                        } else if (index === rep.model - 1
                                                   && colIndex !== 0) {
                                            return scripts.sums[colIndex - 1]
                                        } else if (index === 0
                                                   && colIndex < coalitions.model.length - 1) {
                                            return ("s" + colIndex)
                                        } else if (index === 0
                                                   && colIndex === coalitions.model.length - 1) {
                                            return "Ключ. коаліцій"
                                        } else if ((index > 0
                                                    && index !== rep.model - 1)
                                                   && colIndex === coalitions.model.length - 1) {
                                            return scripts.winnersQCrit[index - 1]
                                        } else if (coalitions.model[col.colIndex].includes(
                                                       scripts.partyNames[index - 1])) {
                                            return "+"
                                        } else if (colIndex === coalitions.model.length - 1
                                                   && index === rep.model - 1)
                                            return ""
                                        else
                                            return ""
                                    }
                                    function coloring() {
                                        if (colIndex === 0 || index === 0
                                                || colIndex === coalitions.model.length - 1
                                                || index === rep.model - 1) {
                                            return "black"
                                        } else if (scripts.winnersQ[colIndex
                                                                    - 1][index - 1] === 1) {
                                            return "red"
                                        } else
                                            return "black"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            color: "transparent"
            id: noteRect
            x: tableLoader.x
            height: accept.height
            visible: tableLoader.status === Loader.Ready
            width: accept.width
            Text {
                id: note
                font.family: "Comfortaa"
                color: "red"
                text: "+ ключова партія в коаліції"
                anchors.fill: parent
                font.pointSize: 100
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    function confirm() {
        parties.model = nParties.text
        calcButton.visible = true
        tableLoader.sourceComponent = undefined
        allParticipants.text = ""
    }

    function calculations() {
        tableLoader.sourceComponent = undefined
        scripts.partyNames = []
        scripts.participants = []
        for (var i = 0; i < parties.model; i++) {
            scripts.partyNames.push(parties.itemAt(i).children[1].text)
            scripts.participants.push(parties.itemAt(i).children[2].text)
        }
        scripts.majority.sendMessage({
                                         "names": scripts.partyNames,
                                         "p": scripts.participants
                                     })
    }
}
