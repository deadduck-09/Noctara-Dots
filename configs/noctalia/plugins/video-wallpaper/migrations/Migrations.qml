import QtQuick

Item {
    id: root
    required property var pluginApi


    /***************************
    * MIGRATION FUNCTIONALITY
    ***************************/
    Loader {
        active: status === Loader.Ready && !item.migrationDone
        sourceComponent: migration200
    }


    Component {
        id: migration200
        Migration200 {
            pluginApi: root.pluginApi
        }
    }
}
