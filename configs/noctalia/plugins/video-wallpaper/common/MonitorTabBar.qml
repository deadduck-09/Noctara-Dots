import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.Widgets

NTabBar {
    id: root

    property bool enabled: true
    property bool monitorSpecific: false

    readonly property string activeMonitor: Quickshell.screens[currentIndex].name

    Layout.fillWidth: true
    distributeEvenly: true

    visible: Quickshell.screens.length > 1 && monitorSpecific

    Repeater {
        id: repeater
        model: Quickshell.screens

        NTabButton {
            id: button
            required property var modelData
            required property int index

            enabled: root.enabled
            text: modelData.name
            tabIndex: index
            checked: root.currentIndex === index
        }
    }
}
