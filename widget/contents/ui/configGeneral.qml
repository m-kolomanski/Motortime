import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Item {
    id: cfg
    implicitHeight: col.implicitHeight

    property string cfg_SeriesOrder:            "F1,F2,F3,FE,WEC,IGTC,IMSA,NLS,GTWCEurope,GTWCAmerica,GTWCAsia,GTWCAustralia,WRC"
    property bool   cfg_F1Enabled:              true
    property string cfg_F1Color:                "#F0F0F0"
    property bool   cfg_F2Enabled:              true
    property string cfg_F2Color:                "#001F3F"
    property bool   cfg_F3Enabled:              true
    property string cfg_F3Color:                "#888888"
    property bool   cfg_FEEnabled:              true
    property string cfg_FEColor:                "#00CED1"
    property bool   cfg_WECEnabled:             true
    property string cfg_WECColor:               "#1B6FD8"
    property bool   cfg_IGTCEnabled:            true
    property string cfg_IGTCColor:              "#9D4EDD"
    property bool   cfg_IMSAEnabled:            true
    property string cfg_IMSAColor:              "#5A4535"
    property bool   cfg_NLSEnabled:             true
    property string cfg_NLSColor:               "#111111"
    property bool   cfg_GTWCEuropeEnabled:      true
    property string cfg_GTWCEuropeColor:        "#0891B2"
    property bool   cfg_GTWCAmericaEnabled:     true
    property string cfg_GTWCAmericaColor:       "#7C2D12"
    property bool   cfg_GTWCAsiaEnabled:        true
    property string cfg_GTWCAsiaColor:          "#0F766E"
    property bool   cfg_GTWCAustraliaEnabled:   true
    property string cfg_GTWCAustraliaColor:     "#16A34A"
    property bool   cfg_WRCEnabled:             true
    property string cfg_WRCColor:               "#FF6D00"
    property int    cfg_ScrollSensitivity:      240
    property int    cfg_WeekCount:              4

    readonly property var seriesNames: ({
        "F1":            "Formula 1",
        "F2":            "Formula 2",
        "F3":            "Formula 3",
        "FE":            "Formula E",
        "WEC":           "World Endurance Championship",
        "IGTC":          "Intercontinental GT Challenge",
        "IMSA":          "IMSA SportsCar Championship",
        "NLS":           "Nürburgring Langstrecken",
        "GTWCEurope":    "GTWC Europe",
        "GTWCAmerica":   "GTWC America",
        "GTWCAsia":      "GTWC Asia",
        "GTWCAustralia": "GTWC Australia",
        "WRC":           "World Rally Championship"
    })

    ListModel { id: seriesModel }

    function rebuildModel() {
        seriesModel.clear()
        var keys = cfg_SeriesOrder.split(",")
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i].trim()
            if (k) seriesModel.append({ key: k })
        }
    }

    function syncOrder() {
        var keys = []
        for (var i = 0; i < seriesModel.count; i++)
            keys.push(seriesModel.get(i).key)
        cfg_SeriesOrder = keys.join(",")
    }

    Component.onCompleted: rebuildModel()

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top }
        spacing: 2

        Repeater {
            model: seriesModel
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 6

                QQC2.ToolButton {
                    icon.name: "arrow-up"
                    enabled: index > 0
                    onClicked: { seriesModel.move(index, index - 1, 1); syncOrder() }
                }
                QQC2.ToolButton {
                    icon.name: "arrow-down"
                    enabled: index < seriesModel.count - 1
                    onClicked: { seriesModel.move(index, index + 1, 1); syncOrder() }
                }

                QQC2.CheckBox {
                    id: enabledBox
                    checked: cfg["cfg_" + model.key + "Enabled"]
                    onCheckedChanged: cfg["cfg_" + model.key + "Enabled"] = checked
                }

                KQuickControls.ColorButton {
                    enabled: enabledBox.checked
                    color: Qt.color(cfg["cfg_" + model.key + "Color"])
                    onColorChanged: cfg["cfg_" + model.key + "Color"] = color.toString().toUpperCase()
                }

                QQC2.Label {
                    text: cfg.seriesNames[model.key] || model.key
                    Layout.fillWidth: true
                }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 4 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            QQC2.Label { text: "Scroll sensitivity" }

            QQC2.Slider {
                id: scrollSlider
                Layout.fillWidth: true
                from: 360; to: 120; stepSize: 120
                value: cfg_ScrollSensitivity
                onMoved: cfg_ScrollSensitivity = value
            }

            QQC2.Label {
                text: scrollSlider.value <= 120 ? "High"
                    : scrollSlider.value <= 240 ? "Medium"
                    :                             "Low"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            QQC2.Label { text: "Weeks to display" }

            QQC2.SpinBox {
                from: 1; to: 8
                value: cfg_WeekCount
                onValueModified: cfg_WeekCount = value
            }
        }
    }
}
