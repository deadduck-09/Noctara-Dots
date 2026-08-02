import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.Widgets

NTabView {
    id: root

    required default property Component child

    Layout.fillWidth: true
    Layout.fillHeight: true

    Repeater {
        model: Quickshell.screens
        delegate: root.child
    }
}
