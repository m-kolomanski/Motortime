import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Item {
    id: cfg
    implicitHeight: col.implicitHeight

    // Plasma reads these from main.xml defaults and saves them on Apply
    property bool   cfg_F1Enabled:   true
    property string cfg_F1Color:     "#E8002D"
    property bool   cfg_F2Enabled:   true
    property string cfg_F2Color:     "#FF6B35"
    property bool   cfg_F3Enabled:   true
    property string cfg_F3Color:     "#FFD166"
    property bool   cfg_WECEnabled:  true
    property string cfg_WECColor:    "#00B4D8"
    property bool   cfg_IMSAEnabled: true
    property string cfg_IMSAColor:   "#06D6A0"
    property bool   cfg_NLSEnabled:  true
    property string cfg_NLSColor:    "#A663CC"
    property bool   cfg_GTWCEnabled: true
    property string cfg_GTWCColor:   "#F4A261"
    property bool   cfg_WRCEnabled:  true
    property string cfg_WRCColor:    "#EF476F"

    readonly property var seriesList: [
        { key: "F1",   name: "Formula 1"                   },
        { key: "F2",   name: "Formula 2"                   },
        { key: "F3",   name: "Formula 3"                   },
        { key: "WEC",  name: "World Endurance Championship" },
        { key: "IMSA", name: "IMSA SportsCar Championship" },
        { key: "NLS",  name: "Nürburgring Langstrecken"    },
        { key: "GTWC", name: "GT World Challenge"          },
        { key: "WRC",  name: "World Rally Championship"    }
    ]

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Repeater {
                model: cfg.seriesList
                delegate: RowLayout {
                    spacing: 8
                    Kirigami.FormData.label: modelData.name

                    QQC2.CheckBox {
                        id: enabledBox
                        text: "Show"
                        checked: cfg["cfg_" + modelData.key + "Enabled"]
                        onCheckedChanged: cfg["cfg_" + modelData.key + "Enabled"] = checked
                    }

                    KQuickControls.ColorButton {
                        enabled: enabledBox.checked
                        color: Qt.color(cfg["cfg_" + modelData.key + "Color"])
                        onColorChanged: cfg["cfg_" + modelData.key + "Color"] = color.toString().toUpperCase()
                    }
                }
            }
        }
    }
}
