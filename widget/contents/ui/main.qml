import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "../data/events.js" as EventData

PlasmoidItem {
    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: root
        Layout.minimumWidth:    580
        Layout.minimumHeight:   520
        Layout.preferredWidth:  820
        Layout.preferredHeight: 620

        // Bar height tied to widget height — consistent size regardless of week count.
        // Fixed topOffset means extra row space (fewer weeks) goes to more visible lanes.
        readonly property real barH: Math.max(16, Math.min(52, root.height * 0.048))

        // ── Layout constants ─────────────────────────────────────────────
        readonly property int navH:      30
        readonly property int headerH:   22
        readonly property int cellGap:    4
        readonly property int margin:     8
        readonly property int barGap:     2

        // ── Navigation ───────────────────────────────────────────────────
        property int weekOffset: 0

        // ── Series logos (colors come from config) ───────────────────────
        readonly property var seriesLogos: ({
            "F1":              "../assets/logos/f1.svg",
            "F2":              "../assets/logos/f2.svg",
            "F3":              "../assets/logos/f3.svg",
            "FE":              "../assets/logos/fe.svg",
            "WEC":             "../assets/logos/wec.svg",
            "IGTC":            "../assets/logos/igtc.svg",
            "IMSA":            "../assets/logos/imsa.svg",
            "NLS":             "../assets/logos/nls.svg",
            "GTWCEurope":      "../assets/logos/gtwc.svg",
            "GTWCAmerica":     "../assets/logos/gtwc.svg",
            "GTWCAsia":        "../assets/logos/gtwc.svg",
            "GTWCAustralia":   "../assets/logos/gtwc.svg",
            "WRC":             "../assets/logos/wrc.svg"
        })

        // ── Event data ───────────────────────────────────────────────────
        function parseDate(s) {
            var p = s.split("-")
            return makeDate(parseInt(p[0]), parseInt(p[1]), parseInt(p[2]))
        }

        readonly property var events: {
            var raw = EventData.events
            var loaded = []
            for (var i = 0; i < raw.length; i++) {
                var ev = raw[i]
                loaded.push({
                    series:    ev.series,
                    location:  ev.location,
                    eventType: ev.event_type,
                    flag:      ev.flag,
                    start:     parseDate(ev.start),
                    end:       parseDate(ev.end)
                })
            }
            return loaded
        }

        function makeDate(y, m, d) {
            var dt = new Date(y, m - 1, d)
            dt.setHours(0, 0, 0, 0)
            return dt
        }

        // ── Date helpers ─────────────────────────────────────────────────
        readonly property var today: {
            var d = new Date()
            d.setHours(0, 0, 0, 0)
            return d
        }

        readonly property var gridStart: {
            var d   = new Date(today)
            var dow = d.getDay()
            d.setDate(d.getDate() + (dow === 0 ? -6 : 1 - dow) + weekOffset * 7)
            return d
        }

        function weekStartDate(wi) {
            var d = new Date(gridStart)
            d.setDate(d.getDate() + wi * 7)
            return d
        }
        function weekEndDate(wi) {
            var d = weekStartDate(wi)
            d.setDate(d.getDate() + 6)
            return d
        }
        function cellDate(wi, di) {
            var d = new Date(gridStart)
            d.setDate(d.getDate() + wi * 7 + di)
            return d
        }
        function isToday(d)        { return d.toDateString() === today.toDateString() }
        function isCurrentMonth(d) { return d.getMonth() === today.getMonth() }
        function daysDiff(a, b)    { return Math.round((b - a) / 86400000) }

        // Which grid row index contains today (-1 if not visible)
        readonly property int weekCount: Plasmoid.configuration.WeekCount || 4

        // Zoom state: clicking "+N more" shows a single week; Back restores normal view
        property bool isZoomed:       false
        property int  savedWeekOffset: 0
        readonly property int effectiveWeekCount: isZoomed ? 1 : weekCount

        readonly property int currentGridRow: {
            for (var i = 0; i < effectiveWeekCount; i++) {
                if (today >= weekStartDate(i) && today <= weekEndDate(i)) return i
            }
            return -1
        }

        function navLabel() {
            var s = gridStart
            var e = new Date(gridStart)
            e.setDate(e.getDate() + effectiveWeekCount * 7 - 1)
            if (s.getMonth() === e.getMonth() && s.getFullYear() === e.getFullYear())
                return Qt.formatDate(s, "MMMM yyyy")
            if (s.getFullYear() === e.getFullYear())
                return Qt.formatDate(s, "MMM") + " – " + Qt.formatDate(e, "MMM yyyy")
            return Qt.formatDate(s, "MMM yyyy") + " – " + Qt.formatDate(e, "MMM yyyy")
        }

        // ── Series helpers ────────────────────────────────────────────────
        readonly property var defaultColors: ({
            "F1":            "#F0F0F0",
            "F2":            "#001F3F",
            "F3":            "#888888",
            "FE":            "#00CED1",
            "WEC":           "#1B6FD8",
            "IGTC":          "#9D4EDD",
            "IMSA":          "#5A4535",
            "NLS":           "#111111",
            "GTWCEurope":    "#0891B2",
            "GTWCAmerica":   "#7C2D12",
            "GTWCAsia":      "#0F766E",
            "GTWCAustralia": "#16A34A",
            "WRC":           "#FF6D00"
        })

        function seriesKey(s)     { return s.replace(/ /g, "") }
        function seriesColor(s) {
            var k = seriesKey(s)
            var c = Plasmoid.configuration[k + "Color"]
            return (c && c.length > 0) ? c : (defaultColors[k] || "#888888")
        }
        function seriesEnabled(s) {
            return Plasmoid.configuration[seriesKey(s) + "Enabled"] !== false
        }
        function contrastColor(hex) {
            var r = parseInt(hex.slice(1,3), 16)
            var g = parseInt(hex.slice(3,5), 16)
            var b = parseInt(hex.slice(5,7), 16)
            return (0.299*r + 0.587*g + 0.114*b)/255 > 0.55 ? "#000000" : "#ffffff"
        }

        // ── Event layout for a week ───────────────────────────────────────
        function eventsForWeek(wi) {
            var wS = weekStartDate(wi)
            var wE = weekEndDate(wi)
            var orderStr = Plasmoid.configuration.SeriesOrder
            var orderKeys = (orderStr && orderStr.length > 0)
                ? orderStr.split(",")
                : ["F1","F2","F3","FE","WEC","IGTC","IMSA","NLS","GTWCEurope","GTWCAmerica","GTWCAsia","GTWCAustralia","WRC"]
            var result = []
            for (var i = 0; i < events.length; i++) {
                var ev = events[i]
                if (!seriesEnabled(ev.series)) continue
                if (ev.end < wS || ev.start > wE) continue
                var sc = Math.max(0, daysDiff(wS, ev.start))
                var ec = Math.min(6, daysDiff(wS, ev.end))
                result.push({
                    series:       ev.series,
                    location:     ev.location,
                    eventType:    ev.eventType,
                    flag:         ev.flag,
                    startCol:     sc,
                    endCol:       ec,
                    spanCols:     ec - sc + 1,
                    clippedLeft:  ev.start < wS,
                    clippedRight: ev.end   > wE,
                    lane:         0
                })
            }
            result.sort(function(a,b) {
                var pa = orderKeys.indexOf(seriesKey(a.series))
                var pb = orderKeys.indexOf(seriesKey(b.series))
                if (pa !== pb) return pa - pb
                if (a.startCol !== b.startCol) return a.startCol - b.startCol
                return b.spanCols - a.spanCols
            })
            var lanes = []  // each lane: array of {startCol, endCol} intervals
            for (var j = 0; j < result.length; j++) {
                var e = result[j]
                var placed = false
                for (var lane = 0; lane < lanes.length; lane++) {
                    var free = true
                    for (var k = 0; k < lanes[lane].length; k++) {
                        var occ = lanes[lane][k]
                        if (e.startCol <= occ.endCol && occ.startCol <= e.endCol) {
                            free = false; break
                        }
                    }
                    if (free) {
                        lanes[lane].push({ startCol: e.startCol, endCol: e.endCol })
                        e.lane = lane; placed = true; break
                    }
                }
                if (!placed) {
                    e.lane = lanes.length
                    lanes.push([{ startCol: e.startCol, endCol: e.endCol }])
                }
            }
            return result
        }

        // ── Root layout ───────────────────────────────────────────────────
        ColumnLayout {
            anchors.fill:    parent
            anchors.margins: margin
            spacing:         cellGap

            // ── ▲ Previous week ───────────────────────────────────────────
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: navH
                radius: 4
                color: prevArea.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                opacity: prevArea.containsMouse ? 0.5 : 0.6

                Text {
                    anchors.centerIn: parent
                    text: "▲"
                    font.pixelSize: 13
                    color: Kirigami.Theme.textColor
                }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: weekOffset--
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // ── Date label + Today ────────────────────────────────────────
            Item {
                Layout.fillWidth:       true
                Layout.preferredHeight: navH

                Text {
                    anchors.centerIn: parent
                    text: navLabel()
                    font.pixelSize: 12
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }

                Rectangle {
                    visible: isZoomed
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: backLabel.implicitWidth + 12
                    height: navH - 6
                    radius: 4
                    color: Kirigami.Theme.highlightColor
                    opacity: backArea.containsMouse ? 1.0 : 0.6
                    Text {
                        id: backLabel
                        anchors.centerIn: parent
                        text: "← Back"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { weekOffset = savedWeekOffset; isZoomed = false }
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Rectangle {
                    visible: weekOffset !== 0 && !isZoomed
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: todayLabel.implicitWidth + 12
                    height: navH - 6
                    radius: 4
                    color: Kirigami.Theme.highlightColor
                    opacity: todayArea.containsMouse ? 1.0 : 0.6
                    Text {
                        id: todayLabel
                        anchors.centerIn: parent
                        text: "Today"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                    }
                    MouseArea {
                        id: todayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: weekOffset = 0
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // ── Day-of-week header ─────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:       true
                Layout.preferredHeight: headerH
                spacing: cellGap

                Repeater {
                    model: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                    delegate: Item {
                        Layout.fillWidth:       true
                        Layout.preferredHeight: headerH
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 11
                            font.bold: true
                            color: index >= 5 ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
                            opacity: 0.6
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.textColor
                opacity: 0.15
            }

            // ── week rows ─────────────────────────────────────────────────
            Repeater {
                model: effectiveWeekCount
                delegate: Item {
                    id: weekRow
                    readonly property int weekIdx: index
                    readonly property var weekEvs: eventsForWeek(index)

                    Layout.fillWidth:    true
                    Layout.fillHeight:   true
                    Layout.minimumHeight: 50

                    readonly property bool isPast:    weekEndDate(weekRow.weekIdx) < today
                    readonly property bool isCurrent: weekRow.weekIdx === currentGridRow
                    readonly property bool isNext:    currentGridRow >= 0 && weekRow.weekIdx === currentGridRow + 1

                    // topOffset fixed; barH from widget height → consistent size, more lanes when fewer weeks
                    readonly property real dynBarTopOffset: 30
                    readonly property real dynBarH:         root.barH
                    readonly property real dynFontPx:       Math.max(10, Math.min(14, root.barH * 0.6))

                    // Row background: current week full highlight, next week subtle
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color:   Kirigami.Theme.highlightColor
                        opacity: weekRow.isCurrent ? 0.10 : weekRow.isNext ? 0.04 : 0
                    }

                    // Past week dim overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color:   Kirigami.Theme.backgroundColor
                        opacity: weekRow.isPast ? 0.45 : 0
                    }

                    // Bottom separator
                    Rectangle {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.bottom: parent.bottom
                        height:  1
                        color:   Kirigami.Theme.textColor
                        opacity: 0.12
                    }

                    // Layer 1 — day cells
                    RowLayout {
                        anchors.fill: parent
                        spacing: cellGap

                        Repeater {
                            model: 7
                            delegate: Item {
                                Layout.fillWidth:  true
                                Layout.fillHeight: true

                                readonly property var  date:      cellDate(weekRow.weekIdx, index)
                                readonly property bool todayCell: isToday(date)
                                readonly property bool curMonth:  isCurrentMonth(date)

                                // Today: full cell highlight
                                Rectangle {
                                    visible: todayCell
                                    anchors.fill:    parent
                                    anchors.margins: 1
                                    radius:  4
                                    color:   Kirigami.Theme.highlightColor
                                    opacity: 0.20
                                }

                                Text {
                                    anchors.top:         parent.top
                                    anchors.right:       parent.right
                                    anchors.topMargin:   3
                                    anchors.rightMargin: 5
                                    text:           date.getDate()
                                    font.pixelSize: 13
                                    font.bold:      todayCell
                                    color:          todayCell ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                                    opacity:        curMonth ? 1.0 : 0.4
                                }

                                Text {
                                    visible: date.getDate() === 1
                                    anchors.top:        parent.top
                                    anchors.left:       parent.left
                                    anchors.topMargin:  3
                                    anchors.leftMargin: 5
                                    text:           Qt.formatDate(date, "MMM")
                                    font.pixelSize: 10
                                    color:          Kirigami.Theme.textColor
                                    opacity:        0.5
                                }
                            }
                        }
                    }

                    // Layer 2 — event bars
                    Item {
                        id: overlay
                        anchors.fill: parent

                        readonly property int hiddenCount: {
                            var n = 0
                            for (var i = 0; i < weekRow.weekEvs.length; i++) {
                                var lane = weekRow.weekEvs[i].lane
                                var barY = weekRow.dynBarTopOffset + lane * (weekRow.dynBarH + barGap)
                                if (barY + weekRow.dynBarH > weekRow.height) n++
                            }
                            return n
                        }

                        Item {
                            visible: overlay.hiddenCount > 0
                            anchors.bottom: parent.bottom
                            anchors.right:  parent.right
                            anchors.margins: 4
                            width:  moreLabel.implicitWidth
                            height: moreLabel.implicitHeight

                            Text {
                                id: moreLabel
                                text: "+" + overlay.hiddenCount + " more"
                                font.pixelSize: 12
                                font.bold: true
                                color: Kirigami.Theme.textColor
                                opacity: moreArea.containsMouse ? 1.0 : 0.75
                            }
                            MouseArea {
                                id: moreArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    savedWeekOffset = weekOffset
                                    weekOffset = weekOffset + weekRow.weekIdx
                                    isZoomed = true
                                }
                            }
                        }

                        Repeater {
                            model: weekRow.weekEvs
                            delegate: Item {
                                readonly property var   ev:         modelData
                                readonly property real  cellW:      (overlay.width - cellGap * 6) / 7
                                readonly property real  barX:       ev.startCol * (cellW + cellGap)
                                readonly property real  barW:       ev.spanCols * cellW + (ev.spanCols - 1) * cellGap
                                readonly property real  barY:       weekRow.dynBarTopOffset + ev.lane * (weekRow.dynBarH + barGap)
                                readonly property color barColor:   seriesColor(ev.series)
                                readonly property color labelColor: contrastColor(seriesColor(ev.series))

                                x:       barX
                                y:       barY
                                width:   barW
                                height:  weekRow.dynBarH
                                visible: barY + weekRow.dynBarH <= weekRow.height

                                Rectangle {
                                    anchors.fill: parent
                                    color:  barColor
                                    radius: 3
                                    topLeftRadius:     ev.clippedLeft  ? 0 : 3
                                    bottomLeftRadius:  ev.clippedLeft  ? 0 : 3
                                    topRightRadius:    ev.clippedRight ? 0 : 3
                                    bottomRightRadius: ev.clippedRight ? 0 : 3
                                }

                                Text {
                                    visible: ev.clippedLeft
                                    anchors.left:           parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin:     1
                                    text: "◀"
                                    font.pixelSize: 8
                                    color: labelColor
                                }
                                Text {
                                    visible: ev.clippedRight
                                    anchors.right:          parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin:    1
                                    text: "▶"
                                    font.pixelSize: 8
                                    color: labelColor
                                }

                                // Right: series logo (or text fallback for NLS/GTWC)
                                Item {
                                    id: seriesTag
                                    visible: barW > 56
                                    anchors.right:          parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin:    ev.clippedRight ? 14 : 5
                                    height: weekRow.dynBarH * 2.2
                                    width:  seriesTag.logoPath !== "" ? Math.min(weekRow.dynBarH * 6, 90) : fallbackText.implicitWidth

                                    readonly property string logoPath: seriesLogos[seriesKey(ev.series)] || ""

                                    Image {
                                        id: logoImg
                                        visible:              seriesTag.logoPath !== ""
                                        source:               seriesTag.logoPath !== "" ? Qt.resolvedUrl(seriesTag.logoPath) : ""
                                        anchors.fill:         parent
                                        anchors.margins:      6
                                        fillMode:             Image.PreserveAspectFit
                                        opacity:              0.85
                                    }

                                    Text {
                                        id: fallbackText
                                        visible:          seriesTag.logoPath === ""
                                        anchors.centerIn: parent
                                        text:             ev.series
                                        font.pixelSize:   weekRow.dynFontPx
                                        font.bold:        true
                                        color:            labelColor
                                        opacity:          0.75
                                    }
                                }

                                // Left: flag + location | event type
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left:           parent.left
                                    anchors.right:          seriesTag.visible ? seriesTag.left : parent.right
                                    anchors.leftMargin:     ev.clippedLeft ? 14 : 5
                                    anchors.rightMargin:    4
                                    clip:  true
                                    elide: Text.ElideRight
                                    font.pixelSize: weekRow.dynFontPx
                                    font.bold:      true
                                    color:          labelColor
                                    text: barW > 160 ? ev.flag + " " + ev.location + " | " + ev.eventType
                                        : barW > 80  ? ev.flag + " " + ev.location
                                        : barW > 32  ? ev.flag
                                        :              ""
                                }
                            }
                        }
                    }
                }
            }

            // ── ▼ Next week ───────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: navH
                radius: 4
                color: nextArea.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                opacity: nextArea.containsMouse ? 0.5 : 0.6

                Text {
                    anchors.centerIn: parent
                    text: "▼"
                    font.pixelSize: 13
                    color: Kirigami.Theme.textColor
                }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: weekOffset++
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Mouse wheel scrolling — accumulate delta, step per 120 units
        property real _wheelAccum: 0
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                parent._wheelAccum += wheel.angleDelta.y
                var threshold = Plasmoid.configuration.ScrollSensitivity || 180
                var steps = Math.trunc(parent._wheelAccum / threshold)
                if (steps !== 0) {
                    weekOffset -= steps
                    parent._wheelAccum -= steps * threshold
                }
            }
        }
    }
}
