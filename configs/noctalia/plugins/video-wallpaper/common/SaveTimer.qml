// A simple timer to save data without it causing binding loops
import QtQuick

import qs.Commons

Item {
    id: root

    required property var pluginApi

    property alias running: timer.running

    property string screenName: undefined

    function save(key: string, value: var) {
        if (typeof key !== "string") {
            Logger.e("video-wallpaper", "Saving with wrong type of key:", key);
            return;
        }

        internal.key = key;
        internal.value = value;
        timer.restart();
    }

    QtObject {
        id: internal

        property string key: ""
        property var value: null
    }

    Timer {
        id: timer
        interval: 30
        repeat: false
        running: false
        triggeredOnStart: false

        onTriggered: {
            if(internal.value === null || root.pluginApi == null) return;

            if (root.screenName === undefined)
                root.pluginApi.pluginSettings[internal.key] = internal.value;
            else {
                if (root.pluginApi?.pluginSettings?.[root.screenName] === undefined) {
                    root.pluginApi.pluginSettings[root.screenName] = {};
                }

                root.pluginApi.pluginSettings[root.screenName][internal.key] = internal.value;
            }

            root.pluginApi.saveSettings();
        }
    }
}
