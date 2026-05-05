import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.plasma.plasmoid

Item {
    implicitHeight: col.implicitHeight

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
        var keys = Plasmoid.configuration.SeriesOrder.split(",")
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i].trim()
            if (k) seriesModel.append({ key: k })
        }
    }

    function syncOrder() {
        var keys = []
        for (var i = 0; i < seriesModel.count; i++)
            keys.push(seriesModel.get(i).key)
        Plasmoid.configuration.SeriesOrder = keys.join(",")
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
                    checked: Plasmoid.configuration[model.key + "Enabled"] !== false
                    onCheckedChanged: Plasmoid.configuration[model.key + "Enabled"] = checked
                }

                KQuickControls.ColorButton {
                    enabled: enabledBox.checked
                    color: Qt.color(Plasmoid.configuration[model.key + "Color"] || "#ffffff")
                    onColorChanged: Plasmoid.configuration[model.key + "Color"] = color.toString().toUpperCase()
                }

                QQC2.Label {
                    text: seriesNames[model.key] || model.key
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
                value: Plasmoid.configuration.ScrollSensitivity
                onMoved: Plasmoid.configuration.ScrollSensitivity = value
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
                value: Plasmoid.configuration.WeekCount
                onValueModified: Plasmoid.configuration.WeekCount = value
            }
        }
    }
}
