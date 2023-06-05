import QtQuick 2.15

Item {
    property alias majority: majority
    property var participants: []
    property var partyNames: []
    property var winnersQ: []
    property var winnersQCrit: []
    property var sums: []
    property var coalitions: []
    WorkerScript {
        id: majority
        source: "Majority.mjs"
        onMessage: {
            winnersQ = messageObject.winnersQ
            winnersQCrit = messageObject.winnersQCrit
            coalitions = messageObject.coalitions
            console.log(winnersQCrit)
            ui.tableLoader.sourceComponent = ui.tableComponent
            sums = messageObject.sums
            ui.allParticipants.text = "Сума: " + messageObject.sum
                    + ". Більшість: " + messageObject.majority
        }
    }
}
